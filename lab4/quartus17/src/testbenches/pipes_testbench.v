`timescale 1 ps / 1 ps

module pipes_testbench ();

	parameter RE_PART_IN_START = 32'hE_0000000; // -2;
	parameter RE_DELTA         = 32'h0_3333333; // 0.2
	parameter IM_PART_IN_START = 32'hF_0000000; // -1
	parameter IM_DELTA         = 32'h0_199999A; // 0.1


	// re=0.526316 	 im=0.263158
	// parameter RE_PART_IN_START = 32'hF_435E52A; // re=0.526316;
	// parameter IM_PART_IN_START = 32'hF_A1AF295; // im=0.263158
	// parameter RE_DELTA         = 32'h0_0000000; // 0.4
	// parameter IM_DELTA         = 32'h0_0000000; // 0.2


	/*88888b.  8888888888  .d8888b.  888             d8888 
	888  "Y88b 888        d88P  Y88b 888            d88888 
	888    888 888        888    888 888           d88P888 
	888    888 8888888    888        888          d88P 888 
	888    888 888        888        888         d88P  888 
	888    888 888        888    888 888        d88P   888 
	888  .d88P 888        Y88b  d88P 888       d8888888888 
	8888888P"  8888888888  "Y8888P"  88888888 d88P     8*/

	// Common
	reg			clock;
	reg			reset_n;
	// Fractal accelerator
	// OUT (left) side of the pipes
	reg	 [31:0]	real_part_in;
	reg	 [31:0]	imaginary_part_in;
	reg	 [9:0]	y_coord_in;
	reg	 [9:0]	x_coord_in;
	reg	 		data_in_write;
	wire	 	data_in_full;
	// OUT (right) side of the pipes
	wire [9:0]	x_coord_out;
	wire [9:0]	y_coord_out;
	wire [10:0]	interation_count;
	wire	 	is_in_the_set;
	reg	 		data_out_read;
	wire	 	data_out_available;


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
		.real_part_in       (real_part_in),
		.imaginary_part_in  (imaginary_part_in),
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


	/*88888 888b    888 8888888 88888888888 8888888        d8888 888      
	  888   8888b   888   888       888       888         d88888 888      
	  888   88888b  888   888       888       888        d88P888 888      
	  888   888Y88b 888   888       888       888       d88P 888 888      
	  888   888 Y88b888   888       888       888      d88P  888 888      
	  888   888  Y88888   888       888       888     d88P   888 888      
	  888   888   Y8888   888       888       888    d8888888888 888      
	8888888 888    Y888 8888888     888     8888888 d88P     888 888888*/

	initial begin 
		reset_n = 1'b1;
		#25; reset_n = 1'b0;
		#25; reset_n = 1'b1;
	end


		   /*888 888      888       888        d8888 Y88b   d88P  .d8888b.  
	      d88888 888      888   o   888       d88888  Y88b d88P  d88P  Y88b 
	     d88P888 888      888  d8b  888      d88P888   Y88o88P   Y88b.      
	    d88P 888 888      888 d888b 888     d88P 888    Y888P     "Y888b.   
	   d88P  888 888      888d88888b888    d88P  888     888         "Y88b. 
	  d88P   888 888      88888P Y88888   d88P   888     888           "888 
	 d8888888888 888      8888P   Y8888  d8888888888     888     Y88b  d88P 
	d88P     888 88888888 888P     Y888 d88P     888     888      "Y8888*/

	always begin
		#10; clock = 1'b0;
		#10; clock = 1'b1;
	end


	// infinite that SEND data to the tested module (divergence_node)
	always @ (posedge clock) begin
		if (!reset_n) begin
			real_part_in      <= RE_PART_IN_START;
			imaginary_part_in <= IM_PART_IN_START;
			x_coord_in        <= 10'd0;
			y_coord_in        <= 10'd0;
			data_in_write     <= 1'd0;
		end
		else begin
			if (!data_in_full && x_coord_in <= 19) begin
				real_part_in      <= real_part_in 	   + RE_DELTA;
				imaginary_part_in <= imaginary_part_in + IM_DELTA;
				x_coord_in        <= x_coord_in + 10'd1;
				y_coord_in        <= y_coord_in + 10'd1;
				data_in_write     <= 1'd1;
			end
			else begin
				real_part_in      <= real_part_in;
				imaginary_part_in <= 32'h04000000;
				x_coord_in        <= x_coord_in;
				y_coord_in        <= y_coord_in;
				data_in_write 	  <= 1'd0;
			end
		end
	end


	// infinite that RECEIVE data to the tested module 
	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin
			data_out_read <= 1'd0;
		end
		else begin
			if (data_out_available)
				data_out_read <= 1'd1;
			else
				data_out_read <= 1'd0;
		end
	end

endmodule 

