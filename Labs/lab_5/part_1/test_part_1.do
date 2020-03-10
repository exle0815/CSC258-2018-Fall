vlib work

vlog -timescale 1ns/1ns part_1.v

vsim part_1

log {/*}
add wave {/*}

force {SW[1]} 0
force {SW[0]} 0 
force {KEY[0]} 0
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 1
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 0
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 1
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 0
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 1
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 0
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 1
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 0
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 1
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 0
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 1
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 0
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 1
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 0
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 1
run 10ns

force {SW[1]} 1
force {SW[0]} 1 
force {KEY[0]} 0
run 10ns

force {SW[1]} 0
force {SW[0]} 1 
force {KEY[0]} 1
run 10ns

force {SW[1]} 0
force {SW[0]} 1 
force {KEY[0]} 0
run 10ns

force {SW[1]} 0
force {SW[0]} 1
force {KEY[0]} 1
run 10ns

force {SW[1]} 0
force {SW[0]} 0
force {KEY[0]} 0
run 10ns