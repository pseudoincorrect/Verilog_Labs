module divergence_node (
	input 			start
	input  [31:0]	im_start,
	output [11:0] 	iterations,
	output 			done
	);

add add_im    (
	.clock	  (clk), 
	.dataa	  (add_im_in_a), 
	.datab	  (add_im_in_b), 
	.overflow (add_im_of), 
	.result	  (add_im_out));

add add_im    (
	.clock	  (clk), 
	.dataa	  (add_re_in_a), 
	.datab	  (add_re_in_b), 
	.overflow (add_re_of), 
	.result	  (add_re_out));

sub sub    (
	.clock	  (clk), 
	.dataa	  (sub_in_a), 
	.datab	  (sub_in_b), 
	.overflow (sub_of), 
	.result	  (sub_out));

mult_altfp_mult_nto mult_im    (
	.clock	  (clk), 
	.dataa	  (mult_im_in_a), 
	.datab	  (mult_im_in_b), 
	.overflow (mult_im_of), 
	.result	  (mult_im_out));

mult_altfp_mult_nto mult_re_re (
	.clock	  (clk), 
	.dataa	  (mult_re_re_in_a), 
	.datab	  (mult_re_re_in_b), 
	.overflow (mult_re_re_of), 
	.result	  (mult_re_re_out));

mult_altfp_mult_nto mult_re_im (
	.clock	  (clk), 
	.dataa	  (mult_re_im_in_a), 
	.datab	  (mult_re_im_in_b), 
	.overflow (mult_re_im_of), 
	.result	  (mult_re_im_out));

