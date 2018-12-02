module Fractal_control (
	// common   
	input             clock,
	input             reset_n,
	input             start,
	input             data_out_read,
	output  [9:0]     x_coord_out,
	output  [9:0]     y_coord_out,
	output  [10:0]    interation_count,
	output            is_in_the_set,
	output            data_out_available
);

	// screen resolution parameters
	parameter X_RESO          = 10'd80;
	parameter Y_RESO          = 10'd80;
	// sending FSM state parameters
	parameter ST_RESET        = 4'd0;
	parameter ST_IDLE         = 4'd1;
	parameter ST_DIV          = 4'd2;
	parameter ST_SEND_DATA    = 4'd3;
	parameter ST_UPDATE_COORD = 4'd4;
	parameter ST_END_COMPUTE  = 4'd5;
	// Adder Subber select parameters
	parameter ADDER           = 1'b1;
	parameter SUBBER          = 1'b0;
	// Divider Coordinate select parameters
	parameter RE_COORD        = 1'b1;
	parameter IM_COORD        = 1'b0;

	/*88888b.  8888888888  .d8888b.  888             d8888 
	888  "Y88b 888        d88P  Y88b 888            d88888 
	888    888 888        888    888 888           d88P888 
	888    888 8888888    888        888          d88P 888 
	888    888 888        888        888         d88P  888 
	888    888 888        888    888 888        d88P   888 
	888  .d88P 888        Y88b  d88P 888       d8888888888 
	8888888P"  8888888888  "Y8888P"  88888888 d88P     8*/

	// input side of the fractal accelerator

	reg [9:0]   y_coord_in;
	reg [9:0]   x_coord_in;
	reg         data_in_write;
	wire        data_in_full;
	// output side of the fractal accelerator
	reg [3:0]	next_state;  
	reg [31:0]	re_part_in;     
	reg [31:0]	re_part_in_start;     
	reg [31:0]	im_part_in;
	reg [31:0]	re_delta;          
	reg [31:0]	im_delta;       


	/*8b     d888  .d88888b.  8888888b.  888     888 888      8888888888 
	8888b   d8888 d88P" "Y88b 888  "Y88b 888     888 888      888        
	88888b.d88888 888     888 888    888 888     888 888      888        
	888Y88888P888 888     888 888    888 888     888 888      8888888    
	888 Y888P 888 888     888 888    888 888     888 888      888        
	888  Y8P  888 888     888 888    888 888     888 888      888        
	888   "   888 Y88b. .d88P 888  .d88P Y88b. .d88P 888      888        
	888       888  "Y88888P"  8888888P"   "Y88888P"  88888888 88888888*/

	fractal_accelerator fractal_accelerator_i (
		.clock              (clock),
		.reset_n            (reset_n),
		.real_part_in       (re_part_in),
		.imaginary_part_in  (im_part_in),
		.y_coord_in         (y_coord_in),
		.x_coord_in         (x_coord_in),
		.data_in_write      (data_in_write),
		.data_in_full       (data_in_full),
		.x_coord_out        (x_coord_out),
		.y_coord_out        (y_coord_out),
		.interation_count   (interation_count),
		.is_in_the_set      (is_in_the_set),
		.data_out_read      (data_out_read),
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


	////////////////////////////////////////////////////////
	// NO combinationnal / sequential logic separation
	////////////////////////////////////////////////////////
	// FSM State register
	always @(posedge clock or negedge reset_n) begin
		if (!reset_n) begin
			next_state   <= ST_RESET;
			re_part_in   <= 32'd0;
			im_part_in   <= 32'd0;
			re_delta     <= 32'd0;
			im_delta     <= 32'd0;
			x_coord_in   <= 10'd0;
			y_coord_in   <= 10'd0;
	    end
		else begin

			case(next_state)

				ST_RESET: begin  
					next_state <= ST_IDLE;
				end

				ST_IDLE: begin 
					if (start) begin
						next_state   <= ST_DIV;
						re_part_in   <= 32'd0;
						im_part_in   <= 32'd0;
						re_delta     <= 32'd0;
						im_delta     <= 32'd0;
						x_coord_in   <= 10'd0;
						y_coord_in   <= 10'd0;
					end
				end

				ST_DIV: begin
					next_state       <= ST_SEND_DATA;
					re_part_in       <= 32'hE_0000000; // -2;
					re_part_in_start <= 32'hE_0000000; // -2;
					re_delta         <= 32'h0_0CCCCCC; // 0.2/4
					im_part_in       <= 32'hF_0000000; // -1
					im_delta         <= 32'h0_0666666; // 0.1/4
				end 

				ST_SEND_DATA: begin
					if (!data_in_full) begin
						next_state    <= ST_UPDATE_COORD;
						data_in_write <= 1'b1;
					end
					else begin
						data_in_write <= 1'b0;
					end
				end 

				ST_UPDATE_COORD: begin
					if (x_coord_in < (X_RESO - 10'd1)) begin
						next_state <= ST_SEND_DATA;
						re_part_in <= re_part_in + re_delta;
						x_coord_in <= x_coord_in + 10'd1;
					end
					else begin
						if (y_coord_in == (Y_RESO - 10'd1)) begin
							next_state <= ST_END_COMPUTE;
						end
						else begin
							next_state <= ST_SEND_DATA;
							x_coord_in <= 10'd0;
							y_coord_in <= y_coord_in + 10'd1;
							re_part_in <= re_part_in_start;
							im_part_in <= im_part_in + im_delta;
						end
					end
					data_in_write <= 1'b0;
				end 

				// description state ST_END_COMPUTE
				ST_END_COMPUTE: begin
					next_state <= ST_IDLE;
				end 

				// description default
				default : begin
					next_state <= ST_RESET;
				end

			endcase
		end
	end	


endmodule