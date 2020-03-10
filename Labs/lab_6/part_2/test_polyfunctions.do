vlib work

vlog -timescale 1ns/1ns poly_function_modified.v

vsim control

log {/*}
add wave {/*}
#1 reset phase
force {go} 0
force {resetn} 0
force {clk} 1
run 10ns

force {go} 0
force {resetn} 0
force {clk} 0
run 10ns

#2 a
force {go} 0
force {resetn} 1
force {clk} 1
run 10ns

force {go} 0
force {resetn} 1
force {clk} 0
run 10ns

#3 a wait
force {go} 1
force {resetn} 1
force {clk} 1
run 10ns

force {go} 1
force {resetn} 1
force {clk} 0
run 10ns

#4 b 
force {go} 0
force {resetn} 1
force {clk} 1
run 10ns

force {go} 0
force {resetn} 1
force {clk} 0
run 10ns

#5 b wait
force {go} 1
force {resetn} 1
force {clk} 1
run 10ns

force {go} 1
force {resetn} 1
force {clk} 0
run 10ns

#6 c
force {go} 0
force {resetn} 1
force {clk} 1
run 10ns

force {go} 0
force {resetn} 1
force {clk} 0
run 10ns

#7 c wait
force {go} 1
force {resetn} 1
force {clk} 1
run 10ns

force {go} 1
force {resetn} 1
force {clk} 0
run 10ns

#8 x
force {go} 0
force {resetn} 1
force {clk} 1
run 10ns

force {go} 0
force {resetn} 1
force {clk} 0
run 10ns

#9 x wait
force {go} 1
force {resetn} 1
force {clk} 1
run 10ns

force {go} 1
force {resetn} 1
force {clk} 0
run 10ns

#10 cycle_0
force {go} 0
force {resetn} 1
force {clk} 1
run 10ns

force {go} 0
force {resetn} 1
force {clk} 0
run 10ns

#11 cycle_1
force {go} 1
force {resetn} 1
force {clk} 1
run 10ns

force {go} 1
force {resetn} 1
force {clk} 0
run 10ns

#12 cycle_2
force {go} 1
force {resetn} 1
force {clk} 1
run 10ns

force {go} 1
force {resetn} 1
force {clk} 0
run 10ns

#12 cycle_3
force {go} 1
force {resetn} 1
force {clk} 1
run 10ns

force {go} 1
force {resetn} 1
force {clk} 0
run 10ns

#13 cycle_4
force {go} 1
force {resetn} 1
force {clk} 1
run 10ns

force {go} 1
force {resetn} 1
force {clk} 0
run 10ns

#14 answer
force {go} 1
force {resetn} 0
force {clk} 1
run 10ns

force {go} 1
force {resetn} 0
force {clk} 0
run 10ns

#14 answer
force {go} 1
force {resetn} 1
force {clk} 1
run 10ns

force {go} 1
force {resetn} 1
force {clk} 0
run 10ns
