module VGA_Pattern (	
			// Host Side
			input  [11:0] current_X,
			input  [11:0] current_Y,
			input  signed [9:0]  x1_resized,
			input  signed [9:0]  x2_resized,
			output [9:0]  pixel_Red,
			output [9:0]  pixel_Green,
			output [9:0]  pixel_Blue,
			// input		  start,
			// Clock
			input 		  VGA_CTRL_CLK,
			// Control Signals
			input 		  reset_n,
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
			output [17:0] LEDR, 

			output [3:0] stateST
);

// State names
parameter 	
	ST_reset         = 4'd0,
	ST_clear_display = 4'd1,
	ST_wait          = 4'd2,
	ST_pre_clean_1   = 4'd3,
	ST_pre_clean_2   = 4'd4,
	ST_draw_x1       = 4'd5,
	ST_draw_x2       = 4'd6,
	ST_clean_1       = 4'd7,
	ST_clean_2       = 4'd8,
	ST_end           = 4'd9,
	ST_pause_0 		 = 4'd10,
	ST_pause_1 		 = 4'd11;


// Misc
parameter X_MAX = 10'd640;
parameter Y_MAX = 10'd480;

reg [20:0] washer;
reg [9:0]  x_walker;
reg [9:0]  x_cln_walker, y_cln_walker;
reg [9:0]  x1_y_walker, x2_y_walker;  
reg [19:0] addr_reg; // Memory address register for SRAM
reg [15:0] data_reg; // Memory data register  for SRAM
reg [3:0]  state;	 // State machine
reg 	   lock;	 // lock VGA during refresh
reg 	   done;	 // Go through the FSM 1 time per refresh
reg [10:0] done_cnt; // Go through the FSM 1 time per refresh
wire 	   we;		 // Write enable for SRAM
wire signed [9:0] x1_reajusted;
wire signed [9:0] x2_reajusted;
// Debug state register access
assign stateST = state;

// SRAM_control
assign SRAM_ADDR = addr_reg; 
assign SRAM_DQ = (we)? 16'hzzzz : data_reg;
assign SRAM_UB_N = 0;  // Hi byte select enabled
assign SRAM_LB_N = 0;  // Lo byte select enabled
assign SRAM_CE_N = 0;  // Chip is enabled
assign SRAM_WE_N = we; // Write when ZERO
assign SRAM_OE_N = 0;  // Output enable is overidden by WE

