module practice(SW, KEY, LEDR);
	input [9:0] SW;
	input [9:0] KEY;
	output [9:0] LEDR;

	arithmetic_logic_unit a0(
			.A(SW[7:4]),
			.B(SW[3:0]),
			.Function(KEY[2:0]),
			.ALUout0(LEDR[3:0]),
			.ALUout1(LEDR[4])
			);

endmodule

module arithmetic_logic_unit(A, B, Function, ALUout0, ALUout1);
	input [3:0]A;
	input [3:0]B;
	input [2:0]Function;
	output [3:0]ALUout0;
	output ALUout1;
	
	wire [3:0]Connection0_0, Connection1_0;
	wire Connection0_1, Connection1_1;

	adder_curcuit u0(
			.X(A[3:0]),
			.Y(4'b0001),
			.cin(1'b0),
			.S(Connection0_0),
			.cout(Connection0_1)
			);
	
	adder_curcuit u1(
			.X(A[3:0]),
			.Y(B[3:0]),
			.cin(1'b0),
			.S(ALUout0[3:0]),
			.cout(ALUout1)
			);


endmodule

module combine(a, b, c, d, e);
	input [3:0]a;
	input b;
	input [3:0]c;
	input d;
	output [7:0]e;

	assign e = {3'b000, a, b, c, d};

endmodule


module adder_curcuit(X, Y, cin, S, cout);
	input [3:0]X;
	input [3:0]Y;
	input cin;
	output [3:0]S;
	output cout;
		
	wire Carry_wire0, Carry_wire1, Carry_wire2;
	
	four_bit_adder_piece f0(
			.a(X[0]),
			.b(Y[0]),
			.cin(cin),
			.cout(Carry_wire0),
			.s(S[0])
			);
	
	four_bit_adder_piece f1(
			.a(X[1]),
			.b(Y[1]),
			.cin(Carry_wire0),
			.cout(Carry_wire1),
			.s(S[1])
			);
	
	four_bit_adder_piece f2(
			.a(X[2]),
			.b(Y[2]),
			.cin(Carry_wire1),
			.cout(Carry_wire2),
			.s(S[2])
			);
			
	four_bit_adder_piece f3(
			.a(X[3]),
			.b(Y[3]),
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
	
	mux2to1 i0(
			.ma(b),
			.mb(cin),
			.muxsel(a^b),
			.r(cout)
			);
	
	assign s = (a^b)^cin;
	
endmodule

module mux2to1(ma, mb, muxsel, r);
	input ma;
	input mb;
	input muxsel;
	output r;
	
	assign r = (ma&~muxsel) | (mb&muxsel);
	
endmodule
