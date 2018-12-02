module	VGA_Ctrl	(
	//	Host Side
	input		[9:0]	pixel_Red,
	input		[9:0]	pixel_Green,
	input		[9:0]	pixel_Blue,
	output		[11:0]	current_X,
	output		[11:0]	current_Y,
	//	VGA Side
	output		[9:0]	oVGA_R, // DAC value
	output		[9:0]	oVGA_G, // DAC value
	output		[9:0]	oVGA_B, // DAC value

	output	reg			oVGA_HS, // horizontal sync signal
	output	reg			oVGA_VS, // vertical sync signal

	output				oVGA_SYNC, // unused
	output				oVGA_BLANK,
	output				oVGA_CLOCK, // opposed phase clk
	//	Control Signal
	input				iCLK,
	input				iRST_N
	// input wire les_btn					
);
	//	Internal Registers
	reg			[10:0]	H_Cont;
	reg			[10:0]	V_Cont;

	////////////////////////////////////////////////////////////

	//	Horizontal default Parameter
	parameter	H_FRONT	=	16;
	parameter	H_SYNC	=	96;
	parameter	H_BACK	=	48;
	parameter	H_ACT	=	640;
	//	Vertical default Parameter
	parameter	V_FRONT	=	10;
	parameter	V_SYNC	=	2;
	parameter	V_BACK	=	33;
	parameter	V_ACT	=	480;
	////////////////////////////////////////////////////////////
	parameter	H_BLANK	=	H_FRONT+H_SYNC+H_BACK;
	parameter	H_TOTAL	=	H_FRONT+H_SYNC+H_BACK+H_ACT;
	parameter	V_BLANK	=	V_FRONT+V_SYNC+V_BACK;
	parameter	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT;
	////////////////////////////////////////////////////////////
	assign	oVGA_SYNC	=	1'b1;			//	This pin is unused.
	assign	oVGA_BLANK	=	~((H_Cont<H_BLANK)||(V_Cont<V_BLANK));
	assign	oVGA_CLOCK	=	~iCLK;
	assign	oVGA_R		=	(current_X > 0) ?	pixel_Red :   10'b0 ;
	assign	oVGA_G		=	(current_X > 0) ?	pixel_Green : 10'b0 ;
	assign	oVGA_B		=	(current_X > 0) ?	pixel_Blue :  10'b0 ;

	assign	current_X	=	(H_Cont>=H_BLANK)	?	H_Cont-H_BLANK[10:0]	:	11'h0	;
	assign	current_Y	=	(V_Cont>=V_BLANK)	?	V_Cont-V_BLANK[10:0]	:	11'h0	;

	// reg [9:0] V_ACT;
	// reg [9:0] V_TOTAL;
	// reg [7:0] btn_cnt;
	// always@(posedge les_btn)
	// begin
	// 	btn_cnt= btn_cnt + 8'h1;
	// end

	//	Horizontal Generator: Refer to the pixel clock
	always @ (posedge iCLK or negedge iRST_N)
	begin
		if(!iRST_N)
		begin
			H_Cont		<=	0;
			oVGA_HS		<=	1;
		//	V_ACT	<=	480 +btn_cnt;
		//	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT;
		end
		else
		begin
			if(H_Cont<H_TOTAL-1)
			H_Cont	<=	H_Cont+1'b1;
			else
			H_Cont	<=	0;
			//	Horizontal Sync
			if(H_Cont==H_FRONT-1)			//	Front porch end
			oVGA_HS	<=	1'b0;
			else if(H_Cont==H_FRONT+H_SYNC-1)	//	Sync pulse end
			oVGA_HS	<=	1'b1;
		end
	end

	//	Vertical Generator: Refer to the horizontal sync
	always@(posedge oVGA_HS or negedge iRST_N)
	begin
		if(!iRST_N)
		begin
			V_Cont		<=	0;
			oVGA_VS		<=	1;
		end
		else
		begin
			if(V_Cont<V_TOTAL-1)
				V_Cont	<=	V_Cont+1'b1;
			else
				V_Cont	<=	0;
			//	Vertical Sync
			if(V_Cont==V_FRONT-1)			//	Front porch end
				oVGA_VS	<=	1'b0;
			if(V_Cont==V_FRONT+V_SYNC-1)	//	Sync pulse end
				oVGA_VS	<=	1'b1;
		end
	end


endmodule