// Show SRAM on the VGA
assign  pixel_Red   = {SRAM_DQ[15:12], 6'b0};
assign  pixel_Green = {SRAM_DQ[11:8] , 6'b0};
assign  pixel_Blue  = {SRAM_DQ[7:4]  , 6'b0};

// DLA state machine
assign LEDG = 7'b0;
assign LEDR = 18'b0;
assign dbg_val = 32'b0;

assign x1_reajusted = ({x1_resized[9], x1_resized[9:1]}) + 10'd240;
assign x2_reajusted = ({x2_resized[9], x2_resized[9:1]}) + 10'd240;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// 							    								  			 //
// 							   		FSM 								     //
// 							    								  			 //
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
always @ (posedge VGA_CTRL_CLK)
begin
	// Active low reset, condition is true when key0 is pushed
	if (!reset_n) // Synch reset assumes KEY0 is held down 1/60 second
	begin
		// Clear the screen
		addr_reg     <= {washer[19:0]};	// [19:0] 20 bits
		we           <= 1'b0; 			// Write some memory
		data_reg     <= 16'b0;			// Write blk
		// Init a randwalker to just left of center
		x_walker     <= 10'd0;
		x_cln_walker <= 10'd1;
		x1_y_walker  <= 10'd0;
		x2_y_walker  <= 10'd0;
		// x1_y_walker <= x1_resized;
		// x2_y_walker <= x2_resized;
		state        <= ST_wait; // First state in regular state machine 
		done         <= 1'b0;
		done_cnt	 <= 11'b0;

		if (washer < 21'b1_0000_0000_0000_0000_0000) washer = washer + 21'b1;
		else							 			 washer = 0;

	end
	
	// Modify display during sync
	else if (~VGA_VS | ~VGA_HS)  // Sync is active low;
	begin
		case(state)
			
			////////////////////////////////////////////////////////////////////
			ST_reset: begin
				state        <= ST_clear_display;
				x_cln_walker <= 10'd0;				
				y_cln_walker <= 10'd0;
				we           <= 1'b0; // NOT write 	
			end

			////////////////////////////////////////////////////////////////////
			ST_clear_display: begin
				addr_reg <= {x_cln_walker, y_cln_walker};
				if (y_cln_walker >= Y_MAX - 10'b1) begin
					if (x_walker >= X_MAX - 10'b1) begin
						state <= ST_wait;
					end
					else begin 
						x_walker <= x_walker + 10'd1;
						y_cln_walker <= 10'd0;
					end
				end
				else begin
					y_cln_walker <= y_cln_walker + 10'd1;
				end
				data_reg <= 16'b0; // Black
				we       <= 1'b0;  // Write	
			end

			////////////////////////////////////////////////////////////////////
			ST_wait: begin // Write a single dot in the middle of the screen
				if (!done) begin
					state <= ST_pre_clean_1;
					x_walker <= (x_walker >= X_MAX - 10'b1) ? 10'd0 : (x_walker + 10'd1);
					x1_y_walker <= x1_reajusted;
					x2_y_walker <= x2_reajusted;
				end
			end

			////////////////////////////////////////////////////////////////////
			ST_pre_clean_1: begin
				state        <= ST_pre_clean_2;
				lock         <= 1'b1;
				done         <= 1'b1;
				x_cln_walker <= x_walker;
				y_cln_walker <= 10'd0;
				we           <= 1'b1; // NOT write 								
			end

			////////////////////////////////////////////////////////////////////
			ST_pre_clean_2: begin
				if (y_cln_walker >= Y_MAX - 10'b1) begin
					state        <= ST_draw_x1;
				end
				else begin
					y_cln_walker <= y_cln_walker + 10'd1;
				end
				addr_reg <= {x_cln_walker, y_cln_walker};
				data_reg <= 16'b0; // Black
				we       <= 1'b0;  // Write
			end

			////////////////////////////////////////////////////////////////////
			ST_pre_clean_2: begin
				if (y_cln_walker >= Y_MAX - 10'b1) begin
					state        <= ST_pause_0;
				end
				else begin
					y_cln_walker <= y_cln_walker + 10'd1;
				end
				addr_reg <= {x_cln_walker, y_cln_walker};
				data_reg <= 16'b0; // Black
				we       <= 1'b0;  // Write
			end

			////////////////////////////////////////////////////////////////////
			ST_pause_0: begin
				state    <= ST_draw_x1;
				addr_reg <= {x_walker, x1_y_walker};
				we       <= 1'b1; 		// Write								
				data_reg <= 16'h07E0;	// Green
			end

			////////////////////////////////////////////////////////////////////
			ST_draw_x1: begin // Write a white dot at the x1 position 
				state    <= ST_pause_1;
				addr_reg <= {x_walker, x1_y_walker};
				we       <= 1'b0; 		// Write								
				data_reg <= 16'h07E0;	// Green
			end		

			////////////////////////////////////////////////////////////////////
			ST_pause_1: begin
				state    <= ST_draw_x2;
				addr_reg <= {x_walker, x2_y_walker};
				we       <= 1'b1; 		// Write								
				data_reg <= 16'hF800; 	// red
			end

			////////////////////////////////////////////////////////////////////
			ST_draw_x2: begin // Write a white dot at the x2 position
				state    <= ST_end;
				addr_reg <= {x_walker, x2_y_walker};
				we       <= 1'b0; 		// Write								
				data_reg <= 16'hF800; 	// red
			end		

			////////////////////////////////////////////////////////////////////
			ST_end: begin
				if (!lock) begin
					state <= ST_pre_clean_1;
				end
				else begin 		
					state 	 <= ST_wait;
					
				end
				we    <= 1'b1; // NOT write								
			end

			////////////////////////////////////////////////////////////////////
			default: begin
				state <= ST_wait;
				we    <= 1'b1; // NOT write								
			end

		endcase
	end
	
	// Show display when not blanking, 
	// Which implies we=1 (not enabled); and use VGA module address
	else
	begin
		if ( (!current_X) && (!current_Y) ) begin
			done_cnt <= done_cnt + 11'b1;
			if (!done_cnt) begin
				done <= 1'b0;
			end
		end 
		lock     <= 1'b0;
		we       <= 1'b1; // NOT write
		addr_reg <= { current_X[9:0], current_Y[9:0] };
	end
end

endmodule // Top module