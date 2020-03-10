module part_2(SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [9:0] SW;
	input [9:0] KEY;
	output [9:0] LEDR;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;

	wire [7:0] reg_to_hex, alu_to_reg, reg_to_alu;
	
	arithmetic_unit q0(
			.A(SW[3:0]),
			.B(reg_to_alu[3:0]),
			.Sub(SW[8]),
			.Function(SW[7:5]),
			.ALUout(alu_to_reg[7:0])
			);
			
	value_to_HEX q1(
			.C(SW[3:0]),
			.m(HEX0[6:0])
			);
		
	value_to_HEX_off q2(
			.C(4'b0000),
			.m(HEX1[6:0])
			);
	
	value_to_HEX_off q3(
			.C(SW[7:4]),
			.m(HEX2[6:0])
			);
			
	value_to_HEX_off q4(
			.C(4'b0000),
			.m(HEX3[6:0])
			);
	
	value_to_HEX q5(
			.C(reg_to_hex[3:0]),
			.m(HEX4[6:0])
			);
	
	value_to_HEX q6(
			.C(reg_to_hex[7:4]),
			.m(HEX5[6:0])
			);
	
	
	register q7(
			.clock(KEY[0]),
			.reg_in(alu_to_reg[7:0]),
			.reset_n(SW[9]),
			.reg_out0(LEDR[7:0]),
			.reg_out1(reg_to_alu[7:0]),
			.reg_out2(reg_to_hex[7:0])
			);
	
endmodule			

module register(clock, reg_in, reset_n, reg_out0, reg_out1, reg_out2);
	input clock, reset_n;
	input [7:0] reg_in;
	output [7:0] reg_out0, reg_out1, reg_out2;
	
	reg [7:0] out;
	
	always @(posedge clock)
	
	begin
		if (reset_n == 1'b0)
		
			out <= 8'b00000000;
			
		else
		
			out <= reg_in;
	end
	
	assign reg_out0 = out;
	assign reg_out1 = out;
	assign reg_out2 = out;
	
endmodule			

module value_to_HEX_off(C, m);
	input [3:0]C;
	output [6:0]m;
	
	assign m[0] = 1;
	assign m[1] = 1;
	assign m[2] = 1;
	assign m[3] = 1;
	assign m[4] = 1;
	assign m[5] = 1;
	assign m[6] = 1;	
	
endmodule

module arithmetic_unit(A, B, Sub, Function, ALUout);
	input [3:0] A, B;
	input Sub;
	input [2:0] Function;
	output [7:0] ALUout;
	
	wire [3:0] Connection0_0, Connection1_0;
	wire Connection0_1, Connection1_1;
	
	adder_curcuit u0(
			.adder_a(A[3:0]),
			.adder_b(4'b0001),
			.adder_sub0(1'b0),
			.adder_sub1(1'b0),
			.adder_sum(Connection0_0[3:0]),
			.adder_cout(Connection0_1)
			);
	
	adder_curcuit u1(
			.adder_a(A[3:0]),
			.adder_b(B[3:0]),
			.adder_sub0(Sub),
			.adder_sub1(Sub),
			.adder_sum(Connection1_0[3:0]),
			.adder_cout(Connection1_1)
			);
			
	mux6to1 u2(
			.a0(Connection0_0[3:0]),
			.a1(Connection0_1),
			.b0(Connection1_0[3:0]),
			.b1(Connection1_1),
			.mux_a(A[3:0]),
			.mux_b(B[3:0]),
			.mux_func(Function[2:0]),
			.mux_out(ALUout[7:0])
			);

endmodule

module adder_curcuit(adder_a, adder_b, adder_sub0, adder_sub1, adder_sum, adder_cout);
	input [3:0]adder_a;
	input [3:0]adder_b;
	input adder_sub0;
	input adder_sub1;
	output [3:0]adder_sum;
	output adder_cout;
		
	wire Carry_wire0, Carry_wire1, Carry_wire2;
	
	four_bit_adder_piece f0(
			.a(adder_a[0]),
			.b(adder_b[0]),
			.cin0(adder_sub0),
			.cin1(adder_sub1),
			.cout(Carry_wire0),
			.s(adder_sum[0])
			);
	
	four_bit_adder_piece f1(
			.a(adder_a[1]),
			.b(adder_b[1]),
			.cin0(adder_sub0),
			.cin1(Carry_wire0),
			.cout(Carry_wire1),
			.s(adder_sum[1])
			);
	
	four_bit_adder_piece f2(
			.a(adder_a[2]),
			.b(adder_b[2]),
			.cin0(adder_sub0),
			.cin1(Carry_wire1),
			.cout(Carry_wire2),
			.s(adder_sum[2])
			);
			
	four_bit_adder_piece f3(
			.a(adder_a[3]),
			.b(adder_b[3]),
			.cin0(adder_sub0),
			.cin1(Carry_wire2),
			.cout(adder_cout),
			.s(adder_sum[3])
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
			.mb(cin1),
			.muxsel(a^(b^cin0)),
			.r(cout)
			);
	
	assign s = (a^(b^cin0))^cin1;
	
endmodule

module mux2to1(ma, mb, muxsel, r);
	input ma;
	input mb;
	input muxsel;
	output r;
	
	assign r = (ma&~muxsel) | (mb&muxsel);
	
endmodule

module mux6to1(a0, a1, b0, b1, mux_a, mux_b, mux_func, mux_out);
	input [3:0]a0, b0, mux_a, mux_b;
	input a1, b1;
	input [2:0]mux_func;
	output [7:0]mux_out;
	
	reg [7:0]out;
	
	always @(*)
	begin
		case (mux_func[2:0])
			3'b000: out = {3'b000, a1, a0};
			3'b001: out = {3'b000, b1, b0};
			3'b010: out = mux_a + mux_b;
			3'b011: out = {(mux_a|mux_b), (mux_a^mux_b)};
			3'b100: out = {7'b0000000, |{mux_a, mux_b}};
			3'b101: out = (mux_b << 3'b100);
			3'b110: out = (mux_b >> 3'b100);
			3'b111: out = mux_a * mux_b;
			default: out = 8'b00000000;
		endcase
	end
	
	assign mux_out = out;

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
