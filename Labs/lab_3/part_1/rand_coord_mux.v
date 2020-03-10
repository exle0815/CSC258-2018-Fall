module rand_coord_mux(
	input coord_mux_reset,
	input coord_mux_clock,
	input [4:0] num_dir,
	output reg [14:0] random_coord
	);

	always @(*)
	begin
		case (num_dir[4:0])
			5'b00000: random_coord = 15'b000101000010100;
			5'b00001: random_coord = 15'b001010000010100;
			5'b00010: random_coord = 15'b001111000010100;
			5'b00011: random_coord = 15'b010100000010100;
			5'b00100: random_coord = 15'b011001000010100;

			5'b01000: random_coord = 15'b011001000010100;
			5'b01001: random_coord = 15'b011001000101000;
			5'b01010: random_coord = 15'b011001000111100;
			5'b01011: random_coord = 15'b011001001010000;
			5'b01100: random_coord = 15'b011001001100100;

			5'b10000: random_coord = 15'b000101001100100;
			5'b10001: random_coord = 15'b001010001100100;
			5'b10010: random_coord = 15'b001111001100100;
			5'b10011: random_coord = 15'b010100001100100;
			5'b10100: random_coord = 15'b011001001100100;

			5'b11000: random_coord = 15'b000101000010100;
			5'b11001: random_coord = 15'b000101000101000;
			5'b11010: random_coord = 15'b000101000111100;
			5'b11011: random_coord = 15'b000101001010000;
			5'b11100: random_coord = 15'b000101001100100;
			default: 15'b0;
		endcase
	end
endmodule
