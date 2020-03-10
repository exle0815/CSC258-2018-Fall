vlib work

vlog -timescale 1ns/1ns module_test.v

vsim test

log {/*}
add wave {/*}

force {reset} 0 0, 1 10
force {clock} 1 0, 0 5 -r 10
force {enable} 0 0, 1 70 0 8070, 1 8090
force {direction} 00 0
force {colour_in} 100 0
force {capture} 0 0, 1 40, 0 50, 1 8070, 0 8080
force {increment} 0 0, 1 60, 0 70, 1 8080, 0 8090
force {ld_blk1} 0 0, 1 60, 0 70
force {ld_blk2} 0 0, 1 8080, 0 8090
force {ld_blk3} 0 0
force {ld_blk4} 0 0
force {ld_blk5} 0 0
force {ld_blk6} 0 0
force {ld_blk7} 0 0
force {ld_blk8} 0 0
force {ld_blk9} 0 0
force {ld_blk10} 0 0
run 15000ns
