onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pipes_testbench/clock
add wave -noupdate /pipes_testbench/reset_n
add wave -noupdate -radix hexadecimal /pipes_testbench/real_part_in
add wave -noupdate -radix hexadecimal -childformat {{{/pipes_testbench/imaginary_part_in[31]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[30]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[29]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[28]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[27]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[26]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[25]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[24]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[23]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[22]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[21]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[20]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[19]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[18]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[17]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[16]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[15]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[14]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[13]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[12]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[11]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[10]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[9]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[8]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[7]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[6]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[5]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[4]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[3]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[2]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[1]} -radix hexadecimal} {{/pipes_testbench/imaginary_part_in[0]} -radix hexadecimal}} -subitemconfig {{/pipes_testbench/imaginary_part_in[31]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[30]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[29]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[28]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[27]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[26]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[25]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[24]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[23]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[22]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[21]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[20]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[19]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[18]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[17]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[16]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[15]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[14]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[13]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[12]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[11]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[10]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[9]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[8]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[7]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[6]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[5]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[4]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[3]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[2]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[1]} {-height 15 -radix hexadecimal} {/pipes_testbench/imaginary_part_in[0]} {-height 15 -radix hexadecimal}} /pipes_testbench/imaginary_part_in
add wave -noupdate /pipes_testbench/y_coord_in
add wave -noupdate /pipes_testbench/data_in_write
add wave -noupdate /pipes_testbench/data_in_full
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/data_in_read
add wave -noupdate /pipes_testbench/y_coord_out
add wave -noupdate /pipes_testbench/interation_count
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/fifo_node_rdreq
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/next_state_2_unload
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/node_select
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/busy_select
add wave -noupdate -expand /pipes_testbench/fractal_accelerator_i/pipes_i/node_busy
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/next_state_1_load
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/almost_full_select
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/mux_usedw_out
add wave -noupdate /pipes_testbench/clock
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/node_select
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/start_select
add wave -noupdate {/pipes_testbench/fractal_accelerator_i/pipes_i/node_start[2]}
add wave -noupdate {/pipes_testbench/fractal_accelerator_i/pipes_i/node_start[1]}
add wave -noupdate {/pipes_testbench/fractal_accelerator_i/pipes_i/node_start[0]}
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/clock
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/fifo_select
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/mux_usedw_out
add wave -noupdate /pipes_testbench/fractal_accelerator_i/pipes_i/write_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10420 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 262
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
WaveRestoreZoom {10118 ps} {13894 ps}
