module mesh (
		// inputs
	input clk, reset_n,
	input [17:0] start,
	input [17:0] stimu,
	//input [17:0] rho, //p
	// outputs
	output [17:0] mesh_out
	);
	parameter N_SIZE = 5;

	wire [17:0] u_out [N_SIZE-1:0] [N_SIZE-1:0];
	// wire [17:0] stimu [N_SIZE:0] [N_SIZE:0];

	assign mesh_out = u_out [(N_SIZE/2)+1][(N_SIZE/2)+1];

	genvar i;
	genvar j;

	generate

	for(i=0; i<N_SIZE; i=i+1) begin: snode_i
		for(j=0; j<N_SIZE; j=j+1) begin: snode_j

			// boundaries UP RIGHT DOWN LEFT
			if ((i==0) || (j==0) || (i==N_SIZE-1) || (j==N_SIZE-1)) begin
				assign u_out[i][j] = 18'b0;
			end

			else if (( i == ((N_SIZE/2)+1) ) && ( j == ((N_SIZE/2)+1) ) ) begin
				assign mesh_out = u_out [i][j];

				// adder_node sound_node_i(
				sound_node sound_node_i(
					.clk         (clk),
					.reset_n     (reset_n),
					.stimu       (stimu),
					.start       (start),
					.u_in_top    (u_out [i+1] [j]),
					.u_in_right  (u_out [i]   [j+1]),
					.u_in_bottom (u_out [i-1] [j]),
					.u_in_left   (u_out [i]   [j-1]),
					.u_out		 (u_out [i]   [j])
				);
			end

			else begin
				// adder_node sound_node_i(
				sound_node sound_node_i(
					.clk         (clk),
					.reset_n     (reset_n),
					.stimu       (18'b0),
					.start       (start),
					.u_in_top    (u_out [i+1] [j]),
					.u_in_right  (u_out [i]   [j+1]),
					.u_in_bottom (u_out [i-1] [j]),
					.u_in_left   (u_out [i]   [j-1]),
					.u_out		 (u_out [i]   [j])
				);
			end

		end
	end

	endgenerate

endmodule 