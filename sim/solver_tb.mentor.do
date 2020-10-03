onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider arena
add wave -noupdate /solver_tb/u_arena/a_clk
add wave -noupdate /solver_tb/u_arena/a_row
add wave -noupdate /solver_tb/u_arena/a_columns_out
add wave -noupdate /solver_tb/u_arena/b_clk
add wave -noupdate /solver_tb/u_arena/b_row
add wave -noupdate /solver_tb/u_arena/b_columns_in
add wave -noupdate /solver_tb/u_arena/b_columns_out
add wave -noupdate /solver_tb/u_arena/b_write
add wave -noupdate /solver_tb/u_arena/a_columns_out_reg
add wave -noupdate /solver_tb/u_arena/b_columns_out_reg
add wave -noupdate -divider dut
add wave -noupdate /solver_tb/uut/clk
add wave -noupdate /solver_tb/uut/reset
add wave -noupdate /solver_tb/uut/start
add wave -noupdate /solver_tb/uut/ready
add wave -noupdate /solver_tb/uut/generations_count
add wave -noupdate /solver_tb/uut/arena_row_select
add wave -noupdate /solver_tb/uut/arena_columns
add wave -noupdate /solver_tb/uut/arena_columns_new
add wave -noupdate /solver_tb/uut/arena_columns_write
add wave -noupdate /solver_tb/uut/busy
add wave -noupdate /solver_tb/uut/busy_next
add wave -noupdate /solver_tb/uut/ticks
add wave -noupdate /solver_tb/uut/ticks_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {163500 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {258300 ps}
