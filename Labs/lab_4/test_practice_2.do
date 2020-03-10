vlib work

vlog -timescale 1ns/1ns practice_2.v

vsim practice_2

log {/*}
add wave {/*}

force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 1
force {SW[3]} 1
run 10ns