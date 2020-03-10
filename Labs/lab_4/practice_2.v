module practice_2(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;

	leftshift a0(
			.A(3'b100),
			.B(SW[7:0]),
			.C(LEDR[7:0])
			);

endmodule
	
module leftshift(A, B, C);
	input [2:0] A;
	input [7:0] B;
	output [7:0] C;

	assign C = B >> A;

endmodule
