module fractal(
	// CLOCK
	input CLOCK_50,
	// KEY
	input [3:0]	KEY,
	// SW
	input [17:0] SW,
	// SEG7
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	// LEDs
	output [17:0] LEDR,
	output [7:0]  LEDG,
	// VGA
	output [7:0] VGA_B,
	output [7:0] VGA_G,
	output [7:0] VGA_R,
	output       VGA_HS,
	output       VGA_VS,
	output       VGA_CLK,
	output       VGA_SYNC_N,
	output       VGA_BLANK_N,
	// SRAM
	inout  [15:0] SRAM_DQ,     // SRAM Data bus 16 Bit
	output [19:0] SRAM_ADDR,   // SRAM Address bus 20 bits 
	output        SRAM_UB_N,   // SRAM High-byte Data 
	output        SRAM_LB_N,   // SRAM Low-byte Data M
	output        SRAM_WE_N,   // SRAM Write Enable
	output        SRAM_CE_N,   // SRAM Chip Enable
	output        SRAM_OE_N    // SRAM Output Enable
);

	/*88888b.  8888888888  .d8888b.  888             d8888 
	888  "Y88b 888        d88P  Y88b 888            d88888 
	888    888 888        888    888 888           d88P888 
	888    888 8888888    888        888          d88P 888 
	888    888 888        888        888         d88P  888 
	888    888 888        888    888 888        d88P   888 
	888  .d88P 888        Y88b  d88P 888       d8888888888 
	8888888P"  8888888888  "Y8888P"  88888888 d88P     8*/

	// Common
	wire    clock_system;
	wire    clock_VGA;
	wire    reset_n;
	// pixel position
	wire	[11:0]	current_X;
	wire	[11:0]	current_Y;
	// countain the Data of the color to create
	wire	[9:0]	pixel_R; 
	wire	[9:0]	pixel_G;
	wire	[9:0]	pixel_B;
	// Vertical and horizontal sync signal
	// and output of the module controlling the VGA DAC
	wire			VGA_HS_800x600;			
	wire			VGA_VS_800x600;	
	wire	[9:0]	VGA_R_800x600;
	wire	[9:0]	VGA_G_800x600;
	wire	[9:0]	VGA_B_800x600;

	       /*888  .d8888b.   .d8888b. 8888888  .d8888b.  888b    888 
	      d88888 d88P  Y88b d88P  Y88b  888   d88P  Y88b 8888b   888 
	     d88P888 Y88b.      Y88b.       888   888    888 88888b  888 
	    d88P 888  "Y888b.    "Y888b.    888   888        888Y88b 888 
	   d88P  888     "Y88b.     "Y88b.  888   888  88888 888 Y88b888 
	  d88P   888       "888       "888  888   888    888 888  Y88888 
	 d8888888888 Y88b  d88P Y88b  d88P  888   Y88b  d88P 888   Y8888 
	d88P     888  "Y8888P"   "Y8888P" 8888888  "Y8888P88 888    Y8*/

	// common
	assign  clock_system = CLOCK_50;
	assign  reset_n 	 = KEY[0];
	// Vertical and horizontal sync signal
	assign	VGA_HS = VGA_HS_800x600;	//	VGA H_SYNC
	assign	VGA_VS = VGA_VS_800x600;	//	VGA V_SYNC
	// output to DAC
	assign	VGA_R =	VGA_R_800x600[7:0];
	assign	VGA_G =	VGA_G_800x600[7:0];
	assign	VGA_B =	VGA_B_800x600[7:0];
	// VGA clk output
	assign VGA_CLK = clock_VGA;
	// LEDs
	// assign LEDR = 18'b0;
	assign LEDG = 8'b0;


	/*8b     d888  .d88888b.  8888888b.  888     888 888      8888888888 
	8888b   d8888 d88P" "Y88b 888  "Y88b 888     888 888      888        
	88888b.d88888 888     888 888    888 888     888 888      888        
	888Y88888P888 888     888 888    888 888     888 888      8888888    
	888 Y888P 888 888     888 888    888 888     888 888      888        
	888  Y8P  888 888     888 888    888 888     888 888      888        
	888   "   888 Y88b. .d88P 888  .d88P Y88b. .d88P 888      888        
	888       888  "Y88888P"  8888888P"   "Y88888P"  88888888 88888888*/

	pll_VGA	u1_800x600 (
			.inclk0(clock_system),
			.c0( clock_VGA ) // 40 MHz for 800x600 pixels
		);

	
	VGA_Ctrl	u2_800x600 (
			//	Host Side
			.current_X	   ( current_X ),
			.current_Y	   ( current_Y ),
			.pixel_Red	   ( pixel_R ), 
			.pixel_Green   ( pixel_G ),
			.pixel_Blue	   ( pixel_B ),
			//	VGA Side
			.oVGA_R	   ( VGA_R_800x600 ),
			.oVGA_G	   ( VGA_G_800x600 ),
			.oVGA_B	   ( VGA_B_800x600 ),
			.oVGA_HS   ( VGA_HS_800x600 ),
			.oVGA_VS   ( VGA_VS_800x600 ),
			.oVGA_SYNC ( VGA_SYNC_N ),
			.oVGA_BLANK( VGA_BLANK_N ),
			.oVGA_CLOCK(),
			//	Control Signal
			.iCLK( clock_VGA),
			.iRST_N(reset_n)
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


	fractal_Pattern fractal_Pattern_i (
		//	Read Out Side
		// current pixel color
		.reset_n	 ( reset_n ),
		.pixel_Red	 ( pixel_R ),
		.pixel_Green ( pixel_G ),
		.pixel_Blue	 ( pixel_B ),
		// current cursor position
		.current_X	 ( current_X ),
		.current_Y	 ( current_Y ),
		// clock	
		.VGA_CTRL_CLK (clock_VGA),
		//	Control Signals
		.clean_screen   ( KEY[1]  ), // not the general reset
		.start	   		( KEY[2]  ),
		.VGA_VS	   		( VGA_VS  ),
		.VGA_HS	   		( VGA_HS  ),
		//SRAM
		.SRAM_DQ   ( SRAM_DQ   ),
		.SRAM_ADDR ( SRAM_ADDR ),
		.SRAM_UB_N ( SRAM_UB_N ),
		.SRAM_LB_N ( SRAM_LB_N ),
		.SRAM_WE_N ( SRAM_WE_N ),
		.SRAM_CE_N ( SRAM_CE_N ),
		.SRAM_OE_N ( SRAM_OE_N ),
		.LEDR	   ( LEDR )
	);

			
	Seven_segments_display dbg_num (32'h0, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);		


endmodule
