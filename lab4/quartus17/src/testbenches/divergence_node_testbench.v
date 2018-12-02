`timescale 1 ps / 1 ps

// `include "220model.v"

module divergence_node_testbench ();

	parameter DELAY = 13;


	/*88888b.  8888888888  .d8888b.  888             d8888 
	888  "Y88b 888        d88P  Y88b 888            d88888 
	888    888 888        888    888 888           d88P888 
	888    888 8888888    888        888          d88P 888 
	888    888 888        888        888         d88P  888 
	888    888 888        888    888 888        d88P   888 
	888  .d88P 888        Y88b  d88P 888       d8888888888 
	8888888P"  8888888888  "Y8888P"  88888888 d88P     8*/

	// common
	reg			clock;
	reg			reset_n;
	// process related
	reg 		busy_toggle;
	reg [7:0]	delay_cnt;

	// input of the node
	reg			node_start;
	reg [31:0]	node_im_start_sys; 	// the reg here add 1 of latency
	reg [31:0]	node_re_start_sys; 	// the reg here add 1 of latency
	reg [9:0]	node_x_coord_in; 	// the reg here add 1 of latency
	reg [9:0]	node_y_coord_in; 	// the reg here add 1 of latency
	// output of the node
	wire 		node_busy;
	wire 		node_diverge_out;
	wire		node_write_out;
	wire [10:0] node_iter_out;
	wire [9:0]	node_x_coord_out;
	wire [9:0]	node_y_coord_out;


	/*8b     d888  .d88888b.  8888888b.  888     888 888      8888888888 
	8888b   d8888 d88P" "Y88b 888  "Y88b 888     888 888      888        
	88888b.d88888 888     888 888    888 888     888 888      888        
	888Y88888P888 888     888 888    888 888     888 888      8888888    
	888 Y888P 888 888     888 888    888 888     888 888      888        
	888  Y8P  888 888     888 888    888 888     888 888      888        
	888   "   888 Y88b. .d88P 888  .d88P Y88b. .d88P 888      888        
	888       888  "Y88888P"  8888888P"   "Y88888P"  88888888 88888888*/

	 divergence_node divergence_node_i (
	 	// inputs
		.clock        (clock),
		.reset_n       (reset_n),
		.start        (node_start),
		.im_start_sys (node_im_start_sys),
		.re_start_sys (node_re_start_sys),
		.x_coord_in   (node_x_coord_in),
		.y_coord_in   (node_y_coord_in),
		// outputs
		.busy         (node_busy),
		.diverge_out  (node_diverge_out),
		.write_out    (node_write_out),
		.iter_out 	  (node_iter_out),
		.x_coord_out  (node_x_coord_out),
		.y_coord_out  (node_y_coord_out)
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
		reset_n = 1'b0;
		#25;
		reset_n = 1'b1;
		#25;
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


	always @ (posedge clock or negedge reset_n) begin
		if (!reset_n) begin
			node_im_start_sys <= 32'h04000000;
			node_re_start_sys <= 32'h06600000;
			delay_cnt         <= 8'h00;
			busy_toggle       <= 1'b0;
			node_start        <= 1'b0;
			node_y_coord_in   <= 10'd0;
			node_x_coord_in   <= 10'd0;
		end
		else begin
			if ((!node_busy && !busy_toggle) || (!node_busy && (delay_cnt >= DELAY))) begin
				delay_cnt         <= 8'h00;
				node_start        <= 1'b1;
				node_im_start_sys <= 32'h04000000;
				node_re_start_sys <= node_re_start_sys - 32'h00100000;
				busy_toggle       <= 1'b1;
				node_y_coord_in   <= node_y_coord_in + 10'd1;
				node_x_coord_in   <= node_x_coord_in + 10'd2;
			end 
			else if (node_busy) begin
				busy_toggle <= 1'b0;
				node_start  <= 1'b0;
			end
			else begin
				delay_cnt  <= delay_cnt + 8'b1;
				node_start <= 1'b0;
			end
		end
	end

endmodule