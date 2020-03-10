vlib work

vlog -timescale 1ns/1ns seven_to_one_mux.v

vsim mux7to1 

add wave {/*}

force {Input[0]} 1
force {Input[1]} 0 
force {Input[2]} 0 
force {Input[3]} 0 
force {Input[4]} 0 
force {Input[5]} 0 
force {Input[6]} 0 
force {MuxSelect[0]} 0 
force {MuxSelect[1]} 0 
force {MuxSelect[2]} 0 
run 10 ns

force {Input[0]} 0
force {Input[1]} 0 
force {Input[2]} 0 
force {Input[3]} 0 
force {Input[4]} 0 
force {Input[5]} 0 
force {Input[6]} 0 
force {MuxSelect[0]} 0 
force {MuxSelect[1]} 0 
force {MuxSelect[2]} 0 
run 10 ns

force {Input[0]} 0
force {Input[1]} 0 
force {Input[2]} 0 
force {Input[3]} 1 
force {Input[4]} 1
force {Input[5]} 0 
force {Input[6]} 0 
force {MuxSelect[0]} 1
force {MuxSelect[1]} 0 
force {MuxSelect[2]} 0 
run 10 ns

force {Input[0]} 0
force {Input[1]} 1 
force {Input[2]} 0 
force {Input[3]} 0 
force {Input[4]} 0 
force {Input[5]} 0 
force {Input[6]} 0 
force {MuxSelect[0]} 1 
force {MuxSelect[1]} 0 
force {MuxSelect[2]} 0 
run 10 ns

force {Input[0]} 0
force {Input[1]} 0 
force {Input[2]} 1 
force {Input[3]} 0 
force {Input[4]} 0 
force {Input[5]} 0 
force {Input[6]} 0 
force {MuxSelect[0]} 0 
force {MuxSelect[1]} 1
force {MuxSelect[2]} 0 
run 10 ns
