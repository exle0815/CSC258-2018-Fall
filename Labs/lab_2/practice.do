vlib work

vlog -timescale 1ns/1ns mux.v

vsim mux

log {/*}
add wave {/*}

force {SW[0]} 0 0, 1 20 -r 40
force {SW[1]} 0 0, 1 20 -r 40
force {SW[9]} 0 0, 1 20 -r 40
run