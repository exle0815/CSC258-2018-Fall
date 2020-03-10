module block_registers(
	input CLOCK_50,
	input [3:0] KEY,
	input [14:0] rand_coord,
	input [7:0] new_x,
	input [6:0] new_y,
	input ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10,
	output blk1, blk2, blk3, blk4, blk5, blk6, blk7, blk8, blk9, blk10,
	);

	wire reset;
	assign reset = ~KEY[0];

	block_register_piece b0(.blk_reset(reset), .blk_clock(CLOCK_50), .random_x(random_coord[14:7]), .random_y(random_coord[6:0]), 
			.x_in(new_x_1), .y_in(new_y_1), .ld_blk(ld_blk1))

module block_register(
	input blk_reset,
	input blk_clock,
	input [7:0] random_x,
	input [6:0] random_y,
	input [7:0] x_in;
	input [6:0] y_in;
	input ld_blk,
	output reg [7:0] blk_x,
	output reg [6:0] blk_y
	);

	always @(posedge blk_clock)
	begin
		if (~blk_reset)
		begin
			blk_x <= 8'b0; 
			blk_y <= 7'b0;
		end
		else 
		begin 
			if (ld_blk)
			begin
				blk_x <= random_x;
				blk_y <= random_y;
			end
			else
			begin
				blk_x <= x_in;
				blk_y <= y_inl
			end
		end
	endmodule