vlib work

vlog -timescale 1ns/1ns part_3_new.v

vsim part_3
#vsim mux8to1

log {/*}
add wave {/*}

force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 1
force {KEY[0]} 0
force {KEY[1]} 1 
force {CLOCK_50} 1 0ns, 0 5ns -r 10
run 10ns
#sel0
force {SW[0]} 1
#sel1
force {SW[1]} 1
#sel3
force {SW[2]} 1 
#clear_b
force {KEY[0]} 1
#start
force {KEY[1]} 0 0ns, 1 15ns
force {CLOCK_50} 1 0ns, 0 5ns -r 10
run 600ns

#force {sel[0]} 0
#force {sel[1]} 0
#force {sel[2]} 0
#run 10ns

#force {sel[0]} 1
#force {sel[1]} 0
#force {sel[2]} 0
#run 10ns

