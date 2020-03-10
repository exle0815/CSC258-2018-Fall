module part_3(SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [9:0] SW;
	input [9:0] KEY;
	output [9:0] LEDR;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
		
   arithmetic_logic_unit a0(
			.A(SW[7:4]),
			.B(SW[3:0]),
			.Function(KEY[2:0]),
			.ALUout(LEDR[7:0]),
			.hexout0(HEX0[6:0]),
			.hexout1(HEX1[6:0]),
			.hexout2(HEX2[6:0]),
			.hexout3(HEX3[6:0]),
			.hexout4(HEX4[6:0]),
			.hexout5(HEX5[6:0])
			);

endmodule

module arithmetic_logic_unit(A, B, Function, ALUout, hexout0, hexout1, hexout2, hexout3, hexout4, hexout5);
	input [3:0]A;
	input [3:0]B;
	input [2:0]Function;
	output [7:0]ALUout;
	output [6:0]hexout0;
	output [6:0]hexout1;
	output [6:0]hexout2;
	output [6:0]hexout3;
	output [6:0]hexout4;
	output [6:0]hexout5;
	
	wire [3:0]Connection0_0, Connection1_0;
	wire Connection0_1, connection1_1;
	wire [7:0] Connection2, Connection3, Connection4, Connection5, value_to_hex;
	
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
			.S(Connection1_0),
			.cout(Connection1_1)
			);
	
	arithmetic_op u2(
			.X(A[3:0]),
			.Y(B[3:0]),
			.S(Connection2)
			);
			
	xor_or u3(
			.X(A[3:0]),
			.Y(B[3:0]),
			.S(Connection3)
			);
	
	one_or_zero u4(
			.X(A[3:0]),
			.Y(B[3:0]),
			.S(Connection4)
			);
	
	Input_equals_output u5(
			.X(A[3:0]),
			.Y(B[3:0]),
			.S(Connection5)
			);
	
	mux6to1 u6(
			.u00(Connection0_0[3:0]),
			.u01(Connection0_1),
			.u10(Connection1_0[3:0]),
			.u11(Connection1_1),
			.u2(Connection2[7:0]),
			.u3(Connection3[7:0]),
			.u4(Connection4[7:0]),
			.u5(Connection5[7:0]),
			.sel(Function[2:0]),
			.out(ALUout[7:0])
			);
			
	value_to_HEX v1(
			.C(B[3:0]),
			.m(hexout0[6:0])
			);
		
	value_to_HEX v2(
			.C(4'b0000),
			.m(hexout1[6:0])
			);
	
	value_to_HEX v3(
			.C(A[3:0]),
			.m(hexout2[6:0])
			);
			
	value_to_HEX v4(
			.C(4'b0000),
			.m(hexout3[6:0])
			);
	
	value_to_HEX v5(
			.C(value_to_hex[3:0]),
			.m(hexout4[6:0])
			);
	
	value_to_HEX v6(
			.C(value_to_hex[3:0]),
			.m(hexout5[6:0])
			);

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

module arithmetic_op(X, Y, S);
	input [3:0]X;
	input [3:0]Y;
	output [7:0]S;
	
	assign S = X + Y;

endmodule

module xor_or(X, Y, S);
	input [3:0]X;
	input [3:0]Y;
	output [7:0]S;
	
	assign S = {(X|Y), (X^Y)};
	
endmodule

module one_or_zero(X, Y, S);
	input [3:0]X;
	input [3:0]Y;
	output [7:0]S;
	
	assign S = {7'b0000000, |{X, Y}};

endmodule

module Input_equals_output(X, Y, S);
	input [3:0]X;
	input [3:0]Y;
	output [7:0]S;
	
	assign S = {X, Y};

endmodule

module mux6to1(u00, u01, u10, u11, u2, u3, u4, u5, sel, out);
	input u00;
	input u01;
	input u10;
	input u11;
	input u2;
	input u3;
	input u4;
	input u5;
	input [2:0]sel;
	output [7:0]out;
	
	reg [7:0]out;

	always @(*)
	begin
		case (sel[2:0])
			3'b000: out = {3'b000, u01, u00};
			3'b001: out = {3'b000, u11, u10};
			3'b010: out = u2;
			3'b011: out = u3;
			3'b100: out = u4;
			3'b101: out = u5;
			default: out = 8'b00000000;
		endcase
	end

endmodule

module value_to_HEX(C, m);
	input [3:0]C;
	output [6:0]m;
	
	assign m[0] = (~C[3]&~C[2]&~C[1]&C[0])|(~C[3]&C[2]&~C[1]&~C[0])|(C[3]&C[2]&~C[1]&C[0])|(C[3]&~C[2]&C[1]&C[0]);
	assign m[1] = (~C[3]&C[2]&~C[1]&C[0])|(C[2]&C[1]&~C[0])|(C[3]&C[1]&C[0])|(C[3]&C[2]&~C[0]);
	assign m[2] = (~C[3]&~C[2]&C[1]&~C[0])|(C[3]&C[2]&C[1])|(C[3]&C[2]&~C[0]);
	assign m[3] = (~C[2]&~C[1]&C[0])|(C[2]&C[1]&C[0])|(~C[3]&C[2]&~C[1]&~C[0])|(C[3]&~C[2]&C[1]&~C[0]);
	assign m[4] = (~C[2]&~C[1]&C[0])|(~C[3]&C[2]&~C[1])|(~C[3]&C[1]&C[0]);
	assign m[5] = (~C[3]&~C[2]&C[0])|(~C[3]&~C[2]&C[1])|(~C[3]&C[1]&C[0])|(C[3]&C[2]&~C[1]&C[0]);
	assign m[6] = (~C[3]&~C[2]&~C[1])|(~C[3]&C[2]&C[1]&C[0])|(C[3]&C[2]&~C[1]&~C[0]);
	
endmodule
	
