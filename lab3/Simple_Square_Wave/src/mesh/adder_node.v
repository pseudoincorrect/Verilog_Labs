module adder_node (
	// inputs
	input clk, reset_n,
	input [17:0] start,
	input [17:0] stimu,
	input [17:0] u_in_left,
	input [17:0] u_in_right,
	input [17:0] u_in_bottom,
	input [17:0] u_in_top,
	//input [17:0] rho, //p
	// outputs
	output reg [17:0] u_out
	);


	always @ (posedge clk or negedge reset_n) 
	begin
		if (!reset_n) begin
			u_out = 18'b0; 
		end
		else begin
			if (stimu)
				u_out = u_out + u_in_left + u_in_right + u_in_bottom + u_in_top + 18'b1;
			else 
				u_out = u_out + u_in_left + u_in_right + u_in_bottom + u_in_top;
		end
	end	
endmodule


