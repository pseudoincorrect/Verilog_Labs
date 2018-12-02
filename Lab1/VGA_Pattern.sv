module VGA_Pattern (	
			//	Host Side
			input  [11:0] current_X,
			input  [11:0] current_Y,
			output [9:0]  pixel_Red,
			output [9:0]  pixel_Green,
			output [9:0]  pixel_Blue,
			//	clock
			input 		  VGA_CTRL_CLK,
			//	Control Signals
			input 		  reset_n,
			input  		  pause,
			input 		  start,
			input		  resume,
			input  [7:0]  SW_rule,
			input		  rand_sel,
			input 		  VGA_VS, 
			input 		  VGA_HS,
			output [31:0] dbg_val,
			// SRAM
			inout  [15:0] SRAM_DQ,     // SRAM Data bus 16 Bit
			output [19:0] SRAM_ADDR,   // SRAM Address bus 20
			output        SRAM_UB_N,   // SRAM High-byte Data 
			output        SRAM_LB_N,   // SRAM Low-byte Data M
			output        SRAM_WE_N,   // SRAM Write Enable
			output        SRAM_CE_N,   // SRAM Chip Enable
			output        SRAM_OE_N,    // SRAM Output Enable

			output [7:0]  LEDG,
			output [17:0] LEDR
);

reg 	   lock; 	 //did we stay in sync?
reg [3:0]  state;	 //state machine
reg [7:0]  led;		 //debug led register
reg [9:0]  x_walker; //particle coords
reg [9:0]  y_walker;
reg [15:0] data_reg; //memory data register  for SRAM
reg [19:0] addr_reg; //memory address register for SRAM
reg [20:0] washer;

reg [30:0] x_rand;	 //shift registers for random number gen  
reg [28:0] y_rand;
wire x_low_bit, y_low_bit; //rand low bits for SR

reg [2:0]  sum; 	 //neighbor sum
wire 	   we;  //write enable for SRAM
wire [7:0] rule;

// SRAM_control
assign SRAM_ADDR = addr_reg; 
assign SRAM_DQ = (we)? 16'hzzzz : data_reg ;
assign SRAM_UB_N = 0;					// hi byte select enabled
assign SRAM_LB_N = 0;					// lo byte select enabled
assign SRAM_CE_N = 0;					// chip is enabled
assign SRAM_WE_N = we;					// write when ZERO
assign SRAM_OE_N = 0;					//output enable is overidden by WE

