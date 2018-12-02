module para_mux (select, data_in, data_out); 

	parameter WIDTH        = 32;  // number of bits wide 
	parameter DEPTH        = 3;  // number of inputs 
	parameter SELECT_WIDTH = 5;  // number of select lines 
	parameter ARRAY        = DEPTH * WIDTH; 


	input  [SELECT_WIDTH-1:0] select;
	input  [ARRAY-1:0]        data_in;
	output [WIDTH-1:0]        data_out;

	integer i; 

	reg[WIDTH-1:0 ] tmp; // tmp will be use to minimize events 
	reg[WIDTH-1:0 ] data_out;

	always @(select or data_in) begin 
		for(i=0; i < WIDTH; i = i + 1) begin// for bits in the width 
			tmp[i] = data_in[WIDTH*select + i]; 
		end
		data_out = tmp; 
	end

endmodule
