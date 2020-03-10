vlib work

vlog -timescale 1ns/1ns part2_save.v

vsim simulation

log {/*}
add wave {/*}

force {resetn} 0 0, 1 20
force {clock} 1 0, 0 10 -r 20
force {go_1} 0 0, 1 40, 0 60, 1 520, 0 540
force {go_2} 0 0, 1 80, 0 100, 1 580, 0 600
force {coord_in} 0000000 0, 0000001 20, 0001111 80, 0011000 460, 0000111 560
force {colour_in} 000 0, 100 20, 001 480
run 1000ns