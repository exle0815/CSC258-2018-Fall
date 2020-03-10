vlib work

vlog -timescale 1ns/1ns project_updated2.v

vsim control

log {/*}
add wave {/*}

force {reset} 0 0, 1 20
force {go} 0 0, 1 30, 0 40
force {clock} 1 0, 0 5 -r 10
force {rotation} 0
force {stop} 0 0, 1 200, 0 210
run 100000ns