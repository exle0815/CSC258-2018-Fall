vlib work

vlog -timescale 1ns/1ns random_generator.v

vsim random_generator

log {/*}
add wave {/*}

force {random_reset} 0 0, 1 20
force {random_clock} 1 0, 0 5 -r 10
force {dir} 00
force {capture} 0 0, 1 30, 0 40, 1 90, 0 100, 1 160, 0 170, 1 240, 0 250, 1 310, 0 320, 1 350, 0 360, 1 520, 0 530, 1 580, 0 590, 1 620, 0 630
run 2000ns