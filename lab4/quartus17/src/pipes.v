module pipes (
	// common
	input 			clock,
	input 			reset_n,
	// input side of the pipes
	input [79:0] 	data_in,
	input 			data_in_available,
	input 			space_ahead,
	output 	reg		data_in_read,
	// output side of the pipes
	output  [31:0] 	 data_out,
	output 	reg    	 write_out
);

	// FSM 1 State parameters
	parameter ST_1_RESET      = 4'd0;
	parameter ST_1_IDLE       = 4'd1;
	parameter ST_1_BEGIN_LOAD = 4'd2;
	parameter ST_1_END_LOAD   = 4'd3;
	parameter ST_1_NEXT_NODE  = 4'd4;
	// FSM 2 State parameters
	parameter ST_2_RESET		   = 4'd0;
	parameter ST_2_CHECK_FIFO_FILL = 4'd1;
	parameter ST_2_READ_WRITE      = 4'd2;
	parameter ST_2_END_WRITE       = 4'd3;
	// Amount of pipes
	parameter PIPE_SIZE 		   = 1;
	parameter PIPE_SELECT_WIDTH	   = 5;


	/*88888b.  8888888888  .d8888b.  888             d8888 
	888  "Y88b 888        d88P  Y88b 888            d88888 
	888    888 888        888    888 888           d88P888 
	888    888 8888888    888        888          d88P 888 
	888    888 888        888        888         d88P  888 
	888    888 888        888    888 888        d88P   888 
	888  .d88P 888        Y88b  d88P 888       d8888888888 
	8888888P"  8888888888  "Y8888P"  88888888 d88P     8*/

	// FSM register Load
 	reg [3:0]   next_state_1_load;
 	// FSM registers Unload
 	reg [3:0]   next_state_2_unload;
 	reg [4:0]   read_count;
 	// generate wires divergence
	wire [PIPE_SIZE-1 : 0]  node_start;
	wire [PIPE_SIZE-1 : 0]  node_busy;
	wire [PIPE_SIZE-1 : 0]  node_write_out;
	wire [79:0]             node_data_in;
	wire [31:0]             node_data_out [PIPE_SIZE-1 : 0];
 	// generate wires fifo
	wire [PIPE_SIZE-1 : 0]  fifo_node_rdreq;
	wire [PIPE_SIZE-1 : 0]  fifo_node_almost_full;
	wire [PIPE_SIZE-1 : 0]  fifo_node_empty;
	wire [PIPE_SIZE-1 : 0]  fifo_node_full;
	wire [31:0]             fifo_node_data_out_array [PIPE_SIZE-1 : 0];
	wire [4:0]              fifo_node_usedw_array    [PIPE_SIZE-1 : 0];
	wire [PIPE_SIZE*32-1:0] fifo_node_data_out_flat;
	wire [PIPE_SIZE*5-1:0]  fifo_node_usedw_flat;
	// parametrized muxes
	wire [4:0]                 mux_usedw_out;
	wire [31:0]                mux_data_out;
	reg  [PIPE_SELECT_WIDTH-1:0] fifo_select;
	reg  [PIPE_SELECT_WIDTH-1:0] node_select;
	wire                       almost_full_select;
	reg                        rdreq_select;
	reg                        start_select;
	wire                       busy_select;

	       /*888  .d8888b.   .d8888b. 8888888  .d8888b.  888b    888 
	      d88888 d88P  Y88b d88P  Y88b  888   d88P  Y88b 8888b   888 
	     d88P888 Y88b.      Y88b.       888   888    888 88888b  888 
	    d88P 888  "Y888b.    "Y888b.    888   888        888Y88b 888 
	   d88P  888     "Y88b.     "Y88b.  888   888  88888 888 Y88b888 
	  d88P   888       "888       "888  888   888    888 888  Y88888 
	 d8888888888 Y88b  d88P Y88b  d88P  888   Y88b  d88P 888   Y8888 
	d88P     888  "Y8888P"   "Y8888P" 8888888  "Y8888P88 888    Y8*/

	assign data_out = mux_data_out;

	assign busy_select        = |{node_busy 			[PIPE_SIZE-1:0] & (1 << node_select)};
	assign almost_full_select = |{fifo_node_almost_full [PIPE_SIZE-1:0] & (1 << node_select)};

	assign node_start	  [PIPE_SIZE-1:0] = {PIPE_SIZE{start_select}} & (1 << node_select);
	// assign node_start	  [PIPE_SIZE-1:0] = start_select & (1 << node_select);
	assign fifo_node_rdreq[PIPE_SIZE-1:0] = {PIPE_SIZE{rdreq_select}} & (1 << fifo_select);

	assign node_data_in = data_in;


	/*8b     d888  .d88888b.  8888888b.  888     888 888      8888888888 
	8888b   d8888 d88P" "Y88b 888  "Y88b 888     888 888      888        
	88888b.d88888 888     888 888    888 888     888 888      888        
	888Y88888P888 888     888 888    888 888     888 888      8888888    
	888 Y888P 888 888     888 888    888 888     888 888      888        
	888  Y8P  888 888     888 888    888 888     888 888      888        
	888   "   888 Y88b. .d88P 888  .d88P Y88b. .d88P 888      888        
	888       888  "Y88888P"  8888888P"   "Y88888P"  88888888 88888888*/

	para_mux para_mux_data_i (
		.select   (fifo_select),
		.data_in  (fifo_node_data_out_flat),
		.data_out (mux_data_out)
		);
		defparam para_mux_data_i.WIDTH        = 32;
		defparam para_mux_data_i.DEPTH        = PIPE_SIZE;
		defparam para_mux_data_i.SELECT_WIDTH = PIPE_SELECT_WIDTH;

	para_mux para_mux_usedw_i (
		.select   (fifo_select),
		.data_in  (fifo_node_usedw_flat),
		.data_out (mux_usedw_out)
		);
		defparam para_mux_usedw_i.WIDTH        = 5;
		defparam para_mux_usedw_i.DEPTH        = PIPE_SIZE;
		defparam para_mux_usedw_i.SELECT_WIDTH = PIPE_SELECT_WIDTH;


	 /*8888b.  8888888888 888b    888 8888888888 8888888b.      
	d88P  Y88b 888        8888b   888 888        888   Y88b   
	888    888 888        88888b  888 888        888    888   
	888        8888888    888Y88b 888 8888888    888   d88P   
	888  88888 888        888 Y88b888 888        8888888P"    
	888    888 888        888  Y88888 888        888 T88b     
	Y88b  d88P 888        888   Y8888 888        888  T88b    
	 "Y8888P88 8888888888 888    Y888 8888888888 888   T8*/

	genvar i;
	generate
		for(i=0; i<PIPE_SIZE; i=i+1) begin: gen_node

			divergence_node divergence_node_i (
			 	.clock        (clock),
				.reset_n      (reset_n),
				.data_in 	  (node_data_in[79:0]),
				// .data_in 	  (80'b0),
				.start        (node_start     [i]),
				.busy         (node_busy      [i]),
				.write_out    (node_write_out [i]),
				.data_out 	  (node_data_out  [i])
			);

			fifo_node fifo_node_i (
				.clock       (clock),
				.data        (node_data_out            [i]),
				.rdreq       (fifo_node_rdreq          [i]),
				.wrreq       (node_write_out           [i]),
				.almost_full (fifo_node_almost_full    [i]),
				.empty       (fifo_node_empty          [i]),
				.full        (fifo_node_full           [i]),
				.q           (fifo_node_data_out_array [i]),
				.usedw       (fifo_node_usedw_array    [i])
			);

			assign fifo_node_data_out_flat [ (32*(i+1)) -1 : 32*i ] = fifo_node_data_out_array [i];
			assign fifo_node_usedw_flat	   [ ( 5*(i+1)) -1 :  5*i ] = fifo_node_usedw_array    [i];

		end
	endgenerate


	/*88888888  .d8888b.  888b     d888     d888   
	888        d88P  Y88b 8888b   d8888    d8888   
	888        Y88b.      88888b.d88888      888   
	8888888     "Y888b.   888Y88888P888      888   
	888            "Y88b. 888 Y888P 888      888   
	888              "888 888  Y8P  888      888   
	888        Y88b  d88P 888   "   888      888   
	888         "Y8888P"  888       888    88888*/

	// FSM to load Data into the pipe
	always @(posedge clock or negedge reset_n) begin

		// reset all registers to 0	
		if (!reset_n) begin
			next_state_1_load <= ST_1_RESET;
			data_in_read      <= 1'b0;
			start_select      <= 1'b0;
			node_select       <= 4'b0;
	    end

		else begin
			case(next_state_1_load)

				// reset all regs to 0
				ST_1_RESET: begin  
					next_state_1_load <= ST_1_IDLE;
				end

				// wait we have valid data and place to store them ahead
				ST_1_IDLE: begin 
					if (data_in_available && space_ahead) begin
						next_state_1_load <= ST_1_BEGIN_LOAD;
						data_in_read      <= 1'b1;
					end
				end

				// work on the data and send it to the out fifo
				ST_1_BEGIN_LOAD: begin  
					data_in_read      <= 1'b0;

					if ((!busy_select) && (!almost_full_select)) begin
						next_state_1_load <= ST_1_END_LOAD;
						start_select      <= 1'b1;
					end

					else begin
						next_state_1_load <= ST_1_NEXT_NODE;
						start_select      <= 1'b0;
					end
				end 

				// select next node to later on read and other value for the in_fifo
				ST_1_END_LOAD: begin  
					next_state_1_load <= ST_1_IDLE;
					node_select       <= (node_select < PIPE_SIZE -1) ? (node_select + 4'b1) : 4'b0;
					start_select      <= 1'b0;
				end 
				
				// select next node to see if this one is not busy
				ST_1_NEXT_NODE: begin  
					// next_state_1_load <= ST_1_BEGIN_LOAD;
					node_select       <= (node_select < PIPE_SIZE -1) ? (node_select + 4'b1) : 4'b0;
					start_select      <= 1'b0;
					// if (|{node_data_in})
						next_state_1_load <= ST_1_BEGIN_LOAD;
				end 

				// go back to reset state
				default : begin
					next_state_1_load <= ST_1_RESET;
				end

			endcase
		end
	end	


	/*88888888  .d8888b.  888b     d888     .d8888b.  
	888        d88P  Y88b 8888b   d8888    d88P  Y88b 
	888        Y88b.      88888b.d88888           888 
	8888888     "Y888b.   888Y88888P888         .d88P 
	888            "Y88b. 888 Y888P 888     .od888P"  
	888              "888 888  Y8P  888    d88P"      
	888        Y88b  d88P 888   "   888    888"       
	888         "Y8888P"  888       888    8888888*/

	// FSM to Merge the node fifo's into one
	always @(posedge clock or negedge reset_n) begin

		// reset all registers to 0	
		if (!reset_n) begin
			next_state_2_unload <= ST_2_RESET;
			read_count        <= 5'b0;
			write_out         <= 1'b0;
			rdreq_select   	  <= 1'b0;
			fifo_select		  <= 4'b0;
	    end

		else begin
			case(next_state_2_unload)

				// reset all regs to 0
				ST_2_RESET: begin  
					next_state_2_unload <= ST_2_CHECK_FIFO_FILL;
				end

				ST_2_CHECK_FIFO_FILL: begin 
					if (mux_usedw_out) begin
						next_state_2_unload <= ST_2_READ_WRITE;
						read_count          <= mux_usedw_out - 5'b1;
						write_out           <= 1'b0;
						rdreq_select        <= 1'b1;
					end 
					else begin
						write_out    <= 1'b0;
						rdreq_select <= 1'b0;
						fifo_select  <= (fifo_select < PIPE_SIZE-1) ? (fifo_select + 4'b1) : 4'b0;
					end
				end

				//
				ST_2_READ_WRITE: begin  
					if (read_count) begin
						write_out    <= 1'b1;
						rdreq_select <= 1'b1;
						read_count   <= read_count - 5'b1;
					end
					else begin
						next_state_2_unload <= ST_2_END_WRITE;
						write_out           <= 1'b1;
						rdreq_select        <= 1'b0;
					end
				end 

				//
				ST_2_END_WRITE: begin  
					fifo_select         <= (fifo_select < PIPE_SIZE-1) ? (fifo_select + 4'b1) : 4'b0;
					next_state_2_unload <= ST_2_CHECK_FIFO_FILL;
					write_out           <= 1'b0;
				end 

				default : begin
					next_state_2_unload <= ST_2_RESET;
				end

			endcase
		end
	end	

endmodule