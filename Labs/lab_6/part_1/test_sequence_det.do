vlib work

vlog -timescale 1ns/1ns sequence_detector.v

vsim sequence_detector

log {/*}
add wave {/*}

#1st cycle(reset)
force {SW[0]} 0
force {SW[1]} 0
force {KEY[0]} 0 
run 10ns

force {SW[0]} 0
force {SW[1]} 0
force {KEY[0]} 1 
run 10ns

#2nd(w = 0)
force {SW[0]} 1
force {SW[1]} 0
force {KEY[0]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 0
force {KEY[0]} 1 
run 10ns

#3rd(w = 1)
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 1
run 10ns

#4th(w = 1)
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 1
run 10ns

#5th(w = 1)
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 1
run 10ns

#6th(w = 1) (1111)
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 1
run 10ns

#7th(w = 1) (1111)
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 1
run 10ns

#8th(w = 0) (1110)
force {SW[0]} 1
force {SW[1]} 0
force {KEY[0]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 0
force {KEY[0]} 1
run 10ns

#9th(w = 1) (1101)
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 1
run 10ns

#10th(w = 0) (1010)
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 1
run 10ns

#11th(reset)
force {SW[0]} 0
force {SW[1]} 1
force {KEY[0]} 0
run 10ns

force {SW[0]} 0
force {SW[1]} 1
force {KEY[0]} 1
run 10ns