module test(
	input reset,
	input clock,
	input enable,
	input increment,
	input [2:0] colour_in,
	input [1:0] direction,
	input capture,
	input ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10
	);

	wire [14:0] rand_coord, blk;
	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] colour, blk_count;
	wire inc;
	wire [4:0] count0, count1;

	random_generator r0 (reset, clock, 1'b1, direction, capture, rand_coord);
	counter_1 r1 (clock, reset, enable, count0);
	rate_divider_draw t1(clock, reset, enable, r_d);
	counter_2 r2 (clock, reset, r_d, count1);
	assign inc = (count0 == 5'b10011 & count1 == 5'b10011) ? 1 : 0;
	blk_counter r4 (reset, clock, inc, blk_count);
	register_blk r5 (reset, clock, rand_coord, increment, direction, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, blk_count, blk);
	draw r6 (reset, clock, enable, blk, colour_in, x, y, colour);
endmodule

module register_blk(
	input reg_reset,
	input reg_clock,
	input [14:0] reg_coord_in,
	input reg_enable,
	input [1:0] reg_dir,
	input ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10,
	input [2:0] reg_count,
	output reg [14:0] blk_out
	);

	wire [14:0] blk1, blk2, blk3, blk4, blk5, blk6, blk7, blk8, blk9, blk10;
	reg ud_or_lr;
	wire [3:0] blk_decision;

	counter_coord g0 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk1, blk1);
	counter_coord g1 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk2, blk2);
	counter_coord g2 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk3, blk3);
	counter_coord g3 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk4, blk4);
	counter_coord g4 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk5, blk5);
	counter_coord g5 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk6, blk6);
	counter_coord g6 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk7, blk7);
	counter_coord g7 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk8, blk8);
	counter_coord g8 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk9, blk9);
	counter_coord g9 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk10, blk10);

	always @(*)
	begin
		case (reg_dir[1:0])
			2'b00: ud_or_lr = 1'b0;
			2'b01: ud_or_lr = 1'b1;
			2'b10: ud_or_lr = 1'b0;
			2'b11: ud_or_lr = 1'b1;
			default: ud_or_lr =1'b0;
		endcase
	end

	assign blk_decision = {ud_or_lr, reg_count};
	always @(*)
	begin
		case (blk_decision[3:0])
			4'b0000: blk_out = blk1;
			4'b0001: blk_out = blk2;
			4'b0010: blk_out = blk3;
			4'b0011: blk_out = blk4;
			4'b0100: blk_out = blk5;
			4'b1000: blk_out = blk6;
			4'b1001: blk_out = blk7;
			4'b1010: blk_out = blk8;
			4'b1011: blk_out = blk9;
			4'b1100: blk_out = blk10;
			default: blk_out = 15'b0;
		endcase
	end
endmodule

module counter_coord(
	input co_reset,
	input co_clock,
	input [14:0] co_coord_in,
	input co_enable,
	input [1:0] co_dir,
	input ld_blk,
	output [14:0] blk_coord
	);
	wire [7:0] blk_x;
	wire [6:0] blk_y;

	counter_x q0 (co_reset, co_clock, co_coord_in[14:7], co_enable, co_dir, ld_blk, blk_x);
	counter_y q1 (co_reset, co_clock, co_coord_in[6:0], co_enable, co_dir, ld_blk, blk_y);
	assign blk_coord = {blk_x, blk_y};

endmodule

