module part_2(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;
	
	adder_curcuit u0(
			.cin(SW[0]),
			.A(SW[4:1]),
			.B(SW[8:5]),
			.S(LEDR[6:0]),
			.cout(LEDR[7])
			);
endmodule

module adder_curcuit(X, Y, cin, S, cout);
	input [7:0]X;
	input [7:0]Y;
	input cin;
	output [6:0]S;
	output cout;
		
	wire Carry_wire0, Carry_wire1, Carry_wire2, Carry_wire3, Carry_wire4, Carry_wire5;
	
	eight_bit_adder_piece f0(
			.a(X[0]),
			.b(Y[0]),
			.cin(cin),
			.cout(Carry_wire0),
			.s(S[0])
			);
	
	eight_bit_adder_piece f1(
			.a(X[1]),
			.b(Y[1]),
			.cin(Carry_wire0),
			.cout(Carry_wire1),
			.s(S[1])
			);
	
	eight_bit_adder_piece f2(
			.a(X[2]),
			.b(Y[2]),
			.cin(Carry_wire1),
			.cout(Carry_wire2),
			.s(S[2])
			);
			
	eight_bit_adder_piece f3(
			.a(X[3]),
			.b(Y[3]),
			.cin(Carry_wire2),
			.cout(Carry_wire3),
			.s(S[3])
			);
			
	eight_bit_adder_piece f4(
			.a(X[4]),
			.b(Y[4]),
			.cin(Carry_wire3),
			.cout(Carry_wire4),
			.s(S[4])
			);
	
	eight_bit_adder_piece f5(
			.a(X[5]),
			.b(Y[5]),
			.cin(Carry_wire4),
			.cout(Carry_wire5),
			.s(S[5])
			);
	
	eight_bit_adder_piece f6(
			.a(X[6]),
			.b(Y[6]),
			.cin(Carry_wire5),
			.cout(cout),
			.s(S[6])
			);
		
endmodule

module eight_bit_adder_piece(a, b, cin, cout, s);
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
