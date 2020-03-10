module direction(
	input dir_reset,
	input dir_clock,
	input [3:0] degree,
	output reg [1:0] direct
	);

	always @(*)
	begin
		case (degree [3:0])
			4'b1000: direct = 2'b00;
			4'b0100: direct = 2'b01;
			4'b0010: direct = 2'b10;
			4'b0001: direct = 2'b11;
		endcase
	end
endmodule