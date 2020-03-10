vlib work

vlog -timescale 1ns/1ns LFSR.v

vsim random

log {/*}
add wave {/*}

force {random_reset} 0 0, 1 20
force {random_clock} 1 0, 0 5 -r 10
run 500ns