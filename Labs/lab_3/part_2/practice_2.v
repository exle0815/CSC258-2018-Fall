module practice_2(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;

	leftshift a0(
			.A(3'b100),
			.B(SW[3:0]),
			.C(LEDR[3:0])
			);

	rightshift a1(
			.A(3'b100),
			.B(SW[3:0]),
			.C(LEDR[3:0])
			);

endmodule
	
module leftshift(A, B, C);
	input [2:0] A;
	input [3:0] B;
	output [3:0] C;

	assign C = B << A;

endmodule

module rightshift(A, B, C);
	input [2:0] A;
	input [3:0] B;
	output [3:0] C;

	assign C = B >> A;

endmodule
