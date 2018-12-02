module top_dda (
	//////////// CLOCK //////////
	input  CLOCK_50,
	input  AUD_XCK,
	input  TD_CLK27,
	output TD_RESET_N,
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
	//////////// DRAM /////////
	inout  [31:0] DRAM_DQ,
	output [12:0] DRAM_ADDR,
	output [ 1:0] DRAM_BA,
	output		   DRAM_CAS_N,
	output		   DRAM_RAS_N,
	output		   DRAM_CLK,
	output		   DRAM_CKE,
	output		   DRAM_CS_N,
	output		   DRAM_WE_N,
	output [ 3: 0] DRAM_DQM,
	//////////// SRAM /////////
	inout  [15:0] SRAM_DQ,     // SRAM Data bus 16 Bit
	output [19:0] SRAM_ADDR,   // SRAM Address bus 20 bits 
	output        SRAM_UB_N,   // SRAM High-byte Data 
	output        SRAM_LB_N,   // SRAM Low-byte Data M
	output        SRAM_WE_N,   // SRAM Write Enable
	output        SRAM_CE_N,   // SRAM Chip Enable
	output        SRAM_OE_N   // SRAM Output Enable
);

	parameter 	
		ST_RESET            = 2'd0,
		ST_WAIT_RESTART_DDA = 2'd1,
		ST_WAIT_RESTART_LOW = 8'd2,
		ST_LOOP             = 2'd3;

	parameter 	
		START_NIOS_ADDR = 8'd1,
		K1_INIT_ADDR    = 8'd2,   
		K2_INIT_ADDR    = 8'd3,   
		KM_INIT_ADDR    = 8'd4, 
		X1_INIT_ADDR    = 8'd5,   
		V1_INIT_ADDR    = 8'd6,   
		X2_INIT_ADDR    = 8'd7,   
		V2_INIT_ADDR    = 8'd8;   

	//=======================================================
	//  REG/WIRE declarations
	//=======================================================

	wire clk;
	wire reset_n;

	// Dda input output
	wire 	[17:0]	x1;
	wire 	[17:0]	x2;
	wire 	[15:0]	x1_resized;
	wire 	[15:0]	x2_resized;
	reg		[3:0]	state;
	reg				restart_dda;
	reg 	[17:0]	k1_init_loaded;
	reg 	[17:0]	k2_init_loaded;
	reg 	[17:0]	km_init_loaded;
	reg 	[17:0]	x1_init_loaded;
	reg 	[17:0]	x2_init_loaded;
	reg 	[17:0]	v1_init_loaded;
	reg 	[17:0]	v2_init_loaded;
	// Sychronizer

	wire [31:0] pio_init_out;
	reg [31:0]  pio_position_in;
	// 	wire start_nios_tmp;

	reg				start_nios, start_nios_prev;
	reg 	[17:0]	k1_init; 	
	reg 	[17:0]	k2_init; 	
	reg 	[17:0]	km_init; 
	reg 	[17:0]	x1_init; 	
	reg 	[17:0]	x2_init; 	
	reg 	[17:0]	v1_init; 	
	reg 	[17:0]	v2_init; 
	// Nios
	wire 	[7:0] 	nios_out_addr;
	// Debug
	wire 	[31:0] 	dbg_val;

	//=======================================================
	//  Structural coding
	//=======================================================

	nios_system nios_system_i_0 (

	// 1) global signals:
	.clk									(clk),
	.clk_27									(TD_CLK27),
	.reset_n								(reset_n),
	.sys_clk								(),
	.vga_clk								(),
	.sdram_clk								(DRAM_CLK),
	.audio_clk								(AUD_XCK),
	
	// the_SDRAM
	.zs_addr_from_the_SDRAM					(DRAM_ADDR),
	.zs_ba_from_the_SDRAM					(DRAM_BA),
	.zs_cas_n_from_the_SDRAM				(DRAM_CAS_N),
	.zs_cke_from_the_SDRAM					(DRAM_CKE),
	.zs_cs_n_from_the_SDRAM					(DRAM_CS_N),
	.zs_dq_to_and_from_the_SDRAM			(DRAM_DQ),
	.zs_dqm_from_the_SDRAM					(DRAM_DQM),
	.zs_ras_n_from_the_SDRAM				(DRAM_RAS_N),
	.zs_we_n_from_the_SDRAM					(DRAM_WE_N),
	
	// the_SRAM
	.SRAM_DQ_to_and_from_the_SRAM			(SRAM_DQ),
	.SRAM_ADDR_from_the_SRAM				(SRAM_ADDR),
	.SRAM_LB_N_from_the_SRAM				(SRAM_LB_N),
	.SRAM_UB_N_from_the_SRAM				(SRAM_UB_N),
	.SRAM_CE_N_from_the_SRAM				(SRAM_CE_N),
	.SRAM_OE_N_from_the_SRAM				(SRAM_OE_N),
	.SRAM_WE_N_from_the_SRAM				(SRAM_WE_N),

	// the_VGA_Controller
	.VGA_CLK_from_the_VGA_Controller		(VGA_CLK),
	.VGA_HS_from_the_VGA_Controller			(VGA_HS),
	.VGA_VS_from_the_VGA_Controller			(VGA_VS),
	.VGA_BLANK_from_the_VGA_Controller		(VGA_BLANK_N),
	.VGA_SYNC_from_the_VGA_Controller		(VGA_SYNC_N),
	.VGA_R_from_the_VGA_Controller			(VGA_R),
	.VGA_G_from_the_VGA_Controller			(VGA_G),
	.VGA_B_from_the_VGA_Controller			(VGA_B),

	.pio_init_dda_out_export	 			(pio_init_out),
	.pio_positions_in_export	 			(pio_position_in)
	);


	dda dda_i_0 (
		.clk		(clk), 
		.reset		(reset_n),
		// .reset		(KEY[1]),
		.restart	(restart_dda),
		// .restart	(!KEY[3]),
		.k1_init 	(k1_init_loaded),
		.k2_init 	(k2_init_loaded),
		.km_init 	(km_init_loaded),
		.x1_init 	(x1_init_loaded),
		.x2_init 	(x2_init_loaded),
		.v1_init 	(v1_init_loaded),
		.v2_init 	(v2_init_loaded),
		.x1_out		(x1),
		.x2_out		(x2)
	);


	Seven_segments_display dbg_num (dbg_val, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);		

	
	assign clk            = CLOCK_50;
	assign reset_n        = KEY[0];
	assign start_nios_tmp = !KEY[2];
	// data creation resizing
	assign x1_resized    = x1[17:2];
	assign x2_resized    = x2[17:2];
	assign nios_out_addr = pio_init_out[31:24];
	// debug
	assign dbg_val       = 32'h0;



	always @ (posedge clk or negedge reset_n) begin
		if (! reset_n) begin
			pio_position_in <= 32'b0;
		end
		else begin
			pio_position_in <= {x1_resized, x2_resized};
		end
	end


	// Synchronizer between NIOS clock (50 MHz) and VGA clock (40 MHz)
	//Update state variables of simulation of spring- mas
	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			start_nios <= 1'b0;
			k1_init    <= 18'h0;
			k2_init    <= 18'h0;
			km_init    <= 18'h0;
			x1_init    <= 18'h0;
			v1_init    <= 18'h0;
			x2_init    <= 18'h0;
			v2_init    <= 18'h0;
		end
		else begin
			if (nios_out_addr == START_NIOS_ADDR) start_nios <= pio_init_out[0];
			else 								  start_nios <= start_nios;

			if (nios_out_addr == K1_INIT_ADDR)  k1_init <= pio_init_out[17:0];
			else 								k1_init <= k1_init;

			if (nios_out_addr == K2_INIT_ADDR)  k2_init <= pio_init_out[17:0];
			else 								k2_init <= k2_init;

			if (nios_out_addr == KM_INIT_ADDR) 	km_init <= pio_init_out[17:0];
			else 								km_init <= km_init;

			if (nios_out_addr == X1_INIT_ADDR) 	x1_init <= pio_init_out[17:0];
			else 								x1_init <= x1_init;

			if (nios_out_addr == V1_INIT_ADDR)  v1_init <= pio_init_out[17:0];
			else 								v1_init <= v1_init;

			if (nios_out_addr == X2_INIT_ADDR)  x2_init <= pio_init_out[17:0];
			else 								x2_init <= x2_init;

			if (nios_out_addr == V2_INIT_ADDR)  v2_init <= pio_init_out[17:0];
			else 								v2_init <= v2_init;
		end
	end



	//Update state variables of simulation of spring- mass
	always @ (posedge clk or negedge reset_n) begin
		
		if (!reset_n) begin 
			state <= ST_RESET;
			restart_dda <= 1'b0;
		end
		else begin

			case (state)

				////////////////////////////////////////////////////////
				ST_RESET: begin
					state          <= ST_WAIT_RESTART_DDA;
					k1_init_loaded <= 18'h0;
					k2_init_loaded <= 18'h0;
					km_init_loaded <= 18'h0;
					x1_init_loaded <= 18'h0;
					v1_init_loaded <= 18'h0;
					x2_init_loaded <= 18'h0;
					v2_init_loaded <= 18'h0;
				end

				////////////////////////////////////////////////////////
				ST_WAIT_RESTART_DDA: begin
					if(start_nios) begin
						state       <= ST_WAIT_RESTART_LOW;
						restart_dda <= 1'b1;
						
						// update dda values
						k1_init_loaded   <= k1_init;
						k2_init_loaded   <= k2_init;
						km_init_loaded   <= km_init;
						x1_init_loaded   <= x1_init;
						v1_init_loaded   <= v1_init;
						x2_init_loaded   <= x2_init;
						v2_init_loaded   <= v2_init;

						// k1_init_loaded <= 18'h10000;
						// k2_init_loaded <= 18'h10000;
						// km_init_loaded <= 18'h10000;
						// x1_init_loaded <= 18'h3C000;
						// v1_init_loaded <= 18'h38000;
						// x2_init_loaded <= 18'h0E800;
						// v2_init_loaded <= 18'h06800;
					end
				end

				////////////////////////////////////////////////////////
				ST_WAIT_RESTART_LOW: begin
				if (!start_nios) begin
						state <= ST_LOOP;
						restart_dda <= 1'b0;
					end
				end

				////////////////////////////////////////////////////////
				ST_LOOP: begin
					if(start_nios) begin
						state       <= ST_WAIT_RESTART_DDA;
						restart_dda <= 1'b1;
					end
					else begin
						restart_dda <= 1'b0;
					end
				end

				////////////////////////////////////////////////////////
				default: begin
					state <= ST_RESET;
				end

			endcase
		end	
	end

endmodule