module blk_counter(
	input reset,
	input clock,
	input en,
	output reg [2:0] q
	);

	always @(posedge clock)
	begin
		if (~reset)
			q <= 3'b0;
		else if (en)
		begin
			if (q == 3'b100)
				q <= 3'b0;
			else
				q <= q + 1'b1;
		end
	end
endmodule

module random_generator(
	input random_reset,
	input random_clock,
	input random_en,
	input [1:0] dir,
	input capture,
	output [14:0] random_coord
	);

	wire [2:0] random_num, current_num, prev_num, rand_num;

	random r1(
    		.rand_reset(random_reset),
    		.rand_clock(random_clock),
    		.rand_en(random_en),
    		.rand_out(random_num)
    		);

	reg_rand r2(
			.reg_reset(random_reset),
			.reg_clock(random_clock),
			.reg_en(capture),
			.rand_num_in(random_num),
			.current(current_num),
			.prev(prev_num)
			);

	filter r3(
			.filt_reset(random_reset),
			.filt_clock(random_clock),
			.cur_num_in(current_num),
			.prev_num_in(prev_num),
			.filt_num_out(rand_num)
			);

	rand_coord_mux r4(
   			.coord_mux_reset(random_reset),
   			.coord_mux_clock(random_clock),
   			.num_dir({dir, rand_num}),
   			.random_coord(random_coord)
   			);

endmodule

module random(
	input rand_reset,
	input rand_clock,
	input rand_en,
	output reg [2:0] rand_out
	);

	always @(posedge rand_clock)
	begin 
		if (~rand_reset)
			rand_out = 3'b000;
		else 
		begin
			if (rand_en)
			begin
				if (rand_out == 3'b100) 
					rand_out <= 3'b000;
				else
					rand_out <= rand_out + 1'b1;
			end
		end
	end
endmodule

module reg_rand(
	input reg_reset,
	input reg_clock,
	input reg_en,
	input [2:0] rand_num_in,
	output reg [2:0] current,
	output reg [2:0] prev
	);

	always @(posedge reg_clock)
	begin
		if (~reg_reset)
		begin
			prev <= 3'b111;
			current <= 3'b111;
		end
		else if (reg_en)
		begin
			prev <= current;
			current <= rand_num_in;
		end
	end

endmodule

module filter(
	input filt_reset,
	input filt_clock,
	input [2:0] cur_num_in,
	input [2:0] prev_num_in,
	output reg [2:0] filt_num_out
	);
	always @(posedge filt_clock)
	begin
		if (~filt_reset)
			filt_num_out <= 3'b0;
		else
		begin
			if (cur_num_in == prev_num_in + 1)
				filt_num_out <= (cur_num_in + 1) % 5;
			else if (cur_num_in == prev_num_in - 1)
			begin
				if (cur_num_in == 3'b000)
					filt_num_out <= 3'b100;
				else 
				filt_num_out <= cur_num_in - 1;
			end
			else
				filt_num_out <= cur_num_in;
		end
	end
endmodule

module rand_coord_mux(
	input coord_mux_reset,
	input coord_mux_clock,
	input [4:0] num_dir,
	output reg [14:0] random_coord
	);

	always @(*)
	begin
		case (num_dir[4:0])
			5'b00000: random_coord = 15'b000110110000111;
			5'b00001: random_coord = 15'b001100000000111;
			5'b00010: random_coord = 15'b010001010000111;
			5'b00011: random_coord = 15'b010110100000111;
			5'b00100: random_coord = 15'b011011110000111;

			5'b01000: random_coord = 15'b011011110000111;
			5'b01001: random_coord = 15'b011011110011100;
			5'b01010: random_coord = 15'b011011110110001;
			5'b01011: random_coord = 15'b011011111000110;
			5'b01100: random_coord = 15'b011011111011011;

			5'b10000: random_coord = 15'b000110111011011;
			5'b10001: random_coord = 15'b001100001011011;
			5'b10010: random_coord = 15'b010001011011011;
			5'b10011: random_coord = 15'b010110101011011;
			5'b10100: random_coord = 15'b011011111011011;

			5'b11000: random_coord = 15'b000110110000111;
			5'b11001: random_coord = 15'b000110110011100;
			5'b11010: random_coord = 15'b000110110110001;
			5'b11011: random_coord = 15'b000110111000110;
			5'b11100: random_coord = 15'b000110111011011;
			default: random_coord = 15'b0;
		endcase
	end
endmodule

module counter_x(
	input resetn,
	input clock,
	input [7:0] random_x,
	input en,
	input [1:0] dir,
	input ld_blk,
	output reg [7:0] new_x
	);

	always @(posedge clock)
	begin
		if (~resetn)
			new_x <= 8'b0;
		else
		begin 
			if (new_x == 8'b0)
				new_x <= new_x;
			if (ld_blk)
				new_x <= random_x;
			else if (new_x != 8'b0)
			begin
				if (en)
				begin
					if (dir == 2'b00)
						new_x <= new_x;
					if (dir == 2'b01)
					begin
						if (new_x == 8'b00010100)
							new_x <= 8'b0;
						else
							new_x <= new_x - 8'd20;
					end
					if (dir == 2'b10)
						new_x <= new_x;
					if (dir == 2'b11)
					begin
						if (new_x == 8'b01100100)
							new_x <= 8'b0;
						else
							new_x <= new_x + 8'd20;
					end
				end
			end
		end
	end
endmodule
module counter_y(
	input resetn,
	input clock,
	input [6:0] random_y,
	input en,
	input [1:0] dir,
	input ld_blk,
	output reg [6:0] new_y
	);

	always @(posedge clock)
	begin
		if (~resetn)
			new_y <= 7'b0;
		else
		begin 
			if (new_y == 7'b0)
				new_y <= new_y;
			if (ld_blk)
				new_y <= random_y;
			else if (new_y != 7'b0)
			begin
				if (en)
				begin
					if (dir == 2'b00)
						begin
						if (new_y == 7'b1100100)
							new_y <= 7'b0;
						else
							new_y <= new_y + 7'd20;
						end
					if (dir == 2'b01)
						new_y <= new_y;
					if (dir == 2'b10)
						begin
						if (new_y == 7'b0010100)
							new_y <= 7'b0;
						else
							new_y <= new_y - 7'd20;
						end
					if (dir == 2'b11)
						new_y <= new_y;
				end
			end
		end
	end
endmodule

module draw(
	input reset,
	input clock,
	input enable,
	input [14:0] new_coord,
	input [2:0] colour_in,
	output [7:0] x,
	output [6:0] y,
	output [2:0] colour
	);
	wire [4:0] count_0, count_1;

	counter_draw_x t0 (clock, reset, enable, count_0);
	rate_divider_draw t1(clock, reset, enable, rd);
	counter_draw_y t2 (clock, reset, rd, count_1);
	assign x = new_coord[14:7] + count_0;
	assign y = new_coord[6:0] + count_1;
	assign colour = (x < 8'd20 | ~enable) ? 3'b0 : colour_in;
endmodule

module counter_draw_x(
	input clock,
	input reset,
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset)
			q <= 5'b10011;
		else if (en)
		begin
			if (q == 5'b10011)
				q <= 5'b0;
			else
				q <= q + 1'b1;
		end
	end
endmodule

module counter_draw_y(
	input clock,
	input reset,
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset)
			q <= 5'b00000;
		else if (en)
		begin
			if (q == 5'b10011)
				q <= 5'b0;
			else
				q <= q + 1'b1;
		end
	end
endmodule

module counter_1(
	input clock,
	input reset,
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset)
			q <= 5'b10011;
		else if (en)
		begin
			if (q == 5'b10011)
				q <= 5'b0;
			else
				q <= q + 1'b1;
		end
	end
endmodule

module counter_2(
	input clock,
	input reset,
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset)
			q <= 5'b00000;
		else if (en)
		begin
			if (q == 5'b10011)
				q <= 5'b0;
			else
				q <= q + 1'b1;
		end
	end
endmodule

module rate_divider_draw(
	input clock,
	input reset,
	input en,
	output q
	);
	reg [4:0] out;

	always @(posedge clock)
	begin
		if (~reset)
			out <= 5'b10100;
		else if (en)
		begin 
			if (out == 5'b00000)
				out <= 5'b10011;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 5'b00000) ? 1 : 0;

endmodule

module count(
	input count_reset,
	input count_clock,
	input count_en,
	output count_out
	);
	wire count_out0;
	wire [4:0] count_out1;

	rate_divider_draw m0 (count_clock, count_reset, count_en, count_out0);
	counter_count m1 (count_clock, count_reset, count_out0, count_out1);
	assign count_out = (count_out1 == 5'b10101) ? 0 : 1;
endmodule

module counter_count(
	input clock,
	input reset,
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset)
			q <= 5'b0;
		else if (en)
		begin
			if (q == 5'b10101)
				q <= q;
			else
				q <= q + 1'b1;
		end
	end
endmodule

module delay_counter(
	input resetn,
	input clock,
	input en,
	output q
	);
	reg [19:0] out;

	always @(posedge clock)
	begin
		if (~resetn)
			out <= 20'b11001011011100110101;
		else if (en)
		begin 
			if (out == 20'b00000000000000000000)
				out <= 20'b11001011011100110101;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 20'b00000000000000000000) ? 1 : 0;

endmodule

module block_frame_counter(
	input resetn,
	input clock,
	input en,
	output q
	);
	reg [3:0] out;

	always @(posedge clock)
	begin
		if (~resetn)
			out <= 4'b1110;
		else if (en)
		begin 
			if (out == 4'b1110)
				out <= 4'b0000;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 4'b0000) ? 1 : 0;

endmodule