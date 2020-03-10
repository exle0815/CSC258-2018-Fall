module part_3(SW, KEY, LEDR);
	input [9:0] SW, KEY;
	output [9:0] LEDR;
	
	Shifter p0(
			.Load_Val(SW[7:0]),
			.Load_n(KEY[1]),
			.ShiftRight(KEY[2]),
			.ASR(KEY[3]),
			.Clk(KEY[0]),
			.Reset_n(SW[9]),
			.Q(LEDR[7:0])
			);

endmodule

module Shifter(Load_Val, Load_n, ShiftRight, ASR, Clk, Reset_n, Q);
	input [7:0] Load_Val;
	input Load_n, ShiftRight, ASR, Clk, Reset_n;
	output [7:0] Q;
	
	wire [7:0] out_in;
	
	sign_extension s0(
			.A(1'b0),
			.B(1'b1),
			.asr(ASR),
			.shift(ShiftRight),
			.clk(Clk),
			.reset_n(Reset_n),
			.Result(out_in[0])
			);
	
	shifterbit s1(
			.load_val(Load_Val[7]),
			.load_n(Load_n),
			.shift(ShiftRight),
			.clk(Clk),
			.reset_n(Reset_n),
			.in(out_in[0]),
			.q0(Q[7]),
			.q1(out_in[1])
			);
	
	shifterbit s2(
			.load_val(Load_Val[6]),
			.load_n(Load_n),
			.shift(ShiftRight),
			.clk(Clk),
			.reset_n(Reset_n),
			.in(out_in[1]),
			.q0(Q[6]),
			.q1(out_in[2])
			);
			
	shifterbit s3(
			.load_val(Load_Val[5]),
			.load_n(Load_n),
			.shift(ShiftRight),
			.clk(Clk),
			.reset_n(Reset_n),
			.in(out_in[2]),
			.q0(Q[5]),
			.q1(out_in[3])
			);
			
	shifterbit s4(
			.load_val(Load_Val[4]),
			.load_n(Load_n),
			.shift(ShiftRight),
			.clk(Clk),
			.reset_n(Reset_n),
			.in(out_in[3]),
			.q0(Q[4]),
			.q1(out_in[4])
			);
			
	shifterbit s5(
			.load_val(Load_Val[3]),
			.load_n(Load_n),
			.shift(ShiftRight),
			.clk(Clk),
			.reset_n(Reset_n),
			.in(out_in[4]),
			.q0(Q[3]),
			.q1(out_in[5])
			);
			
	shifterbit s6(
			.load_val(Load_Val[2]),
			.load_n(Load_n),
			.shift(ShiftRight),
			.clk(Clk),
			.reset_n(Reset_n),
			.in(out_in[5]),
			.q0(Q[2]),
			.q1(out_in[6])
			);
			
	shifterbit s7(
			.load_val(Load_Val[1]),
			.load_n(Load_n),
			.shift(ShiftRight),
			.clk(Clk),
			.reset_n(Reset_n),
			.in(out_in[6]),
			.q0(Q[1]),
			.q1(out_in[7])
			);
			
	shifterbit s8(
			.load_val(Load_Val[0]),
			.load_n(Load_n),
			.shift(ShiftRight),
			.clk(Clk),
			.reset_n(Reset_n),
			.in(out_in[7]),
			.q0(Q[0]),
			.q1()
			);
			
endmodule

module sign_extension(A, B, asr, shift, clk, reset_n, Result);
	input A, B, asr, shift, clk, reset_n;
	output Result;
	wire ars_to_mux, out_to_in0, data_to_dff;
   
	mux2to1 b0(
			.a(A),
			.b(B),
			.sel(asr),
			.r(ars_to_mux)
			);
	
	mux2to1 b1(
			.a(out_to_in0),
			.b(ars_to_mux),
			.sel(shift),
			.r(data_to_dff)
			);
	
	flipflop b2(
			.d(data_to_dff),
			.clock(clk),
			.reset_in_dff(reset_n),
			.flip_out0(Result),
			.flip_out1(out_to_in0),
			.flip_out2()
			);
	
endmodule
	
module shifterbit(load_val, load_n, shift, clk, reset_n, in, q0, q1);
	input load_val, load_n, shift, clk, reset_n, in;
	output q0, q1;
	
	wire out_to_in, mux_to_mux, data_to_dff;
		
	mux2to1 x0(
			.a(out_to_in),
			.b(in),
			.sel(shift),
			.r(mux_to_mux)
			);
	
	mux2to1 x1(
			.a(load_val),
			.b(mux_to_mux),
			.sel(load_n),
			.r(data_to_dff)
			);
	
	flipflop x2(
			.d(data_to_dff),
			.clock(clk),
			.reset_in_dff(reset_n),
			.flip_out0(q0),
			.flip_out1(q1),
			.flip_out2(out_to_in)
			);

endmodule

module mux2to1(a, b, sel, r);
	input a, b, sel;
	output r;
	assign r = (a & ~sel)|(b & sel);

endmodule

module flipflop(d, clock, reset_in_dff, flip_out0, flip_out1, flip_out2);
	input d, clock, reset_in_dff;
	output flip_out0, flip_out1, flip_out2;
	
	reg out;
	
	always @(posedge clock)
	
	begin
	
		if (reset_in_dff == 1'b0)
		
			out <= 1'b0;
			
		else
		
			out <= d;
			
	end
	
	assign flip_out0 = out;
	assign flip_out1 = out;
	assign flip_out2 = out;

endmodule
