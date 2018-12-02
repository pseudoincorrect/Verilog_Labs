module fractal_Pattern (	
			//	Host Side
			input  [11:0] current_X,
			input  [11:0] current_Y,
			output [9:0]  pixel_Red,
			output [9:0]  pixel_Green,
			output [9:0]  pixel_Blue,
			//	clock
			input 		  VGA_CTRL_CLK,
			//	Control Signals
			input 		  clean_screen,
			input 		  start,
			input 		  VGA_VS, 
			input 		  VGA_HS,
			input		  reset_n,
			// SRAM
			inout  [15:0] SRAM_DQ,     // SRAM Data bus 16 Bit
			output [19:0] SRAM_ADDR,   // SRAM Address bus 20
			output        SRAM_UB_N,   // SRAM High-byte Data 
			output        SRAM_LB_N,   // SRAM Low-byte Data M
			output        SRAM_WE_N,   // SRAM Write Enable
			output        SRAM_CE_N,   // SRAM Chip Enable
			output        SRAM_OE_N,    // SRAM Output Enable
			output reg [17:0] LEDR
);

	//state names
	parameter ST_INIT    = 4'd0;
	parameter ST_START   = 4'd1;
	parameter ST_READ    = 4'd2;
	parameter ST_WRITE_1 = 4'd3;
	parameter ST_WRITE_2 = 4'd4;


	/*88888b.  8888888888  .d8888b.  888             d8888 
	888  "Y88b 888        d88P  Y88b 888            d88888 
	888    888 888        888    888 888           d88P888 
	888    888 8888888    888        888          d88P 888 
	888    888 888        888        888         d88P  888 
	888    888 888        888    888 888        d88P   888 
	888  .d88P 888        Y88b  d88P 888       d8888888888 
	8888888P"  8888888888  "Y8888P"  88888888 d88P     8*/

	reg 	    lock; 	 //did we stay in sync?
	reg  [3:0]  state;	 //state machine
	reg  [15:0] data_reg; //memory data register  for SRAM
	reg  [19:0] addr_reg; //memory address register for SRAM
	reg  [20:0] washer;
	reg 	   	we_n;  //write enable for SRAM
	// Fractal_control
	reg			start_fract;
	wire [9:0]	x_coord_out;
	wire [9:0]	y_coord_out;
	wire [10:0]	interation_count;
	wire	 	is_in_the_set;
	reg	 		data_out_read;
	wire	 	data_out_available;
	reg [19:0]	coordinate;
	// reg toggle;
	       /*888  .d8888b.   .d8888b. 8888888  .d8888b.  888b    888 
	      d88888 d88P  Y88b d88P  Y88b  888   d88P  Y88b 8888b   888 
	     d88P888 Y88b.      Y88b.       888   888    888 88888b  888 
	    d88P 888  "Y888b.    "Y888b.    888   888        888Y88b 888 
	   d88P  888     "Y88b.     "Y88b.  888   888  88888 888 Y88b888 
	  d88P   888       "888       "888  888   888    888 888  Y88888 
	 d8888888888 Y88b  d88P Y88b  d88P  888   Y88b  d88P 888   Y8888 
	d88P     888  "Y8888P"   "Y8888P" 8888888  "Y8888P88 888    Y8*/

	// SRAM_control
	assign SRAM_ADDR = addr_reg; 
	assign SRAM_DQ   = (we_n)? 16'hzzzz : data_reg ;
	assign SRAM_UB_N = 0;	 // hi byte select enabled
	assign SRAM_LB_N = 0;	 // lo byte select enabled
	assign SRAM_CE_N = 0;	 // chip is enabled
	assign SRAM_WE_N = we_n; // write when ZERO
	assign SRAM_OE_N = 0;	 // output enable is overidden by WE
	// Show SRAM on the VGA
	assign  pixel_Red   = {SRAM_DQ[15:12], 6'b0} ;
	assign  pixel_Green = {SRAM_DQ[11:8] , 6'b0} ;
	assign  pixel_Blue  = {SRAM_DQ[7:4]  , 6'b0} ;


	/*8b     d888  .d88888b.  8888888b.  888     888 888      8888888888 
	8888b   d8888 d88P" "Y88b 888  "Y88b 888     888 888      888        
	88888b.d88888 888     888 888    888 888     888 888      888        
	888Y88888P888 888     888 888    888 888     888 888      8888888    
	888 Y888P 888 888     888 888    888 888     888 888      888        
	888  Y8P  888 888     888 888    888 888     888 888      888        
	888   "   888 Y88b. .d88P 888  .d88P Y88b. .d88P 888      888        
	888       888  "Y88888P"  8888888P"   "Y88888P"  88888888 88888888*/

	Fractal_control Fractal_control_i (
		.clock              (VGA_CTRL_CLK),
		.reset_n            (reset_n),
		.start              (start_fract),
		.data_out_read      (data_out_read),
		.x_coord_out        (x_coord_out),
		.y_coord_out        (y_coord_out),
		.interation_count   (interation_count),
		.is_in_the_set      (is_in_the_set),
		.data_out_available (data_out_available)
	);

	/*88888888  .d8888b.  888b     d888 
	888        d88P  Y88b 8888b   d8888 
	888        Y88b.      88888b.d88888 
	8888888     "Y888b.   888Y88888P888 
	888            "Y88b. 888 Y888P 888 
	888              "888 888  Y8P  888 
	888        Y88b  d88P 888   "   888 
	888         "Y8888P"  888       8*/

	always @ (posedge VGA_CTRL_CLK)
	begin
		
		// active low reset, condition is true when key0 is pushed
		// synch reset assumes KEY0 is held down 1/60 secon
		if (!clean_screen)	
		begin
			//clear the screen
			addr_reg <= {washer[19:0]};
			we_n     <= 1'b0;	//write enabled
			data_reg <= 16'hFFFF;	//write blk
			state    <= ST_INIT;	
			if (washer < 21'h1FFFFF) washer <= washer + 21'h1;
			else		 			 washer <= 21'h0;
		end
		
		//modify display during sync
		//sync is active low; KEY3 is pause
		else if (~VGA_VS | ~VGA_HS)
		begin
			case(state)

				ST_INIT: begin
					if ( ! start) begin
						state       <= ST_START;
						start_fract <= 1'b1;
					end 
					start_fract <= 1'b0;
					LEDR        <= 18'b0;
					coordinate  <= 20'b0;
					// toggle        <= 1'b0;
				end			

				ST_START: begin
					we_n          <= 1'b1; 	
					state         <= ST_READ ;	
					data_out_read <= 1'd0;
					start_fract   <= 1'b1;
				end

				ST_READ: begin
					if (data_out_available) begin
						state         <= ST_WRITE_1;
						LEDR[1]       <= 1'b1;	
						data_out_read <= 1'd1;
					end
					else begin
						data_out_read <= 1'd0;
						LEDR[1]       <= 1'b0;
					end
					we_n        <= 1'b1; 	
					addr_reg    <= {10'd0, 10'd0};
					start_fract <= 1'b0;
				end


				ST_WRITE_1: begin
					state         <= ST_READ;
					addr_reg      <= {x_coord_out + 10'd500, y_coord_out + 10'd200};
					// addr_reg      <= {x_coord_out, y_coord_out};
					// addr_reg      <= coordinate;
					// coordinate <= coordinate + 20'h401;
					// data_reg      <= {16{x_coord_out[0]}};
					// toggle        <= ~toggle;
					data_reg      <= {16{is_in_the_set}};
					// data_reg      <= {{interation_count[7:0]},{8'b0}};
					// data_reg      <= {16{1'b0}};
					// LEDR[2]		  <= |{interation_count};
					data_out_read <= 1'd0;
					we_n          <= 1'b0;
				end

				// ST_WRITE_2: begin
				// 	if (!lock) begin
				// 		state         <= ST_WRITE_1;
				// 	end
				// 	else begin
				// 		state         <= ST_READ;
				// 		addr_reg      <= {x_coord_out + 10'd100, y_coord_out + 10'd100};
				// 		data_reg      <= {16{is_in_the_set}};
				// 		// data_reg      <= {16{1'b0}};
				// 		LEDR[2]		  <= |{interation_count};
				// 		we_n          <= 1'b0;
				// 		data_out_read <= 1'd0;
				// 		LEDR[1]       <= 1'b1;
				// 	end
				// end


				default: begin
					state <= ST_INIT;
				end

			endcase
		end
		
		//show display when not blanking, 
		//which implies we_n=1 (not enabled); and use VGA module address
		else
		begin
			we_n     <= 1'b1;
			addr_reg <= {current_X[9:0], current_Y[9:0]};
		end	
	end

endmodule //top module