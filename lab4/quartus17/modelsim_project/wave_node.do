onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /divergence_node_testbench/clock
add wave -noupdate -radix unsigned /divergence_node_testbench/reset_n
add wave -noupdate -radix unsigned /divergence_node_testbench/busy_toggle
add wave -noupdate -radix unsigned /divergence_node_testbench/delay_cnt
add wave -noupdate -radix unsigned /divergence_node_testbench/node_start
add wave -noupdate -radix hexadecimal /divergence_node_testbench/node_im_start_sys
add wave -noupdate -radix hexadecimal /divergence_node_testbench/node_re_start_sys
add wave -noupdate -radix unsigned /divergence_node_testbench/node_x_coord_in
add wave -noupdate -radix unsigned /divergence_node_testbench/node_y_coord_in
add wave -noupdate -radix unsigned /divergence_node_testbench/node_busy
add wave -noupdate -radix unsigned /divergence_node_testbench/node_diverge_out
add wave -noupdate -radix unsigned /divergence_node_testbench/node_write_out
add wave -noupdate -radix unsigned /divergence_node_testbench/node_iter_out
add wave -noupdate -radix unsigned /divergence_node_testbench/node_x_coord_out
add wave -noupdate -radix unsigned /divergence_node_testbench/node_y_coord_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5875 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {5640 ps} {6640 ps}
