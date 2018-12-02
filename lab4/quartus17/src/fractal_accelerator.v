module fractal_accelerator (
	// common
	input clock,
	input reset_n,
	// input side of the accelerator
	input  [31:0] real_part_in,
	input  [31:0] imaginary_part_in,
	input  [9:0]  y_coord_in,
	input  [9:0]  x_coord_in,
	input		  data_in_write,
	output		  data_in_full,
	// output side of the accelerator
	output [9:0]  x_coord_out,
	output [9:0]  y_coord_out,
	output [10:0] interation_count,
	output 		  is_in_the_set,
	input 		  data_out_read,
	output		  data_out_available
	);


	/*88888b.  8888888888  .d8888b.  888             d8888 
	888  "Y88b 888        d88P  Y88b 888            d88888 
	888    888 888        888    888 888           d88P888 
	888    888 8888888    888        888          d88P 888 
	888    888 888        888        888         d88P  888 
	888    888 888        888    888 888        d88P   888 
	888  .d88P 888        Y88b  d88P 888       d8888888888 
	8888888P"  8888888888  "Y8888P"  88888888 d88P     8*/

	// fifo in
	wire [79:0]	fifo_in_data_in;
	wire 		fifo_in_rdreq;
	wire 		fifo_in_wrreq;
	wire 		fifo_in_almost_full;
	wire 		fifo_in_empty;
	wire 		fifo_in_full;
	wire [79:0]	fifo_in_data_out;
	wire [6:0]	fifo_in_usedw;
	// fifo out
	wire [31:0]	fifo_out_data_in;
	wire 		fifo_out_rdreq;
	wire 		fifo_out_wrreq;
	wire 		fifo_out_almost_full;
	wire 		fifo_out_empty;
	wire 		fifo_out_full;
	wire [31:0]	fifo_out_data_out;
	wire [7:0]	fifo_out_usedw;
	// pipes
	wire [79:0]	pipe_data_in;
	wire 		pipes_data_in_available;
	wire 		pipes_data_in_read;
	wire 		pipes_space_ahead;
	wire [31:0]	pipe_data_out;
	wire 		pipes_write_out;


	       /*888  .d8888b.   .d8888b. 8888888  .d8888b.  888b    888 
	      d88888 d88P  Y88b d88P  Y88b  888   d88P  Y88b 8888b   888 
	     d88P888 Y88b.      Y88b.       888   888    888 88888b  888 
	    d88P 888  "Y888b.    "Y888b.    888   888        888Y88b 888 
	   d88P  888     "Y88b.     "Y88b.  888   888  88888 888 Y88b888 
	  d88P   888       "888       "888  888   888    888 888  Y88888 
	 d8888888888 Y88b  d88P Y88b  d88P  888   Y88b  d88P 888   Y8888 
	d88P     888  "Y8888P"   "Y8888P" 8888888  "Y8888P88 888    Y8*/

	// fifo in 
	assign pipes_data_in_available = !fifo_in_empty;
	assign fifo_in_rdreq           = pipes_data_in_read;
	assign pipe_data_in            = fifo_in_data_out;
	assign fifo_in_wrreq           = data_in_write;
	assign data_in_full            = fifo_in_almost_full;
	assign fifo_in_data_in         = {	{x_coord_in},
										{y_coord_in},	
										{imaginary_part_in[31:2]},
										{real_part_in[31:2]}};

	// fifo out 
	assign pipes_space_ahead  = !fifo_out_almost_full;
	assign fifo_out_wrreq     = pipes_write_out;
	assign fifo_out_data_in   = pipe_data_out;
	assign fifo_out_rdreq     = data_out_read ;
	assign data_out_available = !fifo_out_empty;
	assign { 	{x_coord_out},
				{y_coord_out},
				{interation_count},
				{is_in_the_set} }
			= fifo_out_data_out;


	/*8b     d888  .d88888b.  8888888b.  888     888 888      8888888888 
	8888b   d8888 d88P" "Y88b 888  "Y88b 888     888 888      888        
	88888b.d88888 888     888 888    888 888     888 888      888        
	888Y88888P888 888     888 888    888 888     888 888      8888888    
	888 Y888P 888 888     888 888    888 888     888 888      888        
	888  Y8P  888 888     888 888    888 888     888 888      888        
	888   "   888 Y88b. .d88P 888  .d88P Y88b. .d88P 888      888        
	888       888  "Y88888P"  8888888P"   "Y88888P"  88888888 88888888*/


	fifo_in fifo_in_i (
		.clock       (clock),
		.data        (fifo_in_data_in),
		.rdreq       (fifo_in_rdreq),
		.wrreq       (fifo_in_wrreq),
		.almost_full (fifo_in_almost_full),
		.empty       (fifo_in_empty),
		.full        (fifo_in_full),
		.q           (fifo_in_data_out),
		.usedw       (fifo_in_usedw)
	);


	pipes pipes_i (
		// common
		.clock       	   (clock),
		.reset_n       	   (reset_n),
		// input side of the pipes
		.data_in      		(pipe_data_in),	  		  // fifo_in_data_out
		.data_in_available 	(pipes_data_in_available),// not fifo_in_empty
		.data_in_read      	(pipes_data_in_read), 	  // fifo_in_rdreq
		.space_ahead	   	(pipes_space_ahead),  	  // not fifo_out_almost_full
		// output side of the pipes
		.data_out       	(pipe_data_out),	  	  // fifo_out_data_in
		.write_out		   	(pipes_write_out)  		  // fifo_out_wrreq
	);


	fifo_out fifo_out_i (
		.clock       (clock),
		.data        (fifo_out_data_in),
		.rdreq       (fifo_out_rdreq),
		.wrreq       (fifo_out_wrreq),
		.almost_full (fifo_out_almost_full),
		.empty       (fifo_out_empty),
		.full        (fifo_out_full),
		.q           (fifo_out_data_out),
		.usedw       (fifo_out_usedw)
	);


		   /*888 888      888       888        d8888 Y88b   d88P  .d8888b.  
	      d88888 888      888   o   888       d88888  Y88b d88P  d88P  Y88b 
	     d88P888 888      888  d8b  888      d88P888   Y88o88P   Y88b.      
	    d88P 888 888      888 d888b 888     d88P 888    Y888P     "Y888b.   
	   d88P  888 888      888d88888b888    d88P  888     888         "Y88b. 
	  d88P   888 888      88888P Y88888   d88P   888     888           "888 
	 d8888888888 888      8888P   Y8888  d8888888888     888     Y88b  d88P 
	d88P     888 88888888 888P     Y888 d88P     888     888      "Y8888*/

endmodule