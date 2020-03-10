vlib work

vlog -timescale 1ns/1ns part_3.v

vsim control

log {/*}
add wave {/*}

force {resetn} 0 0, 1 20
force {clock} 1 0, 0 10 -r 20
force {go_1} 0 0, 1 40, 0 60 -r 230
force {go_2} 0 0, 1 80, 0 100 -r 250
run 1000ns