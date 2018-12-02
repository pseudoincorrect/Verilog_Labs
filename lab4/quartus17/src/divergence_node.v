///////////////////////////////////////////////////////////////////
//	ONGOING WORK ON THAT FILE :
//
//  
//
//
///////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

// `include "lpm"

module divergence_node (
	// inputs
	input 				clock,
	input 				reset_n,
	input 				start,
	input [79:0] 		data_in,
	// outputs
	output reg			busy,
	output reg			write_out,
	output [31:0] 		data_out
	);

	// input [79:0] 	data_in,
	// output [31:0] 	data_out,
	
	parameter X_SIMULATION   = 1'bX;
	parameter ZERO_IMPLEMENT = 1'b0;

	parameter ADD_PIPEL_SIZE  = 3;
	parameter MULT_PIPEL_SIZE = 5;
	parameter ALL_PIPEL_SIZE  = (ADD_PIPEL_SIZE*2+MULT_PIPEL_SIZE+1);
	parameter MAX_ITERATIONS  = 11'd24;
	parameter INTEG_SIZE      = 4;
	parameter FRACT_SIZE      = 28;


	/*88888b.  8888888888  .d8888b.  888             d8888 
	888  "Y88b 888        d88P  Y88b 888            d88888 
	888    888 888        888    888 888           d88P888 
	888    888 8888888    888        888          d88P 888 
	888    888 888        888        888         d88P  888 
	888    888 888        888    888 888        d88P   888 
	888  .d88P 888        Y88b  d88P 888       d8888888888 
	8888888P"  8888888888  "Y8888P"  88888888 d88P     8*/

	// Adder imaginary number
	wire signed [63:0]	add_im_in_a;
	wire signed [63:0]	add_im_in_b;
	wire signed [63:0]	add_im_out;
	wire signed [31:0]	add_im_out_trunc; 
	wire 	 			add_im_overfl;
	// Adder real number
	wire signed [63:0] 	add_re_in_a;
	wire signed [63:0] 	add_re_in_b;
	wire signed [63:0] 	add_re_out;
	wire signed [31:0]	add_re_out_trunc;
	wire 				add_re_overfl;
	// Adder comparator
	wire signed [63:0] 	add_comp_in_a;
	wire signed [63:0] 	add_comp_in_b;
	wire signed [63:0] 	add_comp_out;
	wire signed [31:0]	add_comp_out_trunc;
	wire 				add_comp_overfl;
	// Subber real number
	wire signed [63:0] 	sub_re_in_a;
	wire signed [63:0] 	sub_re_in_b;
	wire signed [63:0] 	sub_re_out;
	wire 				sub_re_overfl;
	// Multiplier imaginary number
	wire signed [31:0] 	mult_im_in_b;
	wire signed [31:0] 	mult_im_in_a;
	wire signed [63:0]	mult_im_out;
	wire signed [63:0] 	mult_im_out_shifted;
	// Squarer real number (real nb input)
	wire signed [31:0] 	square_re_re_in_a;
	wire signed [63:0] 	square_re_re_out;
	// Squarer real number (imaginary nb input)
	wire signed [31:0]	square_re_im_in_a;
	wire signed [63:0]	square_re_im_out;
	// Inital value (constants)
	reg  signed [31:0] 	c_re_reg;
	reg  signed [31:0] 	c_im_reg;
	reg  signed [31:0] 	im_start_sys_reg;
	reg  signed [31:0] 	re_start_sys_reg;
	// Real and Imaginary part
	reg  signed [31:0] 	im_part;
	reg  signed [31:0] 	re_part;
	// Pipeline registers arrays
	reg  signed [31:0] 	c_im_Mq 			[MULT_PIPEL_SIZE-1 : 0];
	reg  signed [31:0] 	c_re_Mq 			[MULT_PIPEL_SIZE-1 : 0];
	reg  signed [63:0] 	square_re_re_out_Aq   	[ADD_PIPEL_SIZE-1 : 0];
	reg  signed [31:0]	add_im_out_trunc_Aq	  	[ADD_PIPEL_SIZE-1 : 0];
	reg  signed [31:0]	add_comp_out_trunc_Aq 	[ADD_PIPEL_SIZE-1 : 0];
	reg  signed 	 	comparator_out_q 	  	[ADD_PIPEL_SIZE-1 : 0];
	reg  signed 	 	add_im_overfl_q 	  	[ADD_PIPEL_SIZE-1 : 0];
	reg  signed 	 	sub_re_overfl_q	 	  	[ADD_PIPEL_SIZE-1 : 0];
	reg  signed 	 	in_process_q		[ALL_PIPEL_SIZE-1 : 0];
	reg  signed [10:0] 	count_iterations_q	[ALL_PIPEL_SIZE-1 : 0];
	reg  signed [9:0] 	x_coord_q			[ALL_PIPEL_SIZE-1 : 0];
	reg  signed [9:0] 	y_coord_q			[ALL_PIPEL_SIZE-1 : 0];
	// Counter
	reg 		lock_iter;
	reg 		enable_iterations;
	reg [7:0] 	counter_pipeline;
	// coordinates
	reg [9:0]   x_coord_start;
 	reg [9:0]   y_coord_start;
	// Input synchronizer
	reg [4:0]	counter_processes;
	wire 		load;
	wire 		start_sys;
	reg 		r0, r1, r2;
	reg			data_ready;
	// output divergence
	wire 		adder_overflow;
	wire 		comparator_out;
	wire 		diverge;
	wire 		done;
	// inputs
	wire [31:0]	im_start_sys;
	wire [31:0]	re_start_sys;
	wire [9:0]	x_coord_in;
	wire [9:0]	y_coord_in;
	// output
	reg 		diverge_out;
	reg [10:0] 	iter_out;
	reg	[9:0]	x_coord_out;
	reg	[9:0]	y_coord_out;


	       /*888  .d8888b.   .d8888b. 8888888  .d8888b.  888b    888 
	      d88888 d88P  Y88b d88P  Y88b  888   d88P  Y88b 8888b   888 
	     d88P888 Y88b.      Y88b.       888   888    888 88888b  888 
	    d88P 888  "Y888b.    "Y888b.    888   888        888Y88b 888 
	   d88P  888     "Y88b.     "Y88b.  888   888  88888 888 Y88b888 
	  d88P   888       "888       "888  888   888    888 888  Y88888 
	 d8888888888 Y88b  d88P Y88b  d88P  888   Y88b  d88P 888   Y8888 
	d88P     888  "Y8888P"   "Y8888P" 8888888  "Y8888P88 888    Y8*/

	// Adder Imaginary number
	assign add_im_in_a = mult_im_out_shifted;
	assign add_im_in_b = {  {INTEG_SIZE{c_im_Mq[MULT_PIPEL_SIZE-1][31]}}, 
							{c_im_Mq[MULT_PIPEL_SIZE-1]}, 
							{FRACT_SIZE{1'b0}} };
	// Adder real number
	assign add_re_in_a = sub_re_out;
	assign add_re_in_b = square_re_re_out_Aq[ADD_PIPEL_SIZE-1];
	// Subber real number
	assign sub_re_in_b = square_re_im_out;
	assign sub_re_in_a = {  {INTEG_SIZE{c_re_Mq[MULT_PIPEL_SIZE-1][31]}}, 
							{c_re_Mq[MULT_PIPEL_SIZE-1]}, 
							{FRACT_SIZE{1'b0}}  };
	// Subber real number
	assign add_comp_in_a       = square_re_im_out;
	assign add_comp_in_b       = square_re_re_out;
	// Multiplier Imaginary 
	assign mult_im_in_a        = im_part;
	assign mult_im_in_b        = re_part;
	// Squarer Real Imaginary
	assign square_re_im_in_a   = im_part;
	// Squarer Real Real
	assign square_re_re_in_a   = re_part;
	// Multiply by two (shift left by one)
	assign mult_im_out_shifted = {{mult_im_out[62:0]}, {1'b0}};
	// Divergence test
	assign adder_overflow = add_im_overfl_q[ADD_PIPEL_SIZE-1] || 
							sub_re_overfl_q[ADD_PIPEL_SIZE-1] || 
							add_re_overfl;
	assign comparator_out = (add_comp_out >= 64'h0400_0000_0000_0000);
	// assign comparator_out = (add_comp_out_trunc >= 32'h4000_0000);
	assign diverge        = comparator_out_q[ADD_PIPEL_SIZE-1] || adder_overflow;
	// truncature/shift from 64 bits to 32, fixed points (8/56 to 4/28)
	assign add_re_out_trunc   = { {add_re_out[63]},
		 					  	  {add_re_out[ (FRACT_SIZE * 2 + INTEG_SIZE - 2) : FRACT_SIZE ]} };
	assign add_im_out_trunc   = { {add_im_out[63]},
		 					  	  {add_im_out[ (FRACT_SIZE * 2 + INTEG_SIZE - 2) : FRACT_SIZE ]} };
	assign add_comp_out_trunc = { {add_comp_out[63]},
		 					  	  {add_comp_out[ (FRACT_SIZE * 2 + INTEG_SIZE - 2) : FRACT_SIZE ]} };
	// Done	
	assign done = diverge || (count_iterations_q[ALL_PIPEL_SIZE-1] >= MAX_ITERATIONS);
	// Load
	assign load = (!in_process_q[ALL_PIPEL_SIZE-1]) && data_ready;
	// input
	assign  {	{x_coord_in},
				{y_coord_in},
				{im_start_sys[31:2]},
				{re_start_sys[31:2]} } 
				= data_in;

	assign im_start_sys[1:0] = 2'b0;
	assign re_start_sys[1:0] = 2'b0;

	// output
	assign data_out = {	
				{x_coord_out},
				{y_coord_out},
				{iter_out},
				{diverge_out} };

	/*8b     d888  .d88888b.  8888888b.  888     888 888      8888888888 
	8888b   d8888 d88P" "Y88b 888  "Y88b 888     888 888      888        
	88888b.d88888 888     888 888    888 888     888 888      888        
	888Y88888P888 888     888 888    888 888     888 888      8888888    
	888 Y888P 888 888     888 888    888 888     888 888      888        
	888  Y8P  888 888     888 888    888 888     888 888      888        
	888   "   888 Y88b. .d88P 888  .d88P Y88b. .d88P 888      888        
	888       888  "Y88888P"  8888888P"   "Y88888P"  88888888 88888888*/

	Add_Sub add_im (
		.add_sub  (1'b1),
		.clock	  (clock), 
		.dataa	  (add_im_in_a), 
		.datab	  (add_im_in_b), // Constant C_im
		.overflow (add_im_overfl), 
		.result	  (add_im_out));

	Add_Sub add_re (
		.add_sub  (1'b1),
		.clock	  (clock), 
		.dataa	  (add_re_in_a), 
		.datab	  (add_re_in_b), // Constant C_re
		.overflow (add_re_overfl), 
		.result	  (add_re_out));

	Add_Sub add_comp (
		.add_sub  (1'b1),
		.clock	  (clock), 
		.dataa	  (add_comp_in_a), 
		.datab	  (add_comp_in_b), // Constant C_re
		.overflow (add_comp_overfl), 
		.result	  (add_comp_out));

	Add_Sub sub (
		.add_sub  (1'b0),
		.clock	  (clock), 
		.dataa	  (sub_re_in_a), 
		.datab	  (sub_re_in_b), 
		.overflow (sub_re_overfl), 
		.result	  (sub_re_out));

	Mult mult_im (
		.clock	  (clock), 
		.dataa	  (mult_im_in_a), 
		.datab	  (mult_im_in_b), 
		.result	  (mult_im_out));

	Mult square_re_re (
		.clock	  (clock), 
		.dataa	  (square_re_re_in_a), 
		.datab	  (square_re_re_in_a), 
		.result	  (square_re_re_out));

	Mult square_re_im (
		.clock	  (clock), 
		.dataa	  (square_re_im_in_a), 
		.datab	  (square_re_im_in_a), 
		.result	  (square_re_im_out));

	// for debug/simulation only 
	wire signed [31:0]	add_im_out_trunc_f; // debug
	wire signed [31:0]	add_re_out_trunc_f; // debug
	wire signed [31:0]	add_comp_out_trunc_f; // debug

	fconvert2 real_part (clock, add_re_out_trunc, add_re_out_trunc_f);
	fconvert2 imag_part (clock, add_im_out_trunc_Aq[ADD_PIPEL_SIZE-1],   add_im_out_trunc_f);
	fconvert2 comp_part (clock, add_comp_out_trunc_Aq[ADD_PIPEL_SIZE-1], add_comp_out_trunc_f);


		   /*888 888      888       888        d8888 Y88b   d88P  .d8888b.  
	      d88888 888      888   o   888       d88888  Y88b d88P  d88P  Y88b 
	     d88P888 888      888  d8b  888      d88P888   Y88o88P   Y88b.      
	    d88P 888 888      888 d888b 888     d88P 888    Y888P     "Y888b.   
	   d88P  888 888      888d88888b888    d88P  888     888         "Y88b. 
	  d88P   888 888      88888P Y88888   d88P   888     888           "888 
	 d8888888888 888      8888P   Y8888  d8888888888     888     Y88b  d88P 
	d88P     888 88888888 888P     Y888 d88P     888     888      "Y8888*/

	///////////////////////////////////////////////////////////////////
	//	Input accept and notify
	///////////////////////////////////////////////////////////////////
	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin 
			data_ready <= 1'b0;
		end
		else begin
			if (load)
				data_ready <= 1'b0;
			else if (start_sys)
				data_ready <= 1'b1;
			else 
				data_ready <= data_ready;
		end
	end


	///////////////////////////////////////////////////////////////////
	//	Pipeline Counter
	///////////////////////////////////////////////////////////////////
	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin 
			counter_pipeline <= 8'b0;
		end
		else begin
			if (counter_pipeline >= (ALL_PIPEL_SIZE-1))
				counter_pipeline <= 8'b0;
			else 
				counter_pipeline <= counter_pipeline + 8'b1;
		end
	end


	///////////////////////////////////////////////////////////////////
	//	Start Signal Synchronizer
	///////////////////////////////////////////////////////////////////
	assign start_sys = r1 && (!r2);

	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin 
			r0 <= 1'b0;
			r1 <= 1'b0;
			r2 <= 1'b0;
		end
		else begin
			r0 <= start;
			r1 <= r0;
			r2 <= r1;
		end
	end


	///////////////////////////////////////////////////////////////////
	//	in_process reg || count_iterations_q
	///////////////////////////////////////////////////////////////////
	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin 
			in_process_q[0]       <= 1'b0;
			count_iterations_q[0] <= {11{ZERO_IMPLEMENT}};
			x_coord_q[0]          <= {10{ZERO_IMPLEMENT}};
			y_coord_q[0]          <= {10{ZERO_IMPLEMENT}};
		end
		else begin
			if (load) begin
				in_process_q[0]       <= 1'b1;
				count_iterations_q[0] <= 1'b0;
				x_coord_q[0]          <= x_coord_start;
				y_coord_q[0]          <= y_coord_start;
			end
			else if (done) begin
				in_process_q[0]       <= 1'b0;
				count_iterations_q[0] <= count_iterations_q[ALL_PIPEL_SIZE-1] + 11'b1;
				x_coord_q[0]          <= x_coord_q[ALL_PIPEL_SIZE-1];
				y_coord_q[0]          <= y_coord_q[ALL_PIPEL_SIZE-1];
			end
			else begin
				in_process_q[0]       <= in_process_q[ALL_PIPEL_SIZE-1];
				count_iterations_q[0] <= count_iterations_q[ALL_PIPEL_SIZE-1] + 11'b1;
				x_coord_q[0]          <= x_coord_q[ALL_PIPEL_SIZE-1];
				y_coord_q[0]          <= y_coord_q[ALL_PIPEL_SIZE-1];
			end
		end
	end


	///////////////////////////////////////////////////////////////////
	//	output_reg
	///////////////////////////////////////////////////////////////////
	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin 
			write_out   <= ZERO_IMPLEMENT;
			iter_out    <= {11{ZERO_IMPLEMENT}};
			diverge_out <= ZERO_IMPLEMENT;
			x_coord_out <= {10{ZERO_IMPLEMENT}};
			y_coord_out <= {10{ZERO_IMPLEMENT}};
		end
		else begin
			if (in_process_q[ALL_PIPEL_SIZE-1] && done) begin
				write_out   <= 1'b1;
				iter_out    <= count_iterations_q[ALL_PIPEL_SIZE-1];
				diverge_out <= diverge;
				x_coord_out <= x_coord_q[ALL_PIPEL_SIZE-1];
				y_coord_out <= y_coord_q[ALL_PIPEL_SIZE-1];
			end
			else begin
				write_out   <= 1'b0;
				iter_out    <= 11'b0;
				diverge_out <= 1'b0;
				x_coord_out <= 10'b0;
				y_coord_out <= 10'b0;
			end
		end
	end


	///////////////////////////////////////////////////////////////////
	//	busy
	///////////////////////////////////////////////////////////////////
	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin 
			busy    <= ZERO_IMPLEMENT;
		end
		else begin
			if (start || data_ready || start_sys || r0 || r1 || r2 || (counter_processes >= ALL_PIPEL_SIZE-2))
				busy <= 1'b1;
			else
				busy <= 1'b0;
		end
	end


	///////////////////////////////////////////////////////////////////
	//	counter_processes
	///////////////////////////////////////////////////////////////////
	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin 
			counter_processes <= 5'b0;
		end
		else begin
			if (load && write_out) 
				counter_processes <= counter_processes;
			else if (load)
				counter_processes <= counter_processes + 5'b1;
			else if (write_out)
				counter_processes <= counter_processes - 5'b1;
			else
				counter_processes <= counter_processes;
		end
	end


	/*8       .d88888b.         d8888 8888888b.  
	888      d88P" "Y88b       d88888 888  "Y88b 
	888      888     888      d88P888 888    888 
	888      888     888     d88P 888 888    888 
	888      888     888    d88P  888 888    888 
	888      888     888   d88P   888 888    888 
	888      Y88b. .d88P  d8888888888 888  .d88P 
	88888888  "Y88888P"  d88P     888 8888888*/

	//	Input Muxes
	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin
			im_part  <= {32{ZERO_IMPLEMENT}}; // Imaginary number
			re_part  <= {32{ZERO_IMPLEMENT}}; // Real number
			c_re_reg <= {32{ZERO_IMPLEMENT}}; // Constant Real number
			c_im_reg <= {32{ZERO_IMPLEMENT}}; // Constant Imaginary number
		end
		else begin 
			if (load) begin
				im_part  <= 32'b0;
				re_part  <= 32'b0;
				c_re_reg <= re_start_sys_reg;
				c_im_reg <= im_start_sys_reg;
			end
			else begin
				im_part  <= add_im_out_trunc_Aq[ADD_PIPEL_SIZE-1];
				re_part  <= add_re_out_trunc;
				c_re_reg <= c_re_reg;
				c_im_reg <= c_im_reg;	
			end
		end
	end


	///////////////////////////////////////////////////////////////////
	//	Input register
	///////////////////////////////////////////////////////////////////
	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin
			re_start_sys_reg <= {32{ZERO_IMPLEMENT}}; // Constant Real number
			im_start_sys_reg <= {32{ZERO_IMPLEMENT}}; // Constant Imaginary number
			x_coord_start	 <= {10{ZERO_IMPLEMENT}};
			y_coord_start	 <= {10{ZERO_IMPLEMENT}};
		end
		else begin 
			if (start) begin
				re_start_sys_reg <= re_start_sys;
				im_start_sys_reg <= im_start_sys;
				x_coord_start	 <= x_coord_in;
				y_coord_start	 <= y_coord_in;
			end
			else begin
				re_start_sys_reg <= re_start_sys_reg;
				im_start_sys_reg <= im_start_sys_reg;
				x_coord_start	 <= x_coord_start;
				y_coord_start	 <= y_coord_start;	
			end
		end
	end


	/*88888b. 8888888 8888888b.  8888888888 888      8888888 888b    888 8888888888 
	888   Y88b  888   888   Y88b 888        888        888   8888b   888 888        
	888    888  888   888    888 888        888        888   88888b  888 888        
	888   d88P  888   888   d88P 8888888    888        888   888Y88b 888 8888888    
	8888888P"   888   8888888P"  888        888        888   888 Y88b888 888        
	888         888   888        888        888        888   888  Y88888 888        
	888         888   888        888        888        888   888   Y8888 888        
	888       8888888 888        8888888888 88888888 8888888 888    Y888 88888888*/

	genvar i;
	generate 

		// Pipeline for c_im_Mq 
		// Pipeline for c_re_Mq
		for(i=0; i<MULT_PIPEL_SIZE; i=i+1) begin: c_im_Mq_gen		
			always @ (posedge clock or negedge reset_n) begin
				if (!reset_n) begin 
					c_im_Mq[i] <= {32{ZERO_IMPLEMENT}};
					c_re_Mq[i] <= {32{ZERO_IMPLEMENT}};
				end
				else begin
					if (i == 0)  begin
						c_im_Mq[0] <= c_im_reg;
						c_re_Mq[0] <= c_re_reg;
					end
					else begin
						c_im_Mq[i] <= c_im_Mq[i-1];
						c_re_Mq[i] <= c_re_Mq[i-1];
					end
				end
			end
		end


		// Pipeline for square_re_re_out_Aq
		// Pipeline for Imaginary adder truncatured
		// Pipeline for square absolute value (im^2 + re^2)
		// Pipeline for comparator
		// Pipeline for Im_add (Imaginary adder) overflow signal
		// Pipeline for sub (Real Subber) overflow signal
		for(i=0; i<ADD_PIPEL_SIZE; i=i+1) begin: square_re_re_out_Aq_gen	
			always @ (posedge clock or negedge reset_n) begin
				if (!reset_n) begin 
						square_re_re_out_Aq[i]   <= {64{ZERO_IMPLEMENT}};
						add_im_out_trunc_Aq[i]   <= {32{ZERO_IMPLEMENT}};
						add_comp_out_trunc_Aq[i] <= {32{ZERO_IMPLEMENT}};
						comparator_out_q[i]      <= ZERO_IMPLEMENT;
						add_im_overfl_q[i]       <= ZERO_IMPLEMENT;
						sub_re_overfl_q[i]       <= ZERO_IMPLEMENT;
				end
				else begin
					if (i == 0) begin
						square_re_re_out_Aq[0]   <= square_re_re_out;
						add_im_out_trunc_Aq[0]   <= add_im_out_trunc;
						add_comp_out_trunc_Aq[0] <= add_comp_out_trunc;
						comparator_out_q[0]      <= comparator_out;
						add_im_overfl_q[0]       <= add_im_overfl;
						sub_re_overfl_q[0]       <= sub_re_overfl;
					end
					else begin 
						square_re_re_out_Aq[i]   <= square_re_re_out_Aq[i-1];
						add_im_out_trunc_Aq[i]   <= add_im_out_trunc_Aq[i-1];
						add_comp_out_trunc_Aq[i] <= add_comp_out_trunc_Aq[i-1];
						comparator_out_q[i]      <= comparator_out_q[i-1];
						add_im_overfl_q[i]       <= add_im_overfl_q[i-1];
						sub_re_overfl_q[i]       <= sub_re_overfl_q[i-1];
					end
				end
			end
		end


		// Pipeline for in_process signal
		// Pipeline for count iteration
		// Pipeline for X coordinate
		// Pipeline for Y coordinate
		for(i=1; i<ALL_PIPEL_SIZE; i=i+1) begin: in_process_q_gen	// start from 1
			always @ (posedge clock or negedge reset_n) begin
				if (!reset_n) begin 
					in_process_q[i]       <= ZERO_IMPLEMENT;
					count_iterations_q[i] <= {11{ZERO_IMPLEMENT}};
					x_coord_q[i]          <= {10{ZERO_IMPLEMENT}};
					y_coord_q[i]          <= {10{ZERO_IMPLEMENT}};
				end
				else begin
					count_iterations_q[i] <=  count_iterations_q[i-1];
					in_process_q[i]       <=  in_process_q[i-1];
					x_coord_q[i]          <=  x_coord_q[i-1];
					y_coord_q[i]          <=  y_coord_q[i-1];
				end
			end
		end

	endgenerate 

endmodule


 /*8888b.   .d88888b.  888b    888 888     888 8888888888 8888888b. 88888888888 
d88P  Y88b d88P" "Y88b 8888b   888 888     888 888        888   Y88b    888     
888    888 888     888 88888b  888 888     888 888        888    888    888     
888        888     888 888Y88b 888 Y88b   d88P 8888888    888   d88P    888     
888        888     888 888 Y88b888  Y88b d88P  888        8888888P"     888     
888    888 888     888 888  Y88888   Y88o88P   888        888 T88b      888     
Y88b  d88P Y88b. .d88P 888   Y8888    Y888P    888        888  T88b     888     
 "Y8888P"   "Y88888P"  888    Y888     Y8P     8888888888 888   T88b    8*/

module converter_32to64 (
	input  [31:0] in_32_number,
	output [63:0] out_64_number
	);
	parameter INTEG_SIZE = 4;
	parameter FRACT_SIZE = 28;

	assign out_64_number = 	{ 
							  {INTEG_SIZE {in_32_number[31]}}, 
						  	  {in_32_number}, 
						  	  {FRACT_SIZE {1'b0}} 
						  	};
endmodule 

module converter_64to32 (
	input  [63:0] in_64_number,
	output [32:0] out_32_number
	);	
	parameter INTEG_SIZE = 4;
	parameter FRACT_SIZE = 28;

	assign out_32_number = 	{ 
		 					  {in_64_number[63]} ,
		 					  {in_64_number[ (FRACT_SIZE * 2 + INTEG_SIZE) : FRACT_SIZE ]} 
							};
endmodule 


