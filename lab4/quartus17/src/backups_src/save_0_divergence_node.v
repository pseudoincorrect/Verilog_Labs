///////////////////////////////////////////////////////////////////
//	ONGOING WORK ON THAT FILE :
//
//  
//
//
///////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

// `include "lpm"

module divergence_node (
	input 			clk,
	input 			reset,
	input 			start,
	input  [31:0]	im_start_sys,
	input  [31:0]	re_start_sys,
	output [11:0] 	iterations,
	output reg		done
	);

parameter ADD_PIPEL_SIZE  = 3;
parameter MULT_PIPEL_SIZE = 5;

///////////////////////////////////////////////////////////////////
//	Signals Declaration
///////////////////////////////////////////////////////////////////
// Adder imaginary number
wire signed [63:0]	add_im_in_a;
wire signed [63:0]	add_im_in_b;
wire signed [63:0]	add_im_out;
wire signed [31:0]	add_im_out_trunc;
wire 	 			add_im_overfl;
// Adder real number
wire signed [63:0] 	add_re_in_a;
wire signed [63:0] 	add_re_in_b;
wire signed [63:0] 	add_re_out;
wire signed [31:0]	add_re_out_trunc;
wire 				add_re_overfl;
// Adder comparator
wire signed [63:0] 	add_comp_in_a;
wire signed [63:0] 	add_comp_in_b;
wire signed [63:0] 	add_comp_out;
wire signed [31:0]	add_comp_out_trunc;
wire 				add_comp_overfl;
// Subber real number
wire signed [63:0] 	sub_re_in_a;
wire signed [63:0] 	sub_re_in_b;
wire signed [63:0] 	sub_re_out;
wire 				sub_re_overfl;
// Multiplier imaginary number
reg  signed [31:0] 	mult_im_in_b_reg;
reg  signed [31:0] 	mult_im_in_a_reg;
wire signed [63:0]	mult_im_out;
wire signed [63:0] 	mult_im_out_shifted;
// Squarer real number (real nb input)
reg  signed [31:0] 	square_re_re_in_a_reg;
wire signed [63:0] 	square_re_re_out;
// Squarer real number (imaginary nb input)
reg  signed [31:0]	square_re_im_in_a_reg;
wire signed [63:0]	square_re_im_out;
// Inital value (constants)
reg  signed [31:0] 	c_re_reg;
reg  signed [31:0] 	c_im_reg;
reg  signed [31:0] 	im_start_sys_reg;
reg  signed [31:0] 	re_start_sys_reg;
// Pipeline registers arrays
reg  signed [31:0] 	c_im_Mq [MULT_PIPEL_SIZE-1 : 0];
reg  signed [31:0] 	c_re_Mq [MULT_PIPEL_SIZE-1 : 0];
reg  signed [63:0] 	square_re_re_out_Aq [ADD_PIPEL_SIZE-1 : 0];
// Counter
reg [11:0] 	count_iterations;
reg 		count_iter_en;
// Input synchronizer
wire 		start_sys;
reg 		r0, r1, r2;
// output divergence
wire 		adder_overflow;
wire 		comparator_4;
reg [11:0]  iterations_reg;

