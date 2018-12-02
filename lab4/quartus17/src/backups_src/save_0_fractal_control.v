module Fractal_control (
	// common   
	input             clock,
	input             reset_n,
	input   [31:0]    re_center,
	input   [31:0]    im_center,
	input   [31:0]    re_width,
	input   [31:0]    im_width,
	input             start,
	input             data_out_read,
	output  [9:0]     x_coord_out,
	output  [9:0]     y_coord_out,
	output  [10:0]    interation_count,
	output            is_in_the_set,
	output            data_out_available,
	output reg [31:0] tick_counter
);

	// screen resolution parameters
	parameter X_RESO          = 10'd20;
	parameter Y_RESO          = 10'd20;
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
	reg [31:0]	re_center_r; 	 
	reg [31:0]	im_center_r; 	 
	reg [31:0]	re_width_r;       
	reg [31:0]	im_width_r;       
	reg [31:0]	re_part_in;     
	reg [31:0]	re_part_in_start;     
	reg [31:0]	im_part_in;
	reg [31:0]	im_part_in_start;
	reg [4:0]	div_counter;      
	reg 		div_mode;         
	reg [31:0]	re_delta;          
	reg [31:0]	im_delta;          
	// Adder
	reg 		add_sub_mode;     
	reg [31:0]	add_sub_a;        
	reg [31:0]	add_sub_b;     
	wire 		add_sub_overfl;
	wire [31:0]	add_sub_out;   
	// Divider
	reg [31:0]  denom;
	reg [31:0]  numer;
	wire [31:0] quotient;
	wire [31:0] remain;

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


	Div div_i (
		.clock    (clock),
		.denom    (denom),
		.numer    (numer),
		.quotient (quotient),
		.remain   (remain)
	);


	Add_Sub add_sub_i (
		.add_sub  (add_sub_mode),
		.clock	  (clock), 
		.dataa	  (add_sub_a), 
		.datab	  (add_sub_b), // Constant C_im
		.overflow (add_sub_overfl), 
		.result	  (add_sub_out)
	);


		   /*888 888      888       888        d8888 Y88b   d88P  .d8888b.  
	      d88888 888      888   o   888       d88888  Y88b d88P  d88P  Y88b 
	     d88P888 888      888  d8b  888      d88P888   Y88o88P   Y88b.      
	    d88P 888 888      888 d888b 888     d88P 888    Y888P     "Y888b.   
	   d88P  888 888      888d88888b888    d88P  888     888         "Y88b. 
	  d88P   888 888      88888P Y88888   d88P   888     888           "888 
	 d8888888888 888      8888P   Y8888  d8888888888     888     Y88b  d88P 
	d88P     888 88888888 888P     Y888 d88P     888     888      "Y8888*/

	always @(posedge clock or negedge reset_n) begin
		if (!reset_n) begin
			tick_counter <= 32'b0;
		end
		else begin
			if (start) tick_counter <= 32'b0;
			else 	   tick_counter <= tick_counter + 32'b1;
		end
	end


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
			re_center_r  <= 32'd0;
			im_center_r  <= 32'd0;
			re_width_r   <= 32'd0;
			im_width_r   <= 32'd0;
			re_part_in   <= 32'd0;
			im_part_in   <= 32'd0;
			div_counter  <= 4'd0;
			div_mode     <= RE_COORD;
			re_delta     <= 32'd0;
			im_delta     <= 32'd0;
			numer        <= 32'd0;
			denom	     <= 32'd0;
			add_sub_mode <= SUBBER;
			add_sub_a    <= 32'd0;
			add_sub_b    <= 32'd0;
			x_coord_in   <= 10'd0;
			y_coord_in   <= 10'd0;
	    end
		else begin

			case(next_state)

				// description state ST_RESET
				ST_RESET: begin  
					next_state <= ST_IDLE;
				end

				// description state ST_IDLE
				ST_IDLE: begin 
					if (start) begin
						next_state   <= ST_DIV;
						re_center_r  <= re_center;
						im_center_r  <= im_center;
						re_width_r   <= re_width;
						im_width_r   <= im_width;
						re_part_in   <= 32'd0;
						im_part_in   <= 32'd0;
						div_counter  <= 4'd5;
						div_mode     <= RE_COORD;
						re_delta     <= 32'd0;
						im_delta     <= 32'd0;
						numer        <= re_width_r;
						denom	     <= X_RESO;
						add_sub_mode <= SUBBER;
						add_sub_a    <= re_center_r; 
						add_sub_b    <= re_width_r >> 1;
						x_coord_in   <= 10'd0;
						y_coord_in   <= 10'd0;
					end
				end

				// // description state ST_DIV
				// ST_DIV: begin
				// 	// if (div_counter) begin
					// 	div_counter <= div_counter - 5'd1;
					// end
					// else begin 
					// 	if (div_mode == RE_COORD) begin
					// 		// divider
					// 		re_delta         <= quotient;
					// 		numer            <= im_width_r;
					// 		denom	     	 <= Y_RESO;
					// 		div_mode         <= IM_COORD;
					// 		div_counter      <= 4'd5;
					// 		// adsub
					// 		re_part_in       <= add_sub_out;
					// 		re_part_in_start <= add_sub_out;
					// 		add_sub_a        <= im_center_r; 
					// 		add_sub_b        <= im_width_r >> 1;
					// 	end
					// 	else begin
					// 		next_state   <= ST_SEND_DATA;
					// 		// im_delta     <= quotient;
					// 		// im_part_in   <= add_sub_out;
							
					// 		// re_part_in       <= 32'b0 - (re_width_r >> 1);
					// 		// im_part_in       <= 32'b0 - (im_width_r >> 1);
					// 		re_part_in       <= 32'hE_000_0000; // -2;
					// 		re_part_in_start <= 32'hE_000_0000; // -2;
					// 		re_delta         <= 32'h0_333_3333; // 0.
					// 		im_part_in       <= 32'hF_000_0000;
					// 		im_delta         <= 32'h0_199_999A; // 0.333

					// 		add_sub_mode <= ADDER;
					// 	end
					// end

				ST_DIV: begin
					
					// DEBUG values
					next_state       <= ST_SEND_DATA;
					re_part_in       <= 32'hE_0000000; // -2;
					re_part_in_start <= 32'hE_0000000;  // -2;
					re_delta         <= 32'h0_3333333;  // 0.2
					im_part_in       <= 32'hF_0000000;  // -1
					im_delta         <= 32'h0_199999A;  // 0.1
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
					if (x_coord_in < X_RESO - 10'd1) begin
						next_state <= ST_SEND_DATA;
						re_part_in <= re_part_in + re_delta;
						x_coord_in <= x_coord_in + 10'd1;
					end
					else begin
						if (y_coord_in == Y_RESO - 10'd1) begin
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