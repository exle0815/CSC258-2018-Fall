vlib work

vlog -timescale 1ns/1ns random.v

vsim random

log {/*}
add wave {/*}

force {reset} 0 0, 1 10
force {clock} 1 0, 0 5 -r 10
run 5000ns