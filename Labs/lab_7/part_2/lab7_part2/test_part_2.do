vlib work

vlog -timescale 1ns/1ns part2.v

vsim part_2

log {/*}
add wave {/*}

force {KEY[0]} 0 0, 1 20
force {CLOCK_50} 1 0, 0 10 -r 20
force {KEY[3]} 1 0, 0 40, 1 60, 0 520, 1 540
force {KEY[1]} 1 0, 0 80, 1 100, 0 580, 1 600
force {SW[6:0]} 0000000 0, 0000001 20, 0001111 60, 0011000 480, 0000111 520
force {SW[9:7]} 000 0, 100 20, 001 480
run 1000ns
