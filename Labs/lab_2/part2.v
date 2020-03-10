//SW[3:0] data inputs
//SW[9:8] select signal

//LEDR[0] output display

module mux4to1(LEDR, SW);
   input [9:0] SW;
	output [9:0] LEDR;
	wire Connection1;
	wire Connection2;

	mux2to1_1 u0(
		.u(SW[0]),
		.w(SW[1]),
		.s1(SW[8]),
		.out1(Connection1)
		);
		
	mux2to1_2 u1(
	    .v(SW[2]),
		.x(SW[3]),
		.s1(SW[8]),
		.out2(Connection2)
		);
		
	mux2to1_3 u3(
		.in1(Connection1),
		.in2(Connection2),
		.s0(SW[9]),
		.out3(LEDR[0])
		);
		
endmodule

module mux2to1_1(u, w, s1, out1);
	input u;
	input w;
	input s1;
	output out1;
	
	assign out1 = u & ~s1 | w & s1;

endmodule
	
module mux2to1_2(v, x, s1, out2);
	input v;
	input x;
	input s1;
	output out2;
	
	assign out2 = v & ~s1 | x & s1;

endmodule
	
module mux2to1_3(in1, in2, s0, out3);
	input in1;
	input in2;
	input s0;
	output out3;
	
	assign out3 = in1 & ~s0 | in2 & s0;
	
endmodule
