vlib work

vlog -timescale 1ns/1ns lfsr_with_enable.v

vsim random

log {/*}
add wave {/*}

force {random_reset} 0 0, 1 20
force {random_clock} 1 0, 0 5 -r 10
force {random_en} 0 0, 1 30, 0 40, 1 70, 0 80, 1 110, 0 120
run 500ns