module automaton(
	//////////// CLOCK //////////
	input CLOCK_50,
	//////////// KEY //////////
	input [3:0]	KEY,
	//////////// SW //////////
	input [17:0] SW,
	//////////// SEG7 //////////
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	//////////// LEDs /////////
	output [17:0] LEDR,
	output [7:0]  LEDG,
	//////////// VGA //////////
	output [7:0] VGA_B,
	output [7:0] VGA_G,
	output [7:0] VGA_R,
	output       VGA_HS,
	output       VGA_VS,
	output       VGA_CLK,
	output       VGA_SYNC_N,
	output       VGA_BLANK_N,
	//////////// SRAM /////////
	inout  [15:0] SRAM_DQ,     // SRAM Data bus 16 Bit
	output [19:0] SRAM_ADDR,   // SRAM Address bus 20 bits 
	output        SRAM_UB_N,   // SRAM High-byte Data 
	output        SRAM_LB_N,   // SRAM Low-byte Data M
	output        SRAM_WE_N,   // SRAM Write Enable
	output        SRAM_CE_N,   // SRAM Chip Enable
	output        SRAM_OE_N   // SRAM Output Enable
);
	parameter R_SZ = 512;

// end DE2_115_VGA declaration

	//=======================================================
	//  REG/WIRE declarations
	//=======================================================

	wire	VGA_CTRL_CLK_800x600;
	wire	VGA_CTRL_CLK = VGA_CTRL_CLK_800x600;
	assign  VGA_CLK   	 = VGA_CTRL_CLK;

	wire	VGA_HS_800x600;			
	wire	VGA_VS_800x600;	
	assign	VGA_HS = VGA_HS_800x600;	//	VGA H_SYNC
	assign	VGA_VS = VGA_VS_800x600;	//	VGA V_SYNC

	wire	[11:0]	current_X;
	wire	[11:0]	current_Y;

	// countain the Data of the color to create
	wire	[9:0]	pixel_R; 
	wire	[9:0]	pixel_G;
	wire	[9:0]	pixel_B;

	// output of the module controlling the VGA DAC
	wire	[9:0]	sVGA_R_800x600;
	wire	[9:0]	sVGA_G_800x600;
	wire	[9:0]	sVGA_B_800x600;
	// intermediate for the module controlling the DAC and the output to the DAC
	wire	[9:0]	sVGA_R = sVGA_R_800x600;
	wire	[9:0]	sVGA_G = sVGA_G_800x600;
	wire	[9:0]	sVGA_B = sVGA_B_800x600;

	// output to DAC
	assign	VGA_R	=	sVGA_R[7:0];
	assign	VGA_G	=	sVGA_G[7:0];
	assign	VGA_B	=	sVGA_B[7:0];

	wire [31:0] dbg_val;

	//=======================================================
	//  Structural coding
	//=======================================================

	VGA_CLK	u1_800x600 (
			.inclk0(CLOCK_50),
			.c0( VGA_CTRL_CLK_800x600 )
		);
		defparam u1_800x600.PLL_MUL= 40;
		defparam u1_800x600.PLL_DIV= 50;
	/////// end VGA_CLK
	
	VGA_Ctrl	u2_800x600 (
			//	Host Side
			.current_X	   ( current_X ),
			.current_Y	   ( current_Y ),
			.pixel_Red	   ( pixel_R ), 
			.pixel_Green   ( pixel_G ),
			.pixel_Blue	   ( pixel_B ),
			//	VGA Side
			.oVGA_R	   ( sVGA_R_800x600 ),
			.oVGA_G	   ( sVGA_G_800x600 ),
			.oVGA_B	   ( sVGA_B_800x600 ),
			.oVGA_HS   ( VGA_HS_800x600 ),
			.oVGA_VS   ( VGA_VS_800x600 ),
			.oVGA_SYNC ( VGA_SYNC_N ),
			.oVGA_BLANK( VGA_BLANK_N ),
			.oVGA_CLOCK(),
			//	Control Signal
			.iCLK( VGA_CTRL_CLK),
			.iRST_N(KEY[0])
			// .les_btn( KEY[2])
		);
		defparam	u2_800x600.H_FRONT =	40;
		defparam	u2_800x600.H_SYNC  =	128;
		defparam	u2_800x600.H_BACK  =	88;
		defparam	u2_800x600.H_ACT   =	800;
		defparam	u2_800x600.V_FRONT =	1;
		defparam	u2_800x600.V_SYNC  =	4;
		defparam	u2_800x600.V_BACK  =	23;
		defparam	u2_800x600.V_ACT   =	600;
    /////// end VA_Ctrl

	VGA_Pattern Pattern_DLA (
		//	Read Out Side
		// current pixel color
		.pixel_Red	 ( pixel_R ),
		.pixel_Green ( pixel_G ),
		.pixel_Blue	 ( pixel_B ),
		// current cursor position
		.current_X	 ( current_X ),
		.current_Y	 ( current_Y ),
		// clock	
		.VGA_CTRL_CLK (VGA_CTRL_CLK),
		//	Control Signals
		.rand_sel  ( SW[17]  ),
		.pause 	   ( SW[16]  ),
		.SW_rule   ( SW[7:0] ),
		.dbg_val   ( dbg_val ),
		.reset_n   ( KEY[1]  ),
		.start	   ( KEY[2]  ),
		.resume    ( KEY[3]	 ),
		.VGA_VS	   ( VGA_VS  ),
		.VGA_HS	   ( VGA_HS  ),
		//SRAM
		.SRAM_DQ   ( SRAM_DQ   ),
		.SRAM_ADDR ( SRAM_ADDR ),
		.SRAM_UB_N ( SRAM_UB_N ),
		.SRAM_LB_N ( SRAM_LB_N ),
		.SRAM_WE_N ( SRAM_WE_N ),
		.SRAM_CE_N ( SRAM_CE_N ),
		.SRAM_OE_N ( SRAM_OE_N ),
		.LEDG	   ( LEDG ),
		.LEDR	   ( LEDR )
	);
    /////// end VGA_Pattern

			
	Seven_segments_display dbg_num (dbg_val, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);		

endmodule
