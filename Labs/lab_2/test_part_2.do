vlib work

vlog -timescale 1ns/1ns part_2.v

vsim part_2 

log {/*}
add wave {/*}

force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 1
force {SW[3]} 1
force {SW[4]} 1
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
run 20ns