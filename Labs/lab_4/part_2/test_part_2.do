vlib work

vlog -timescale 1ns/1ns part_2.v

vsim part_2

log {/*}
add wave {/*}

#0 Reset case
force {SW[0]} 0 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 0
force {KEY[0]} 1
run 10ns

#1 
force {SW[0]} 0 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 0
force {KEY[0]} 0
run 10ns

#2 for A + 1 and A + B cases
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#3
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0 
run 10ns

#4
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#5
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns

#6
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#7
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns

#8 case for Verilog operation '+'
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 1
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#9
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 1
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns

#10 operation xor or or
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 1
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#11
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 1
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns

#12 case for contain 1 or not
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#13
force {SW[0]} 1 
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns

#14
force {SW[0]} 0
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#15 case for is it really not reset when key is not rising
force {SW[0]} 0
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 0
force {KEY[0]} 0
run 10ns

#16 case for left shift
force {SW[0]} 1
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 0
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#17
force {SW[0]} 1
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 0
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns

#18 case for reset
force {SW[0]} 1
force {SW[1]} 1 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 1
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 0
force {KEY[0]} 1
run 10ns

#19
force {SW[0]} 1
force {SW[1]} 1 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 1
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 0
force {KEY[0]} 0
run 10ns

#20 case for addition
force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#21
force {SW[0]} 1
force {SW[1]} 1 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns

#22 case for addition
force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#23
force {SW[0]} 1
force {SW[1]} 1 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns

#24 case for operation '*'
force {SW[0]} 0
force {SW[1]} 1 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 1
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#25
force {SW[0]} 0
force {SW[1]} 1 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 1
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns

#26 case for right shift
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 1
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#27
force {SW[0]} 0
force {SW[1]} 0 
force {SW[2]} 0
force {SW[3]} 0 
force {SW[5]} 0
force {SW[6]} 1
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns

#27 case for last stored data
force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 1
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 1
run 10ns

#28
force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 1
force {SW[3]} 0 
force {SW[5]} 1
force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1
force {KEY[0]} 0
run 10ns