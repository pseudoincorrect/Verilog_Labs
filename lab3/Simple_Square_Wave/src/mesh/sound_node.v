module sound_node (
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

	// initialization parameters
	parameter Eta = 18'h0_000D;
	parameter Rho = 18'h0_0CCD; // better choose a power of 2
	// calculated parameters
	parameter Eta_frac = 18'h0_FFF3;
	// States
	parameter STATE_IDLE   = 4'd0; 
	parameter STATE_PROC_1 = 4'd1; 
	parameter STATE_PROC_2 = 4'd2; 
	parameter STATE_PROC_3 = 4'd3; 
	parameter STATE_PROC_4 = 4'd4;  
	parameter STATE_PROC_5 = 4'd5;  
	parameter STATE_PROC_6 = 4'd6;  
	parameter STATE_PROC_7 = 4'd7;  

	wire [17:0] mult_eta_M1234_out, mult_eta_M3_out, mult_eta_M1_out;
	reg [17:0] U_0_prev;
	reg [17:0] U_0, U_1, U_2, U_3, U_4;
	reg [17:0] U_12, U_34, U_1234;
	reg [17:0] U_1_p, U_2_p, U_3_p, U_4_p;
	reg [17:0] M_f, M_1, M_2, M_3, M_4, M_24, M_234, M_1234;
	// reg [17:0] Eta, Rho;
	reg [17:0] Stimu;
	reg [3:0]  state;


	signed_mult mult_eta_M1234 	(mult_eta_M1234_out, Eta_frac, M_1234);
	signed_mult mult_eta_M3 	(mult_eta_M3_out, Eta, U_0_prev);
	signed_mult mult_eta_M1 	(mult_eta_M1_out, Rho, U_1234);


	always @ (posedge clk or negedge reset_n) 
	begin
		if (!reset_n) begin
			{
			u_out, state, U_0_prev, 
			U_0, U_1, U_2, U_3, U_4, 
			U_1_p, U_2_p, U_3_p, U_4_p, 
			M_f, M_1, M_2, M_3, M_24, M_234, M_1234
			} <= {{18{18'b0}}, {4'b0}};
			state <= STATE_IDLE;
		end
		else begin
			case (state)

				STATE_IDLE : begin

					if (start) begin
						U_0      <= M_f;
						U_0_prev <= U_0;
						U_1      <= u_in_top;
						U_2      <= u_in_right;
						U_3      <= u_in_bottom;
						U_4      <= u_in_left;
						// Eta      <= eta;
						// Rho      <= rho;
						Stimu    <= stimu;
						state    <= STATE_PROC_1;
					end
				end

				STATE_PROC_1 : begin
					U_1_p <= U_1 - U_0;
					U_2_p <= U_2 - U_0;
					U_3_p <= U_3 - U_0;
					U_4_p <= U_4 - U_0;
					M_4   <= U_0_prev;
					state <= STATE_PROC_2;
				end

				STATE_PROC_2 : begin
					M_2   <= {U_0[16:0], 1'b0}; // M_2 * 2 
					// M_3   <= U_0_prev / Eta;
					M_3   <= mult_eta_M3_out; // MULTIPLICATION
					U_12  <= U_1_p + U_2_p;
					U_34  <= U_3_p + U_4_p;
					state <= STATE_PROC_3;
				end

				STATE_PROC_3 : begin
					M_24   <= M_2 - M_4;
					U_1234 <= U_12 + U_34;
					state  <= STATE_PROC_4;
				end

				STATE_PROC_4 : begin
					// M_1   <= U_1234 / Rho;
					M_1   <= mult_eta_M1_out; // MULTIPLICATION
					M_234 <= M_24 + M_3;
					state <= STATE_PROC_5;
				end

				STATE_PROC_5 : begin
					M_1234 <= M_1 + M_234;
					state  <= STATE_PROC_6;
				end

				STATE_PROC_6 : begin
					M_f   <= mult_eta_M1234_out; // MULTIPLICATION
					state <= STATE_PROC_7;
				end				

				STATE_PROC_7 : begin
					M_f   <= M_f + Stimu;
					u_out <= M_f + Stimu;
					state <= STATE_IDLE;
				end

				default begin
					state <= STATE_IDLE;
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
		// we take the 2 bit from the sign and the LSB
		// of the integer part: bits 35 and 32
		// and the 16 MSB of the fractionnal part
		assign out = {mult_out[35], mult_out[32:16]};
endmodule