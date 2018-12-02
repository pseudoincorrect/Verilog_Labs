`timescale 1 ps / 1 ps

module fractal_control_testbench ();


	/*88888b.  8888888888  .d8888b.  888             d8888 
	888  "Y88b 888        d88P  Y88b 888            d88888 
	888    888 888        888    888 888           d88P888 
	888    888 8888888    888        888          d88P 888 
	888    888 888        888        888         d88P  888 
	888    888 888        888    888 888        d88P   888 
	888  .d88P 888        Y88b  d88P 888       d8888888888 
	8888888P"  8888888888  "Y8888P"  88888888 d88P     8*/

	reg			clock;
	reg			start;
	reg			reset_n;
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

	Fractal_control Fractal_control_i (
		.clock              (clock),
		.reset_n            (reset_n),
		.start              (start),
		.data_out_read      (data_out_read),
		.x_coord_out        (x_coord_out),
		.y_coord_out        (y_coord_out),
		.interation_count   (interation_count),
		.is_in_the_set      (is_in_the_set),
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
		reset_n   = 1'b1;
		#25; 
		reset_n   = 1'b0;
		#25; 
		reset_n   = 1'b1;
		start     = 1'b0;
		#25 
		start     = 1'b1;
		#50;
		start     = 1'b0;
	end


		   /*888 888      888       888        d8888 Y88b   d88P  .d8888b.  
	      d88888 888      888   o   888       d88888  Y88b d88P  d88P  Y88b 
	     d88P888 888      888  d8b  888      d88P888   Y88o88P   Y88b.      
	    d88P 888 888      888 d888b 888     d88P 888    Y888P     "Y888b.   
	   d88P  888 888      888d88888b888    d88P  888     888         "Y88b. 
	  d88P   888 888      88888P Y88888   d88P   888     888           "888 
	 d8888888888 888      8888P   Y8888  d8888888888     888     Y88b  d88P 
	d88P     888 88888888 888P     Y888 d88P     888     888      "Y8888*/

	// Clock generation
	always begin
		#10; clock = 1'b0;
		#10; clock = 1'b1;
	end

	// RECEIVE data to the tested module
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
