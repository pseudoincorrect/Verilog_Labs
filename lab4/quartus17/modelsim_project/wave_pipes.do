onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /pipes_testbench/real_part_in
add wave -noupdate /pipes_testbench/data_in_write
add wave -noupdate -radix hexadecimal /pipes_testbench/imaginary_part_in
add wave -noupdate /pipes_testbench/clock
add wave -noupdate /pipes_testbench/x_coord_out
add wave -noupdate /pipes_testbench/y_coord_out
add wave -noupdate /pipes_testbench/interation_count
add wave -noupdate /pipes_testbench/is_in_the_set
add wave -noupdate /pipes_testbench/clock
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21346 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 198
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
WaveRestoreZoom {0 ps} {62720 ps}
