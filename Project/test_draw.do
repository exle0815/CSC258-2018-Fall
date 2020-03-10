vlib work

vlog -timescale 1ns/1ns draw.v

vsim erase

log {/*}
add wave {/*}

force {reset} 0 0, 1 20
force {clock} 1 0, 0 5 -r 10
force {enable} 0 0, 1 20
force {new_coord} 15'b0 0, 15'b000101000010100 20
run 5000ns