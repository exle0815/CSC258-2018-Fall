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

	wire [3:0]Connection0_0, Connection1_0;
	wire Connection0_1, Connection1_1;
	wire [7:0] out_to_hex;
	
	adder_curcuit u0(
			.A(SW[7:4]),
			.B(4'b0001),
			.Sub0(SW[8]),
			.Sub1(SW[8]),
			.S(Connection0_0[3:0]),
			.cout(Connection0_1)
			);
	
	adder_curcuit u1(
			.A(SW[7:4]),
			.B(SW[3:0]),
			.cin0(SW[8]),
			.cin1(SW[8]),
			.S(Connection1_0[3:0]),
			.cout(Connection1_1)
			);
			
	mux6to1 u2(
			.a0(Connection0_0[3:0]),
			.a1(Connection0_1),
			.b0(Connection1_0[3:0]),
			.b1(Connection1_1),
			.A(SW[7:4]),
			.B(SW[3:0]),
			.Function(KEY[2:0]),
			.ALUout0(LEDR[7:0]),
			.ALUout1(out_to_hex[7:0])
			);

	value_to_HEX u3(
			.C(SW[3:0]),
			.m(HEX0[6:0])
			);
		
	value_to_HEX u4(
			.C(4'b0000),
			.m(HEX1[6:0])
			);
	
	value_to_HEX u5(
			.C(SW[7:4]),
			.m(HEX2[6:0])
			);
			
	value_to_HEX u6(
			.C(4'b0000),
			.m(HEX3[6:0])
			);
	
	value_to_HEX u7(
			.C(out_to_hex[3:0]),
			.m(HEX4[6:0])
			);
	
	value_to_HEX u8(
			.C(out_to_hex[7:4]),
			.m(HEX5[6:0])
			);
	
			
endmodule

module adder_curcuit(A, B, Sub0, Sub1, S, cout);
	input [3:0]A;
	input [3:0]B;
	input Sub0;
	input Sub1;
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
	
	mux2to1 i0(
			.ma(b^cin0),
			.mb(cin),
			.muxsel(a^(b^cin0)),
			.r(cout)
			);
	
	assign s = (a^(b^cin0))^cin;
	
endmodule

module mux2to1(ma, mb, muxsel, r);
	input ma;
	input mb;
	input muxsel;
	output r;
	
	assign r = (ma&~muxsel) | (mb&muxsel);
	
endmodule

module mux6to1(a0, a1, b0, b1, A, B, Function, ALUout0, ALUout1);
	input [3:0]a0, b0, A, B;
	input a1, b1;
	input [2:0]Function;
	output [7:0]ALUout0, ALUout1;
	
	reg [7:0]out;
	
	always @(*)
	begin
		case (Function[2:0])
			3'b000: out = {3'b000, a1, a0};
			3'b001: out = {3'b000, b1, b0};
			3'b010: out = A + B;
			3'b011: out = {(A|B), (A^B)};
			3'b100: out = {7'b0000000, |{A, B}};
			3'b101: out = {A, B};
			default: out = 8'b00000000;
		endcase
	end
	
	assign ALUout0 = out;
	assign ALUout1 = out;

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
