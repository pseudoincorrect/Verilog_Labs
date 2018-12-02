module dda (clk, reset, restart, 
			k1_init, k2_init, km_init,
			x1_init, x2_init,
			v1_init, v2_init, 
			x1_out, x2_out );

	input clk, reset, restart;
	input [17:0] k1_init, k2_init, km_init, 
				 x1_init, x2_init,
				 v1_init, v2_init; 
	output [17:0] x1_out, x2_out;

	parameter 	
				ST_reset          = 2'd0,
				ST_wait_start_low = 2'd1,
				ST_restart        = 2'd2,
				ST_compute        = 2'd3;

	parameter LEFT_WALL  = 18'h3_0000; // -1 
	parameter RIGHT_WALL = 18'h1_0000; // +1
	// parameter K1         = 18'h1_0000; // +1
	// parameter K2         = 18'h1_0000; // +1
	// parameter K_MID      = 18'h1_0000; // +1
	parameter DAMPLING_1 = 18'h0_0280; // +0.1
	parameter DAMPLING_2 = 18'h0_0280; // +0.1
	parameter DT 		 = 18'd9;

	//state variables
	reg	[1:0] state;
	reg  signed [17:0] x1, x2, v1, v2;
	reg  signed [17:0] k1, k2, km;
	// variables/wires needed in the calculus
	wire signed [17:0] v1_new, x1_new, x2_new, v2_new ;
	wire signed [17:0] damp_1, damp_2;
	wire signed [17:0] spring_f_1, spring_f_2, spring_f_midl;
	wire signed [17:0] left_rel_x1, left_rel_x2, rel_x1_x2;
	// the clock divider
	reg [31:0] count;

	// Spring force multiplier
	signed_mult mul_f_1 	(spring_f_1,  	left_rel_x1, k1);
	signed_mult mul_f_2 	(spring_f_2, 	left_rel_x2, k2);
	signed_mult mul_f_midl  (spring_f_midl, rel_x1_x2,   km);
	// Dampling multiplier
	signed_mult mul_damping_1 (damp_1, DAMPLING_1, v1);
	signed_mult mul_damping_2 (damp_2, DAMPLING_2, v2);

	// output assignments
	assign x1_out = x1;
	assign x2_out = x2;
	// Relative position/distance
	assign left_rel_x1 = x1 - LEFT_WALL;
	assign left_rel_x2 = RIGHT_WALL - x2;
	assign rel_x1_x2   = x2 - x1;
	// Position
	assign x1_new = x1 + (v1 >>> DT);
	assign x2_new = x2 + (v2 >>> DT);
	// Velocity
	assign v1_new = v1 + ((-spring_f_1 - damp_1 + spring_f_midl) >>> DT);
	assign v2_new = v2 + (( spring_f_2 - damp_2 - spring_f_midl) >>> DT);

	//Update state variables of simulation of spring- mass
	always @ (posedge clk or negedge reset) begin
		
		if (!reset) begin 
			state <= ST_reset;
		end
		else begin

			case (state)

				////////////////////////////////////////////////////////
				ST_reset: begin
					state <= ST_restart;
					x1 <= 18'h0; 
					v1 <= 18'h0; 
					x2 <= 18'h0; 
					v2 <= 18'h0; 
					k1 <= 18'h0;
					k2 <= 18'h0;
					km <= 18'h0;
				end

				////////////////////////////////////////////////////////
				ST_restart: begin
					if (restart) begin
						x1    <= x1_init; 
						v1    <= v1_init; 
						x2    <= x2_init; 
						v2    <= v2_init; 
						k1    <= k1_init;
						k2    <= k2_init;
						km    <= km_init;
						state <= ST_wait_start_low;
					end
				end

				////////////////////////////////////////////////////////
				ST_wait_start_low: begin
					if (!restart) begin
						state <= ST_compute;
						count <= 32'b0;
					end
				end

				////////////////////////////////////////////////////////
				ST_compute: begin
					if (restart) begin
						state <= ST_restart;
					end
					else begin
						// if(count >= 16'd32) begin // for modelsim 
						if(count >= 32'd200000) begin
							count <= 32'b0;
							x1    <= x1_new;
							v1    <= v1_new;
							x2    <= x2_new;
							v2    <= v2_new;
						end
						else begin
							count <= count + 32'b1;
						end
					end
				end

				////////////////////////////////////////////////////////
				default: begin
					state <= ST_reset;
				end

			endcase
		end	
	end

endmodule
	

/////////////////////////////////////////////////
//// Multiplier /////////////////////////////////
/////////////////////////////////////////////////	
module signed_mult (out, a, b);
		output 		[17:0]	out;
		input 	signed	[17:0] 	a;
		input 	signed	[17:0] 	b;
		wire	signed	[17:0]	out;
		wire 	signed	[35:0]	mult_out;
		assign mult_out = a * b;
		// due to the signed 18 bits fixed points, 
		// we take the bit from the sign and the LSB
		// of the integer part: bits 35 and 32
		// and the 16 MSB of the fractionnal part
		assign out = {mult_out[35], mult_out[32:16]};
endmodule


/////////////////////////////////////////////////
//// Integrator /////////////////////////////////
/////////////////////////////////////////////////
module integrator(out,funct,InitialOut,dt,clk,reset);
	output [17:0] out; 				//the state variable V
	input signed [17:0] funct;      //the dV/dt function
	input [3:0] dt ;				// in units of SHIFT-right
	input clk, reset;
	input signed [17:0] InitialOut; //the initial state variable V
	
	wire signed	[17:0] out, v1new ;
	reg signed	[17:0] v1 ;
	
	always @ (posedge clk) 
	begin
		if (reset==0) //reset	
			v1 <= InitialOut ; // 
		else 
			v1 <= v1new ;	
	end
	assign v1new = v1 + (funct>>>dt) ;
	assign out = v1 ;
endmodule
//////////////////////////////////////////////////