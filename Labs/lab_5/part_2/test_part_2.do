vlib work

vlog -timescale 1ns/1ns part_2.v

vsim part_2
#vsim display_counter

log {/*}
add wave {/*}

#sel0
force {SW[0]} 1
#sel1
force {SW[1]} 0
#par_load
force {SW[2]} 1 0ns, 0 30ns
#clear_b
force {SW[3]} 0 0ns, 1 10ns
force {CLOCK_50} 1 0ns, 0 10ns -r 20
run 1000000100ns

#force {en_display} 1
#force {clear_b} 0 0ns, 1 20ns 
#force {clk} 1 0ns, 0 10ns -r 20
#run 500ns