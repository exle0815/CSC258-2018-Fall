vlib work

vlog -timescale 1ns/1ns poly_function_modified.v

vsim poly_function_modified

log {/*}
add wave {/*}

#1 reset phase
#data input
force {SW[7:0]} 00000100
#reset
force {KEY[0]} 0
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000100
#reset
force {KEY[0]} 0
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns

#2 load A
#data input
force {SW[7:0]} 00000101
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000101
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns

#2 load A
#data input
force {SW[7:0]} 00000101
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 0
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000101
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 0
force {CLOCK_50} 0
run 10ns

#3 load A wait
#data input
force {SW[7:0]} 00000101
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000101
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns

#4 load B
#data input
force {SW[7:0]} 00000011
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 0
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000011
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 0
force {CLOCK_50} 0
run 10ns

#5 load B wait
#data input
force {SW[7:0]} 00000011
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000011
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns

#6 load C
#data input
force {SW[7:0]} 00000100
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 0
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000100
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 0
force {CLOCK_50} 0
run 10ns

#7 load C wait
#data input
force {SW[7:0]} 00000100
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000100
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns

#8 load X
#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 0
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 0
force {CLOCK_50} 0
run 10ns

#9 load x wait
#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns

#10 Cycle 0
#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 0
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 0
force {CLOCK_50} 0
run 10ns

#10 Cycle 1
#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns

force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns

#10 Cycle 2
#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns

#10 Cycle 3
#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns
#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns

#10 Cycle 4
#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 1
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns

#10 reset
#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 0
#~go
force {KEY[1]} 1
force {CLOCK_50} 1
run 10ns

#data input
force {SW[7:0]} 00000010
#reset
force {KEY[0]} 0
#~go
force {KEY[1]} 1
force {CLOCK_50} 0
run 10ns