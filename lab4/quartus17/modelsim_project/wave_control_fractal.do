onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fractal_control_testbench/Fractal_control_i/start
add wave -noupdate /fractal_control_testbench/Fractal_control_i/clock
add wave -noupdate /fractal_control_testbench/Fractal_control_i/data_out_available
add wave -noupdate /fractal_control_testbench/Fractal_control_i/x_coord_out
add wave -noupdate /fractal_control_testbench/Fractal_control_i/y_coord_out
add wave -noupdate /fractal_control_testbench/Fractal_control_i/interation_count
add wave -noupdate /fractal_control_testbench/Fractal_control_i/is_in_the_set
add wave -noupdate /fractal_control_testbench/Fractal_control_i/clock
add wave -noupdate /fractal_control_testbench/Fractal_control_i/data_in_write
add wave -noupdate /fractal_control_testbench/Fractal_control_i/x_coord_in
add wave -noupdate /fractal_control_testbench/Fractal_control_i/y_coord_in
add wave -noupdate /fractal_control_testbench/Fractal_control_i/im_part_in
add wave -noupdate /fractal_control_testbench/Fractal_control_i/re_part_in
add wave -noupdate /fractal_control_testbench/Fractal_control_i/clock
add wave -noupdate /fractal_control_testbench/Fractal_control_i/fractal_accelerator_i/fifo_in_i/q
add wave -noupdate {/fractal_control_testbench/Fractal_control_i/fractal_accelerator_i/pipes_i/gen_node[0]/divergence_node_i/data_in}
add wave -noupdate {/fractal_control_testbench/Fractal_control_i/fractal_accelerator_i/pipes_i/gen_node[1]/divergence_node_i/data_in}
add wave -noupdate {/fractal_control_testbench/Fractal_control_i/fractal_accelerator_i/pipes_i/gen_node[2]/divergence_node_i/data_in}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {60325 ps} 0}
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
configure wave -griddelta 20
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {60234 ps} {62234 ps}
