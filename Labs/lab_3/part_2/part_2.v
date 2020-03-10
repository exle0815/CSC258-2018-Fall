module part_2(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;
	
	four_bit_adder u0(
			.cin(SW[8]),
			.A(SW[3:0]),
			.B(SW[7:4]),
			.S(LEDR[3:0]),
			.cout(LEDR[4])
			);
endmodule

module four_bit_adder(cin, A, B, S, cout);
	input cin;
	input [3:0]A;
	input [3:0]B;
	output [3:0]S;
	output cout;
	
	wire Carry_wire0, Carry_wire1, Carry_wire2;
	
	four_bit_adder_piece f0(
			.a(A[0]),
			.b(B[0]),
			.cin(cin),
			.cout(Carry_wire0),
			.s(S[0])
			);
	
	four_bit_adder_piece f1(
			.a(A[1]),
			.b(B[1]),
			.cin(Carry_wire0),
			.cout(Carry_wire1),
			.s(S[1])
			);
	
	four_bit_adder_piece f2(
			.a(A[2]),
			.b(B[2]),
			.cin(Carry_wire1),
			.cout(Carry_wire2),
			.s(S[2])
			);
			
	four_bit_adder_piece f3(
			.a(A[3]),
			.b(B[3]),
			.cin(Carry_wire2),
			.cout(cout),
			.s(S[3])
			);
			
endmodule

module four_bit_adder_piece(a, b, cin, cout, s);
	input a;
	input b;
	input cin;
	output cout;
	output s;
	
	mux2to1 m0(
			.x(b),
			.y(cin),
			.sel(a^b),
			.m(cout)
			);
	
	assign s = (a^b)^cin;
	
endmodule

module mux2to1(x, y, sel, m);
	input x;
	input y;
	input sel;
	output m;
	
	assign m = (x&~sel) | (y&sel);
	
endmodule
