vlib work

vlog -timescale 1ns/1ns part_3.v

vsim datapath

log {/*}
add wave {/*}

force {ld_x} 1 0, 0 60
force {ld_y} 0 0, 1 80, 0 100
force {ld_colour} 0 0, 1 120
force {enable} 0 0, 1 120
force {resetn} 0 0ns, 1 20 
force {clock} 1 0, 0 10 -r 20
force {coord_in} 0000000 0, 0000001 20, 0001111 60
force {colour_in} 000 0, 100 20
run 600ns