`timescale 1ns /100ps

module top_dda_testbench ();

	reg clk, reset;
	wire [17:0] x1, v1, x2, v2;

	dda dda_i_0 (clk, reset, x1, v1, x2, v2);

	always begin
		clk = 1; #5; clk = 0; #5;
	end

	initial begin
		clk = 0;
		reset = 0;
		#5; reset = 1;
	end

endmodule