///////////////////////////////////////////////////////////////////
// 	Module Instantiaton
///////////////////////////////////////////////////////////////////
Add_Sub add_im (
	.add_sub  (1'b1),
	.clock	  (clk), 
	.dataa	  (add_im_in_a), 
	.datab	  (add_im_in_b), // Constant C_im
	.overflow (add_im_overfl), 
	.result	  (add_im_out));

Add_Sub add_re (
	.add_sub  (1'b1),
	.clock	  (clk), 
	.dataa	  (add_re_in_a), 
	.datab	  (add_re_in_b), // Constant C_re
	.overflow (add_re_overfl), 
	.result	  (add_re_out));

Add_Sub add_comp (
	.add_sub  (1'b1),
	.clock	  (clk), 
	.dataa	  (add_comp_in_a), 
	.datab	  (add_comp_in_b), // Constant C_re
	.overflow (add_comp_overfl), 
	.result	  (add_comp_out));

Add_Sub sub (
	.add_sub  (1'b0),
	.clock	  (clk), 
	.dataa	  (sub_re_in_a), 
	.datab	  (sub_re_in_b), 
	.overflow (sub_re_overfl), 
	.result	  (sub_re_out));

Mult mult_im (
	.clock	  (clk), 
	.dataa	  (mult_im_in_a_reg), 
	.datab	  (mult_im_in_b_reg), 
	.result	  (mult_im_out));

Mult square_re_re (
	.clock	  (clk), 
	.dataa	  (square_re_re_in_a_reg), 
	.datab	  (square_re_re_in_a_reg), 
	.result	  (square_re_re_out));

Mult square_re_im (
	.clock	  (clk), 
	.dataa	  (square_re_im_in_a_reg), 
	.datab	  (square_re_im_in_a_reg), 
	.result	  (square_re_im_out));


///////////////////////////////////////////////////////////////////
//	Signals Assignements
///////////////////////////////////////////////////////////////////
// Adder Imaginary number
assign add_im_in_a = mult_im_out_shifted;
assign add_im_in_b = {{32{c_im_Mq[MULT_PIPEL_SIZE-1][31]}}, c_im_Mq[MULT_PIPEL_SIZE-1]};
// Adder real number
assign add_re_in_a = sub_re_out;
assign add_re_in_b = square_re_re_out_Aq[ADD_PIPEL_SIZE-1];
// Subber real number
assign sub_re_in_a = square_re_im_out;
assign sub_re_in_b = {{32{c_re_Mq[MULT_PIPEL_SIZE-1][31]}}, c_re_Mq[MULT_PIPEL_SIZE-1]};
// Subber real number
assign add_comp_in_a = square_re_im_out;
assign add_comp_in_b = {{32{c_re_Mq[MULT_PIPEL_SIZE-1][31]}}, c_re_Mq[MULT_PIPEL_SIZE-1]};
// Multiply by two (shift left by one)
assign mult_im_out_shifted = {{mult_im_out[61:0]}, {2'b0}};
// Divergence test
assign adder_overflow      = add_im_overfl || add_re_overfl || sub_re_overfl || add_comp_overfl;
assign comparator_4        = (add_comp_out_trunc >= 32'h4000_0000);
assign iterations          = iterations_reg;

// truncature/shift from 64 bits to 32, fixed points (6/58 to 3/29)
assign add_re_out_trunc   = { add_re_out[63], add_re_out[59:56], add_re_out[55:29] };
assign add_im_out_trunc   = { add_im_out[63], add_im_out[59:56], add_im_out[55:29] };
assign add_comp_out_trunc = { add_comp_out[63], add_comp_out[59:56], add_comp_out[55:29] };

///////////////////////////////////////////////////////////////////
//	Iteration Counter
///////////////////////////////////////////////////////////////////
always @ (posedge clk or negedge reset) begin
	if (!reset) 
		count_iterations <= 12'b0;
	else
		if (done)
			count_iterations <= 12'b0;
		else if (count_iter_en)
			count_iterations <= count_iterations + 12'b1;
		else
			count_iterations <= count_iterations;
end

///////////////////////////////////////////////////////////////////
//	Start Signal Synchronizer
///////////////////////////////////////////////////////////////////
assign start_sys = r1 && (!r2);

always @ (posedge clk or negedge reset) begin
	if (!reset) begin 
		r0 <= 1'b0;
		r1 <= 1'b0;
		r2 <= 1'b0;
	end
	else begin
		r0 <= start;
		r1 <= r0;
		r2 <= r1;
	end
end


///////////////////////////////////////////////////////////////////
// 	Enable Iteration Counter Signal
///////////////////////////////////////////////////////////////////
always @ (posedge clk or negedge reset) begin
	if (!reset) begin 
		count_iter_en  <= 1'b0;
		done           <= 1'b0;
		iterations_reg <= 12'b0;
	end
	else begin
		if (start_sys) begin
			count_iter_en  <= 1'b1;
			done           <= 1'b0;
			iterations_reg <= 12'b0;
		end
		else if (comparator_4) begin
			count_iter_en  <= 1'b0;
			done           <= 1'b1;
			iterations_reg <= count_iterations;
		end
		else if (adder_overflow) begin
			count_iter_en  <= 1'b0;
			done           <= 1'b1;
			iterations_reg <= count_iterations;
		end
		else if (count_iterations == 12'd1024) begin
			count_iter_en  <= 1'b0;
			done           <= 1'b1;
			iterations_reg <= count_iterations;
		end
		else begin
			count_iter_en  <= count_iter_en;
			done           <= 1'b0;
			iterations_reg <= iterations_reg;
		end
	end
end


///////////////////////////////////////////////////////////////////
//	Input Muxes
///////////////////////////////////////////////////////////////////
always @ (posedge clk or negedge reset) begin
	if (!reset) begin
		// Imaginary number
		mult_im_in_a_reg      <= 32'b0;
		mult_im_in_b_reg      <= 32'b0;
		// Square Real number
		square_re_re_in_a_reg <= 32'b0;
		// Square Imaginary number
		square_re_im_in_a_reg <= 32'b0;
		// Constant Real number
		c_re_reg              <= 32'b0;
		// Constant Imaginary number
		c_im_reg              <= 32'b0;
	end
	else begin 
		if (start_sys) begin
			// Imaginary number
			mult_im_in_a_reg      <= 32'b0;
			mult_im_in_b_reg      <= 32'b0;
			// Square Real number
			square_re_re_in_a_reg <= 32'b0;
			// Square Imaginary number
			square_re_im_in_a_reg <= 32'b0;
			// Constant Real number
			c_re_reg              <= re_start_sys_reg;
			// Constant Imaginary number
			c_im_reg              <= im_start_sys_reg;
		end
		else begin
			// Imaginary number
			mult_im_in_a_reg      <= add_re_out_trunc;
			mult_im_in_b_reg      <= add_re_out_trunc;
			// Square Real number
			square_re_re_in_a_reg <= add_re_out_trunc;
			// Square Imaginary numbe
			square_re_im_in_a_reg <= add_im_out_trunc;
			// Constant Real number
			c_re_reg              <= c_re_reg;
			// Constant Imaginary number
			c_im_reg              <= c_im_reg;	
		end
	end
end

///////////////////////////////////////////////////////////////////
//	Input register
///////////////////////////////////////////////////////////////////
always @ (posedge clk or negedge reset) begin
	if (!reset) begin
		// Constant Real number
		re_start_sys_reg <= 32'b0;
		// Constant Imaginary number
		im_start_sys_reg <= 32'b0;
	end
	else begin 
		if (start) begin
			// Constant Real number
			re_start_sys_reg <= re_start_sys;
			// Constant Imaginary number
			im_start_sys_reg <= im_start_sys;
		end
		else begin
			// Constant Real number
			re_start_sys_reg <= re_start_sys_reg;
			// Constant Imaginary number
			im_start_sys_reg <= im_start_sys_reg;	
		end
	end
end



///////////////////////////////////////////////////////////////////
//	Pipeline lines ;; c_im_Mq ;; c_re_Mq ;; square_re_re_out_Aq ;;
///////////////////////////////////////////////////////////////////
genvar i;
generate 

	// Pipeline for c_im_Mq
	for(i=0; i<MULT_PIPEL_SIZE; i=i+1) begin: c_im_Mq_gen		
		always @ (posedge clk or negedge reset) begin
			if (!reset) begin 
				c_im_Mq[i] <= 32'b0;
			end
			else begin
				if (i == 0) 
					c_im_Mq[0] <= c_im_reg;
				else
					c_im_Mq[i] <= c_im_Mq[i-1];
			end
		end
	end

	// Pipeline for c_re_Mq
	for(i=0; i<MULT_PIPEL_SIZE; i=i+1) begin: c_re_Mq_gen 	
		always @ (posedge clk or negedge reset) begin
			if (!reset) begin 
				c_re_Mq[i] <= 32'b0;
			end
			else begin
				if (i == 0)
					c_re_Mq[0] <= c_re_reg;
				else
					c_re_Mq[i] <= c_re_Mq[i-1];
			end
		end
	end

	// Pipeline for square_re_re_out_Aq
	for(i=0; i<ADD_PIPEL_SIZE; i=i+1) begin: square_re_re_out_Aq_gen	
		always @ (posedge clk or negedge reset) begin
			if (!reset) begin 
				square_re_re_out_Aq[i] <= 64'b0;
			end
			else begin
				if (i == 0)
					square_re_re_out_Aq[0] <= square_re_re_in_a_reg;
				else 
					square_re_re_out_Aq[i] <= square_re_re_out_Aq[i-1];
			end
		end
	end

	// Pipeline for count
	for(i=0; i<COUNT_PIPEL_SIZE; i=i+1) begin: count_q_gen	
		always @ (posedge clk or negedge reset) begin
			if (!reset) begin 
				count_q[i] <= 64'b0;
			end
			else begin
				if (i == 0)
					count_q[0] <= count;
				else 
					count_q[i] <= count_q[i-1];
			end
		end
	end

	// Pipeline for comparator
	for(i=0; i<ADD_PIPEL_SIZE; i=i+1) begin: comparator_q_gen	
		always @ (posedge clk or negedge reset) begin
			if (!reset) begin 
				comparator_q[i] <= 64'b0;
			end
			else begin
				if (i == 0)
					comparator_q[0] <= comparator;
				else 
					comparator_q[i] <= comparator_q[i-1];
			end
		end
	end

endgenerate 

endmodule