// Show SRAM on the VGA
assign  pixel_Red   = {SRAM_DQ[15:12], 6'b0} ;
assign  pixel_Green = {SRAM_DQ[11:8] , 6'b0} ;
assign  pixel_Blue  = {SRAM_DQ[7:4]  , 6'b0} ;

// DLA state machine
assign LEDG = led;
assign led = 7'b0;

assign x_low_bit = x_rand[27] ^ x_rand[30];
assign y_low_bit = y_rand[26] ^ y_rand[28];

//state names
parameter init = 4'd0, test1 = 4'd1, test2 = 4'd2, test3 = 4'd3, test4 = 4'd4, 
		  draw_walker = 4'd5, update_walker = 4'd6, wait_walker = 4'd7, copy_last_line1 = 4'd8, 
		  copy_last_line2 = 4'd9, copy_last_line3 = 4'd10;

always @ (posedge VGA_CTRL_CLK)
begin
	
	// active low reset, condition is true when key0 is pushed
	if (!reset_n)		//synch reset assumes KEY0 is held down 1/60 second
	begin
		//clear the screen
		// addr_reg <= {current_X[9:0], current_Y[9:0]};	// [19:0] 20 bits
		addr_reg       <= {washer[19:0]};	// [19:0] 20 bits
		we             <= 1'b0;								//write some memory
		data_reg       <= 16'b0;	//write blk
		rule           <= SW_rule;
		//init random number generators to alternating bits
		x_rand   <= 31'h55555555;
		y_rand   <= 29'h55555555;

		state    <= init;	//first state in regular state machine 
		dbg_val  <= 32'h68;
		LEDR     <= 18'b0;	

		if (washer < 21'h1FFFFF) washer = washer + 21'h1;
		else		 			 washer = 21'h0;
	end
	
	//modify display during sync
	else if ((~VGA_VS | ~VGA_HS) &  ( ! pause) )  //sync is active low; KEY3 is pause
	begin
		case(state)
			init:
			begin
				if ( ! start) begin
					if ( ! rand_sel) begin
						addr_reg <= {10'd400,10'd300} ;	//(x,y)
						//init a walker
						x_walker <= 10'd1;
						y_walker <= 10'd301;
					end else begin
						addr_reg <= {1'b0, x_rand[8:0], 1'b0 ,y_rand[8:0]} ;	//(x,y)
						//init a walker
						x_walker <= 10'd1;
						y_walker <= {1'b0 ,y_rand[8:0]} + 10'd1;
					end
					we       <= 1'b0;								
					//write the seed (random or not)
					data_reg <= 16'hFFFF ;
					state    <= test1 ;
				end else
					state <= init;

				dbg_val  <= {8'b0, 3'b0, x_rand[8:0], 3'b0 ,y_rand[8:0]};
			end			

			test1: //read upper left neighbor
			begin	
				lock     <= 1'b1; 	//set the interlock to detect end of sync interval
				sum      <= 0; 		//init sum of neighbors
				we       <= 1'b1; 	//no memory write 
				addr_reg <= {x_walker - 10'd1, y_walker - 10'd1};
				state    <= test2 ;	
				dbg_val  <= 32'h1;	
			end

			test2: //read upper midle neighbor
			begin	
				sum     <= sum | {SRAM_DQ[15], 2'b0};
				we       <= 1'b1; 	//no memory write 
				addr_reg <= {x_walker, y_walker - 10'd1};
				state    <= test3 ;	
				dbg_val  <= 32'h2;	
			end

			test3: //read  upper right neighbor
			begin	
				sum      <= sum | {1'b0, SRAM_DQ[15], 1'b0};		
				we       <= 1'b1; 	//no memory write 
				addr_reg <= {x_walker + 10'd1, y_walker - 10'd1};
				state    <= test4 ;	
				dbg_val  <= 32'h3;	
			end

			test4: 
			begin
				sum     <= sum | {2'b0, SRAM_DQ[15]}; 		
				we      <= 1'b1; //no memory write 
				state   <= draw_walker;
				dbg_val <= 32'h5;
			end	

			draw_walker: //draw the walker
			begin
				if (lock) begin
					if (rule[sum]) 
						data_reg <= 16'hFFFF;
					else
						data_reg <= 16'h0;
					
					we       <= 1'b0; // memory write 
					addr_reg <= {x_walker, y_walker};
					state    <= update_walker ;	
				end else begin // if get here, then no neighbors, so update position
					sum   <= 3'b0;
					state <= test1;		
				end
				dbg_val <= 32'h6;
			end

			update_walker: //update the walker
			begin
				we <= 1'b1; //no mem write
				//inc/dec x while staying on screen
				if (x_walker < 800) begin
					x_walker <= x_walker + 10'd1;
					state    <= test1;	
				end else begin
					if (y_walker < 600) begin
						x_walker <= 10'd1;
						y_walker <= y_walker + 10'd1;
						state    <= test1;	
					end else begin
						state    <= wait_walker;
						y_walker <= y_walker;
					end
				end
				dbg_val <= 32'h8;
			end

			wait_walker: 
			begin
				if ( ! resume ) begin
					// state <= wait_walker;
					// state <= test1;
					state    <= copy_last_line1;
					x_walker <= 10'd0;

				end else begin
					state <= wait_walker;
				end
				dbg_val <= 32'h9;
			end

			copy_last_line1:
			begin
				lock 	 <= 1'b1;
				we       <= 1'b1; // read SRAM
				addr_reg <= {x_walker, y_walker};
				state    <= copy_last_line2;
				dbg_val  <= 32'h11;
			end

			copy_last_line2:
			begin
				if (lock) begin
					we       <= 1'b0; // write SRAM
					data_reg <= SRAM_DQ;
					addr_reg <= {x_walker, 10'd0};

					if (x_walker < 10'd800) begin
						x_walker <= x_walker + 10'd1;
						state    <= copy_last_line1;
					end else begin
						x_walker <= 10'd1;
						y_walker <= 10'd1;
						// state    <= wait_walker;
						state    <= test1;
					end
				end else begin
					state <= copy_last_line1;
				end
				dbg_val <= 32'h13;
			end
		endcase

		x_rand <= {x_rand[29:0], x_low_bit} ;
		y_rand <= {y_rand[27:0], y_low_bit} ;
	end
	
	//show display when not blanking, 
	//which implies we=1 (not enabled); and use VGA module address
	else
	begin
		lock <= 1'b0; //clear lock if display starts because this destroys mem addr_reg
		we 	 <= 1'b1;
		addr_reg <= {current_X[9:0], current_Y[9:0]};
	end
end

endmodule //top module