module adder_subtraction(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;
	
	four_bit_adder u0(
			.Sub0(SW[0]),
			.Sub1(SW[0]),
			.A(SW[4:1]),
			.B(SW[8:5]),
			.S(LEDR[3:0]),
			.cout(LEDR[4])
			);
endmodule

module four_bit_adder(Sub0, Sub1, A, B, S, cout);
	input Sub0;
	input Sub1;
	input [3:0]A;
	input [3:0]B;
	output [3:0]S;
	output cout;
	
	wire Carry_wire0, Carry_wire1, Carry_wire2;
	
	four_bit_adder_piece f0(
			.a(A[0]),
			.b(B[0]),
			.cin0(Sub0),
			.cin1(Sub1),
			.cout(Carry_wire0),
			.s(S[0])
			);
	
	four_bit_adder_piece f1(
			.a(A[1]),
			.b(B[1]),
			.cin0(Sub0),
			.cin1(Carry_wire0),
			.cout(Carry_wire1),
			.s(S[1])
			);
	
	four_bit_adder_piece f2(
			.a(A[2]),
			.b(B[2]),
			.cin0(Sub0),
			.cin1(Carry_wire1),
			.cout(Carry_wire2),
			.s(S[2])
			);
			
	four_bit_adder_piece f3(
			.a(A[3]),
			.b(B[3]),
			.cin0(Sub0),
			.cin1(Carry_wire2),
			.cout(cout),
			.s(S[3])
			);
	
endmodule

module four_bit_adder_piece(a, b, cin0, cin1, cout, s);
	input a;
	input b;
	input cin0;
	input cin1;
	output cout;
	output s;
	
	mux2to1 m0(
			.x(b^cin0),
			.y(cin1),
			.sel(a^(b^cin0)),
			.m(cout)
			);
	
	assign s = (a^(b^cin0))^cin1;
	
endmodule

module mux2to1(x, y, sel, m);
	input x;
	input y;
	input sel;
	output m;
	
	assign m = (x&~sel) | (y&sel);
	
endmodule
