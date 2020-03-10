vlib work

vlog -timescale 1ns/1ns project_lab.v

vsim project

log {/*}
add wave {/*}

force {KEY[0]} 0 0, 1 20
force {KEY[1]} 1 0, 0 4030, 1 4040
force {CLOCK_50} 1 0, 0 5 -r 10
run 600000ns