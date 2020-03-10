vlib work

vlog -timescale 1ns/1ns count.v

vsim count

log {/*}
add wave {/*}

force {reset} 0 0, 1 10
force {clock} 1 0, 0 5 -r 10
force {enable} 0 0, 1 70
run 30000ns