
module Seven_segments_display (  input [31:0] dbg_val, 
								 output [6:0] HEX0, 
								 output [6:0] HEX1, 
								 output [6:0] HEX2, 
								 output [6:0] HEX3, 
								 output [6:0] HEX4, 
								 output [6:0] HEX5, 
								 output [6:0] HEX6, 
								 output [6:0] HEX7
);
	SEG7_LUT seg0 (dbg_val[3:0]  , HEX0);
	SEG7_LUT seg1 (dbg_val[7:4]  , HEX1);
	SEG7_LUT seg2 (dbg_val[11:8] , HEX2);
	SEG7_LUT seg3 (dbg_val[15:12], HEX3);
	SEG7_LUT seg4 (dbg_val[19:16], HEX4);
	SEG7_LUT seg5 (dbg_val[23:20], HEX5);
	SEG7_LUT seg6 (dbg_val[27:24], HEX6);
	SEG7_LUT seg7 (dbg_val[31:28], HEX7);
	
endmodule

module SEG7_LUT	(	
	input		[3:0]	inpDIG,
	output reg	[6:0]	outSEG
);

	always @(inpDIG)
	begin
			case(inpDIG)
			4'h1: outSEG = 7'b1111001;	// ---t----
			4'h2: outSEG = 7'b0100100; 	// |	  |
			4'h3: outSEG = 7'b0110000; 	// lt	 rt
			4'h4: outSEG = 7'b0011001; 	// |	  |
			4'h5: outSEG = 7'b0010010; 	// ---m----
			4'h6: outSEG = 7'b0000010; 	// |	  |
			4'h7: outSEG = 7'b1111000; 	// lb	 rb
			4'h8: outSEG = 7'b0000000; 	// |	  |
			4'h9: outSEG = 7'b0011000; 	// ---b----
			4'ha: outSEG = 7'b0001000;
			4'hb: outSEG = 7'b0000011;
			4'hc: outSEG = 7'b1000110;
			4'hd: outSEG = 7'b0100001;
			4'he: outSEG = 7'b0000110;
			4'hf: outSEG = 7'b0001110;
			4'h0: outSEG = 7'b0000001;
			endcase
	end

endmodule
