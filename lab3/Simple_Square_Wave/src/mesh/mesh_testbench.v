`timescale 1ns /100ps

module mesh_testbench ();

	reg clk, reset_n, start;
	reg  [17:0] stimu;
	wire [17:0] u_in_left;
	wire [17:0] u_in_right;
	wire [17:0] u_in_bottom;
	wire [17:0] u_in_top;
	wire [17:0] node_out;
	wire [17:0] mesh_out;


	///////////////////////////////////////////////////////
	// NODE
	///////////////////////////////////////////////////////

	sound_node sound_node_i_0 (
	.clk         (clk),
	.reset_n     (reset_n),
	.start       (start),
	.stimu       (stimu),
	.u_in_left   (u_in_left),
	.u_in_right  (u_in_right),
	.u_in_bottom (u_in_bottom),
	.u_in_top    (u_in_top),
	.u_out		 (node_out)
	);
	assign u_in_top    = 18'b0;
	assign u_in_bottom = 18'b0;
	assign u_in_right  = 18'b0;
	assign u_in_left   = 18'b0;



	///////////////////////////////////////////////////////
	// MESH
	///////////////////////////////////////////////////////
	mesh mesh_i_0 (
	.clk         (clk),
	.reset_n     (reset_n),
	.start       (start),
	.stimu       (stimu),
	.mesh_out	 (mesh_out)
	);
	defparam mesh_i_0.N_SIZE = 8;

	// fixed point calculator 
	//http://www.rfwireless-world.com/calculators/floating-vs-fixed-point-converter.html

	always begin
		clk = 1; #5; clk = 0; #5;
	end

	// always begin
	// 	start = 1; #10; start = 0; #10;
	// end

	initial begin
		clk          = 0;
		reset_n      = 0;
		stimu        = 18'h0_3D00; //max 18'h0_3D00
		start        = 1;
		#5; reset_n  = 1;
		#30; stimu   = 18'h0; 
		// #4500; stimu = 18'h0_199A; 
		#60; stimu   = 18'h0;
	end

endmodule