onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /node_testbench/clk
add wave -noupdate -radix unsigned /node_testbench/reset_n
add wave -noupdate -radix unsigned /node_testbench/start
add wave -noupdate -radix unsigned /node_testbench/stimu
add wave -noupdate -radix unsigned /node_testbench/u_in_bottom
add wave -noupdate -radix unsigned /node_testbench/u_in_left
add wave -noupdate -radix unsigned /node_testbench/u_in_right
add wave -noupdate -radix unsigned /node_testbench/u_in_top
add wave -noupdate -format Analog-Step -height 200 -max 105912.0 -min -107453.0 -radix decimal /node_testbench/u_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1720000 ps} 0} {{Cursor 2} {17900 ps} 0} {{Cursor 3} {35700 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 256
configure wave -valuecolwidth 148
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3263400 ps} {10354600 ps}
