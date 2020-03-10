vlib work

vlog -timescale 1ns/1ns seven_seg_decoder.v

vsim seven_seg_decoder

log {/*}
add wave {/*}

#1st test case A
force {C[0]} 0
force {C[1]} 1
force {C[2]} 0
force {C[3]} 1
run 10ns

#2nd test case B
force {C[0]} 1
force {C[1]} 1
force {C[2]} 0
force {C[3]} 1
run 10ns

#3rd test case C
force {C[0]} 0
force {C[1]} 0
force {C[2]} 1
force {C[3]} 1
run 10ns

#4th test case 1
force {C[0]} 1
force {C[1]} 0
force {C[2]} 0
force {C[3]} 0
run 10ns

#5th test case 2
force {C[0]} 0
force {C[1]} 1
force {C[2]} 0
force {C[3]} 0
run 10ns

#6th test case 3
force {C[0]} 1
force {C[1]} 1
force {C[2]} 0
force {C[3]} 0
run 10ns