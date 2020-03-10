module project(
	CLOCK_50,						
    KEY,
	 SW,
	VGA_CLK,   						
	VGA_HS,							
	VGA_VS,							
	VGA_BLANK_N,						
	VGA_SYNC_N,						
	VGA_R,   						
	VGA_G,	 						
	VGA_B,
	HEX0,
	HEX1   						
	);

	input			CLOCK_50;				
	input   [3:0]   KEY;
	input   [9:0]   SW;
	output			VGA_CLK;   				
	output			VGA_HS;					
	output			VGA_VS;					
	output			VGA_BLANK_N;				
	output			VGA_SYNC_N;				
	output	[9:0]	VGA_R;   				
	output	[9:0]	VGA_G;	 				
	output	[9:0]	VGA_B;
	output  [6:0]	HEX0;
	output	[6:0]	HEX1; 		
	
	wire reset, go, go2, left, right, up, down;
	assign reset = KEY[0];
	assign go = ~KEY[1];
	assign go2 = ~KEY[2];
	assign left = SW[3];
	assign right = SW[2];
	assign up = SW[1];
	assign down = SW[0];
	
	wire [2:0] colour, colour_in;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn, stop, signal;
	wire draw, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, capture, increment;
	wire [1:0] direction;
	wire count_sec, collision, player_draw, reset_draw, change_dir, reset_counter;
	wire [3:0] count_second;

	vga_adapter VGA(
			.resetn(reset),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	count_sec s0(reset, CLOCK_50, count_sec, reset_rd, count_second, HEX1, HEX0);

	count_direction s1(reset, CLOCK_50, change_dir, count_dir, direction);

	control c0(reset, CLOCK_50, go, go2, count_second, stop, direction, collision, ld_map, ld_player, colour_in, capture, increment, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, draw, writeEn, count_sec, reset_counter, resetn, reset_rd, count_dir, player_draw, reset_draw, signal, change_dir, cap_random, store_random);

	datapath d0(reset, CLOCK_50, reset_counter, reset_draw, draw, signal, colour_in, direction, cap_random, store_random, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, ld_player, player_draw, left, right, up, down, x, y, colour, collision, stop);

endmodule

module control(
	input reset,
	input clock,
	input go,
	input go2,
	input [3:0] count_second,
	input stop,
	input [1:0] direction,
	input collision,
	output reg ld_map,
	output reg ld_player,
	output reg [2:0] colour,
	output reg capture,
	output reg increment,
	output ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10,
	output reg draw,
	output reg wren,
	output reg count_sec,
	output reset_counter,
	output reg resetn,
	output reg reset_rd,
	output reg count_dir,
	output reg player_draw,
	output reg reset_draw,
	output signal,
	output change_dir,
	output cap_random,
	output store_random
	);

	wire [2:0] ld_num, colour_d;
	reg ld_blk;
	wire drawe, reset_new, cap;
	wire incre, r_d_three;
	assign incre = increment;
	assign cap = capture;
	assign reset_new = resetn;
	assign colour_d = colour;
	assign drawe = draw & (colour_d == 3'b100);
	wire [5:0] frame_count;

	reg [4:0] current_state, next_state;

	localparam  PREPARE			= 5'd0,
			    MAIN			= 5'd1,
			    MAIN_WAIT 		= 5'd2,
			    CAPTURE			= 5'd3,
			    INCRE   		= 5'd4,
				DRAW			= 5'd5,
				ERASE			= 5'd6,
				WAIT 			= 5'd7,
				WAIT_DRAW 		= 5'd8,
				WAIT_ERASE 		= 5'd9,
				GAMEOVER 		= 5'd10;


	count_three p0 (reset, clock, reset_new, incre, r_d_three, signal, change_dir);
	count_capture p1 (reset, clock, reset_new, cap, r_d_capture, cap_random, store_random)
	delay_counter c1 (reset, clock, reset_new, drawe, rd);
	block_frame_counter c2 (reset, clock, reset_new, rd, q, frame_count);
	assign reset_counter = (rd & frame_count == 6'b111100) ? 0 : 1;
	always @(*)
	begin: state_table
		case (current_state)
			PREPARE : next_state = MAIN;
			MAIN : next_state = go ? MAIN_WAIT : MAIN;
			MAIN_WAIT : next_state = go ? MAIN_WAIT : CAPTURE;
			CAPTURE: next_state = r_d_capture : INCRE : CAPTURE;
			INCRE: 
			begin
				if (collision == 1'b1)
					next_state = GAMEOVER;
				else
					next_state = r_d_three ? DRAW : INCRE;	
			end
			DRAW: next_state = ~reset_counter ? ERASE : DRAW;
			ERASE: 
			begin
				if (count_second != 4'b1111)
					next_state = stop ? CAPTURE : ERASE;
				else
					next_state = stop ? WAIT : ERASE;
			end
			WAIT: next_state = r_d_three ? WAIT_DRAW : WAIT;
			WAIT_DRAW: next_state = ~reset_counter ? WAIT_ERASE : WAIT_DRAW;
			WAIT_ERASE: next_state = stop ? CAPTURE : WAIT_ERASE;
			GAMEOVER: next_state = go2 ? PREPARE : GAMEOVER;
		endcase
	end

	always @(*)
	begin: enable_signals
		ld_map = 1'b0;
		ld_player = 1'b0;
		colour = 3'b0;
		capture = 1'b0;
		draw = 1'b0;
		wren = 1'b0;
		increment = 1'b0;
		count_sec = 1'b0;
		ld_blk = 1'b0;
		resetn = 1'b1;
		reset_rd = 1'b1;
		count_dir = 1'b0;
		player_draw = 1'b0;
		reset_draw = 1'b1;

		case (current_state)
			PREPARE:
			begin
				ld_map = 1'b1;
				colour = 3'b111;
				ld_player = 1'b1;
			end
			MAIN:
			begin
				player_draw = 1'b1;
				colour = 3'b010;
				reset_rd = 1'b0;
				resetn = 1'b0;
			end
			CAPTURE:
			begin
				capture = 1'b1;
				count_sec = 1'b1;
				reset_draw = 1'b0;
			end
			INCRE:
			begin
				increment = 1'b1;
				count_sec = 1'b1;
				ld_blk = 1'b1;
			end
			DRAW:
			begin
				draw = 1'b1;
				colour = 3'b100;
				wren = 1'b1;
				count_sec = 1'b1;
			end
			ERASE:
			begin
				draw = 1'b1;
				colour = 3'b000;
				wren = 1'b1;
				count_sec = 1'b1;
				resetn = 1'b0;
			end
			WAIT:
			begin
				increment = 1'b1;
				reset_rd = 1'b0;
				count_dir = 1'b1;
			end
			WAIT_DRAW:
			begin
				draw = 1'b1;
				colour = 3'b100;
				wren = 1'b1;
			end
			WAIT_ERASE:
			begin
				draw = 1'b1;
				colour = 3'b000;
				wren = 1'b1;
				resetn = 1'b0;
			end
		endcase
	end

	counter_ld c3(clock, reset, reset_rd, capture, ld_num);
	mux_ld_blk c4(direction, ld_blk, ld_num, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10);

	always @(posedge clock)
	begin: state_FFs
		if (~reset)
			current_state <= PREPARE;
		else 
			current_state <= next_state;
	end
endmodule

module datapath(
	input reset,
	input clock,
	input reset_counter,
	input reset_draw,
	input enable,
	input increment,
	input [2:0] colour_in,
	input [1:0] direction,
	input cap_random, store_random
	input ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, ld_player, player_draw,
	input left, right, up, down,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] colour_out,
	output collision,
	output stop
	);

	wire [14:0] rand_coord, blk;
	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] colour, blk_colour;
	wire [3:0] blk_count;
	wire [4:0] count0, count1;
	wire inc;

	random_generator d1 (reset, clock, direction, cap_random, store_random, rand_coord);
	counter_draw_x d2 (clock, reset, reset_counter, reset_draw, enable, count0);
	rate_divider_draw d3(clock, reset, reset_counter, reset_draw, enable, r_d);
	counter_draw_y d4 (clock, reset, reset_counter, reset_draw, r_d, count1);
	assign inc = (count0 == 5'b10011 & count1 == 5'b10011) ? 1 : 0;
	blk_counter d5 (reset, clock, reset_counter, inc, blk_count);
	assign stop = (inc & blk_count == 4'b1010 & colour_in == 3'b000) ? 1 : 0;
	keyboard_dir d6 (left, right, up, down, direction, left_d, right_d, up_d, down_d);
	register_blk d7 (reset, clock, colour_in, rand_coord, increment, direction, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, ld_player, player_draw, left_d, right_d, up_d, down_d, blk_count, blk, blk_colour, collision);
	draw d8 (reset, clock, reset_counter, reset_draw, enable, player_draw, blk, blk_colour, x, y, colour);
	assign x_out = x;
	assign y_out = y;
	assign colour_out = colour;
endmodule

module register_blk(
	input reg_reset,
	input reg_clock,
	input [2:0] colour_in,
	input [14:0] reg_coord_in,
	input reg_enable,
	input [1:0] reg_dir,
	input ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, ld_player, player_draw,
	input left, right, up, down,
	input [3:0] reg_count,
	output reg [14:0] blk_out,
	output reg [2:0] colour_out,
	output reg collision
	);

	wire [14:0] player, blk1, blk2, blk3, blk4, blk5, blk6, blk7, blk8, blk9, blk10;
	wire [4:0] decision;

	counter_coord r0 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk1, blk1);
	counter_coord r1 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk2, blk2);
	counter_coord r2 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk3, blk3);
	counter_coord r3 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk4, blk4);
	counter_coord r4 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk5, blk5);
	counter_coord r5 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk6, blk6);
	counter_coord r6 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk7, blk7);
	counter_coord r7 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk8, blk8);
	counter_coord r8 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk9, blk9);
	counter_coord r9 (reg_reset, reg_clock, reg_coord_in, reg_enable, reg_dir, ld_blk10, blk10);
	player_move s9 (reg_reset, reg_clock, 15'b010001010110001, reg_enable, ld_player, left, right, up, down, player);

	assign decision = {player_draw, reg_count};
	always @(*)
	begin
		case (decision[4:0])
			5'b10000: blk_out = player;
			5'b00000: blk_out = blk1;
			5'b00001: blk_out = blk2;
			5'b00010: blk_out = blk3;
			5'b00011: blk_out = blk4;
			5'b00100: blk_out = blk5;
			5'b00101: blk_out = blk6;
			5'b00110: blk_out = blk7;
			5'b00111: blk_out = blk8;
			5'b01000: blk_out = blk9;
			5'b01001: blk_out = blk10;
			5'b01010: blk_out = player;
			default: blk_out = 15'b0;
		endcase
	end

	always @ (*) 
	begin 
		if (colour_in == 3'b000)
			colour_out = 3'b0;
		else
			colour_out = (blk_out == player) ? 3'b010 : 3'b100;
	end

	always @ (posedge reg_clock)
	begin
		if (~reg_reset)
			collision <= 1'b0;
		else
		begin
			if (player == blk1 | player == blk2 | player == blk3 | player == blk4 | player == blk5 | player == blk6 | player == blk7 | player == blk8 | player == blk9 | player == blk10)
				collision <= 1'b1;
			else
			begin
				collision <= 1'b0;
			end
		end
	end
endmodule

module counter_ld(
	input clk,
	input reset,
	input resetn,
	input en,
	output reg [2:0] q
	);

	always @(posedge clk)
	begin
		if (~reset | ~resetn)
			q <= 3'b000;
		else if (en)
		begin
			if (q == 3'b101)
				q <= 3'b001;
			else
				q <= q + 1'b1;
		end
	end
endmodule

module mux_ld_blk(
	input [1:0] direction,
	input enable,
	input [2:0] ld_number,
	output reg ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10
	);

	reg ud_or_lr;
	wire [4:0] dir_ld_num;

	always @(*)
	begin
		case (direction[1:0])
			2'b00: ud_or_lr = 1'b0;
			2'b01: ud_or_lr = 1'b1;
			2'b10: ud_or_lr = 1'b0;
			2'b11: ud_or_lr = 1'b1;
			default: ud_or_lr =1'b0;
		endcase
	end

	assign dir_ld_num = {enable, ud_or_lr, ld_number};

	always @(*)
	begin
		ld_blk1 = 1'b0;
		ld_blk2 = 1'b0;
		ld_blk3 = 1'b0;
		ld_blk4 = 1'b0;
		ld_blk5 = 1'b0;
		ld_blk6 = 1'b0;
		ld_blk7 = 1'b0;
		ld_blk8 = 1'b0;
		ld_blk9 = 1'b0;
		ld_blk10 = 1'b0;

		case (dir_ld_num [4:0])
			5'b00001: ld_blk1 = 1'b0;
			5'b00010: ld_blk2 = 1'b0;
			5'b00011: ld_blk3 = 1'b0;
			5'b00100: ld_blk4 = 1'b0;
			5'b00101: ld_blk5 = 1'b0;
			5'b01001: ld_blk6 = 1'b0;
			5'b01010: ld_blk7 = 1'b0;
			5'b01011: ld_blk8 = 1'b0;
			5'b01100: ld_blk9 = 1'b0;
			5'b01101: ld_blk10 = 1'b0;
			5'b10001: ld_blk1 = 1'b1;
			5'b10010: ld_blk2 = 1'b1;
			5'b10011: ld_blk3 = 1'b1;
			5'b10100: ld_blk4 = 1'b1;
			5'b10101: ld_blk5 = 1'b1;
			5'b11001: ld_blk6 = 1'b1;
			5'b11010: ld_blk7 = 1'b1;
			5'b11011: ld_blk8 = 1'b1;
			5'b11100: ld_blk9 = 1'b1;
			5'b11101: ld_blk10 = 1'b1;
			default: ld_blk1 = 1'b0;
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
	always @(*)
	begin
		if (blk_x == 8'b0 | blk_y == 7'b0)
			blk_coord = 15'b0;
		else 
			blk_coord = {blk_x, blk_y};
	end
endmodule

module blk_counter(
	input reset,
	input clock,
	input reset_counter,
	input en,
	output reg [3:0] q
	);

	always @(posedge clock)
	begin
		if (~reset | ~reset_counter)
			q <= 4'b0;
		else if (en)
		begin
			if (q == 4'b1010)
				q <= 4'b0;
			else
				q <= q + 1'b1;
		end
	end
endmodule

module random_generator(
	input random_reset,
	input random_clock,
	input [1:0] dir,
	input cap_random,
	input store_random,
	output [14:0] random_coord
	);

	wire [3:0] rand_out, current_num, prev_num, random_number;
	wire [5:0] num_dir;

	random g0(random_reset, random_clock, cap_random, rand_out);
	reg_rand g1 (random_reset, random_clock, store_random, rand_out, current_num, prev_num);
	filter g2 (random_reset, random_clock, current_num, prev_num, random_number);
	assign num_dir = {dir, random_number};
	rand_coord_mux g3(random_reset, random_clock, num_dir, random_coord);

endmodule


module random(
	input random_reset,
	input random_clock,
	input random_en,
	output [3:0] random_out
	);
	wire random_signal;
	wire [3:0] rand_out;

	random_piece z0 (random_reset, random_clock, random_en, random_signal, ran_en0, rand_out[0]);
	random_piece_dif z1 (random_reset, random_clock, random_en, ran_en0, ran_en1, rand_out[1]);
	random_piece_dif z2 (random_reset, random_clock, random_en, ran_en1, ran_en2, rand_out[2]);
	random_piece z3 (random_reset, random_clock, random_en, ran_en2, ran_en3, rand_out[3]);
	assign random_signal = ran_en2 ^ ran_en3;
	assign random_out = rand_out % 4'd5;


endmodule

module random_piece_dif(
	input ran_reset,
	input ran_clock,
	input ran_en,
	input ran_in,
	output ran_sig,
	output ran_out
	);

	reg out;

	always @ (posedge ran_clock)
	begin
		if (~ran_reset)
			out <= 1'b1;
		else if (ran_en)
		begin
			if (ran_in)
				out <= ~out;
		end
	end

	assign ran_sig = out;
	assign ran_out = out;
endmodule

module random_piece(
	input ran_reset,
	input ran_clock,
	input ran_en,
	input ran_in,
	output ran_sig,
	output ran_out
	);

	reg out;

	always @ (posedge ran_clock)
	begin
		if (~ran_reset)
			out <= 1'b0;
		else if (ran_en)
		begin
			if (ran_in)
				out <= ~out;
		end
	end

	assign ran_sig = out;
	assign ran_out = out;
endmodule

module reg_rand(
	input reg_reset,
	input reg_clock,
	input reg_en,
	input [3:0] rand_num_in,
	output reg [3:0] current,
	output reg [3:0] prev
	);

	always @(posedge reg_clock)
	begin
		if (~reg_reset)
		begin
			prev <= 4'b1111;
			current <= 4'b1111;
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
	input [3:0] cur_num_in,
	input [3:0] prev_num_in,
	output reg [3:0] filt_num_out
	);
	always @(posedge filt_clock)
	begin
		if (~filt_reset)
			filt_num_out <= 4'b0;
		else
		begin
			if (cur_num_in == prev_num_in + 1'b1)
				filt_num_out <= (cur_num_in + 1'b1) % 5;
			else if (cur_num_in == prev_num_in - 1'b1)
			begin
				if (cur_num_in == 4'b000)
					filt_num_out <= 4'b100;
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
	input [5:0] num_dir,
	output reg [14:0] random_coord
	);

	always @(*)
	begin
		case (num_dir[5:0])
			6'b000000: random_coord = 15'b000110110000111;
			6'b000001: random_coord = 15'b001100000000111;
			6'b000010: random_coord = 15'b010001010000111;
			6'b000011: random_coord = 15'b010110100000111;
			6'b000100: random_coord = 15'b011011110000111;

			6'b010000: random_coord = 15'b011011110000111;
			6'b010001: random_coord = 15'b011011110011100;
			6'b010010: random_coord = 15'b011011110110001;
			6'b010011: random_coord = 15'b011011111000110;
			6'b010100: random_coord = 15'b011011111011011;

			6'b100000: random_coord = 15'b000110111011011;
			6'b100001: random_coord = 15'b001100001011011;
			6'b100010: random_coord = 15'b010001011011011;
			6'b100011: random_coord = 15'b010110101011011;
			6'b100100: random_coord = 15'b011011111011011;

			6'b110000: random_coord = 15'b000110110000111;
			6'b110001: random_coord = 15'b000110110011100;
			6'b110010: random_coord = 15'b000110110110001;
			6'b110011: random_coord = 15'b000110111000110;
			6'b110100: random_coord = 15'b000110111011011;
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
						if (new_x == 8'b00011011)
							new_x <= 8'b0;
						else
							new_x <= new_x - 8'd21;
					end
					if (dir == 2'b10)
						new_x <= new_x;
					if (dir == 2'b11)
					begin
						if (new_x == 8'b01101111)
							new_x <= 8'b0;
						else
							new_x <= new_x + 8'd21;
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
						if (new_y == 7'b1011011)
							new_y <= 7'b0;
						else
							new_y <= new_y + 7'd21;
						end
					if (dir == 2'b01)
						new_y <= new_y;
					if (dir == 2'b10)
						begin
						if (new_y == 7'b0000111)
							new_y <= 7'b0;
						else
							new_y <= new_y - 7'd21;
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
	input reset_counter,
	input reset_draw,
	input enable0,
	input player_draw,
	input [14:0] new_coord,
	input [2:0] colour_in,
	output [7:0] x,
	output [6:0] y,
	output [2:0] colour
	);
	wire [4:0] count_0, count_1;
	wire enable;
	assign enable = enable0 | player_draw;

	counter_draw_x t0 (clock, reset, reset_counter, reset_draw, enable, count_0);
	rate_divider_draw t1(clock, reset, reset_counter, reset_draw, enable, rd);
	counter_draw_y t2 (clock, reset, reset_counter, reset_draw, rd, count_1);
	assign x = new_coord[14:7] + count_0;
	assign y = new_coord[6:0] + count_1;
	assign colour = (x < 8'd21 | y < 7'd7 | ~enable) ? 3'b0 : colour_in;
endmodule

module counter_draw_x(
	input clock,
	input reset,
	input reset_count,
	input reset_draw,
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset | ~reset_count | ~reset_draw)
			q <= 5'b0;
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
	input reset_count,
	input reset_draw,
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset | ~reset_count | ~reset_draw)
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
	input reset_count,
	input reset_draw,
	input en,
	output q
	);
	reg [4:0] out;

	always @(posedge clock)
	begin
		if (~reset | ~reset_count | ~reset_draw)
			out <= 5'b10011;
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

module delay_counter(
	input resetn,
	input clock,
	input resetnew,
	input en,
	output q
	);
	reg [19:0] out;

	always @(posedge clock)
	begin
		if (~resetn | ~resetnew)
			out <= 20'b11001011011100110101;
		else if (en)
		begin 
			if (out == 20'b0)
				out <= 20'b11001011011100110101;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 20'b0) ? 1 : 0;

endmodule

module block_frame_counter(
	input resetn,
	input clock,
	input resetnew,
	input en,
	output q,
	output reg [5:0] out
	);

	always @(posedge clock)
	begin
		if (~resetn | ~resetnew)
			out <= 6'b0;
		else if (en)
		begin 
			if (out == 6'b111100)
				out <= 6'b0;
			else
			 	out <= out + 1'b1;
		end
	end
	assign q = (out == 6'b111100) ? 1 : 0;

endmodule

module count_sec(
	input reset,
	input clock,
	input enable,
	input reset_rd,
	output [3:0] count_second,
	output [6:0] hex1,
	output [6:0] hex0
	);
	wire hex_en; 
	wire [3:0] hex0_count, hex1_count;

	rate_divider_second s3 (reset, clock, reset_rd, enable, rotation);
	count_second s4 (reset, clock, reset_rd, rotation, count_second);
	hex_second s5 (reset, clock, reset_rd, rotation, hex0_count);
	assign hex_en = (rotation & hex0_count ==  4'b1001) ? 1 : 0;
	hex_second s6 (reset, clock, reset_rd, hex_en, hex1_count);
	hex_decoder s7 (hex1_count, hex1);
	hex_decoder s8 (hex0_count, hex0);
endmodule

module rate_divider_second(
	input reset,
	input clock,
	input resetn,
	input enable,
	output q
	);

	reg [25:0] out;

	always @(posedge clock)
	begin
		if (~reset | ~resetn)
			out <= 26'd49999999;
		else if (enable)
		begin 
			if (out == 26'b0)
				out <= 26'd49999999;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 26'b0) ? 1 : 0;

endmodule

module count_second(
	input reset,
	input clock,
	input resetn,
	input enable,
	output reg [3:0] count_second
	);
	always @(posedge clock)
	begin
		if (~reset | ~resetn)
			count_second <= 4'b0;
		else if (enable)
		begin
			if (count_second == 4'b1111)
				count_second <= count_second;
			else
				count_second <= count_second + 1'b1;
		end
	end
endmodule

module hex_second(
	input reset,
	input clock,
	input resetn,
	input enable,
	output reg [3:0] hex_second
	);
	always @(posedge clock)
	begin
		if (~reset | ~resetn)
			hex_second <= 4'b0;
		else if (enable)
		begin
			if (hex_second == 4'b1001)
				hex_second <= 4'b0;
			else
				hex_second <= hex_second + 1'b1;
		end
	end
endmodule

module hex_decoder(
    input [3:0] hex_digit,
    output reg [6:0] segments
    );
   
    always @(*)
        case (hex_digit)
            4'b0000: segments = 7'b100_0000;
            4'b0001: segments = 7'b111_1001;
            4'b0010: segments = 7'b010_0100;
            4'b0011: segments = 7'b011_0000;
            4'b0100: segments = 7'b001_1001;
            4'b0101: segments = 7'b001_0010;
            4'b0110: segments = 7'b000_0010;
            4'b0111: segments = 7'b111_1000;
            4'b1000: segments = 7'b000_0000;
            4'b1001: segments = 7'b001_1000;   
            default: segments = 7'b0;
        endcase
endmodule

module count_direction(
	input reset,
	input clock,
	input enable0,
	input enable1,
	output reg [1:0] direction
	);

	always @(posedge clock)
	begin
		if (~reset)
			direction <= 2'b0;
		else if (enable0 & enable1)
		begin
			if (direction == 2'b11)
				direction <= 2'b0;
			else
				direction <= direction + 1'b1;
		end
	end
endmodule

module count_three(
	input reset,
	input clock,
	input resetn,
	input enable,
	output out,
	output signal,
	output change_dir
	);
	reg [1:0] q;

	always @(posedge clock)
	begin
		if (~reset)
			q <= 2'b0;
		else if (enable)
		begin
			if (q == 2'b11)
				q <= 2'b0;
			else
				q <= q + 1'b1;
		end
	end

	assign out = (q == 2'b11) ? 1 : 0;
	assign signal = (q == 2'b01) ? 1 : 0;
	assign change_dir = (q == 2'b00) ? 1 : 0;
endmodule

module count_capture(
	input reset,
	input clock,
	input resetn,
	input enable,
	output out,
	output cap_random,
	output store_random
	);
	reg [1:0] q;

	always @(posedge clock)
	begin
		if (~reset)
			q <= 2'b0;
		else if (enable)
		begin
			if (q == 2'b11)
				q <= 2'b0;
			else
				q <= q + 1'b1;
		end
	end

	assign out = (q == 2'b11) ? 1 : 0;
	assign cap_random = (q == 2'b01) ? 1 : 0;
	assign store_random = (q == 2'b10) ? 1 : 0;
endmodule

module player_move(
	input p_reset,
	input p_clock,
	input [14:0] p_in,
	input p_enable,
	input ld_player,
	input left, right, up, down,
	output [14:0] p_coord
	);
	wire [7:0] p_x;
	wire [6:0] p_y;

	player_move_x q2 (p_reset, p_clock, p_in[14:7], p_enable, ld_player, left, right, p_x);
	player_move_y q3 (p_reset, p_clock, p_in[6:0], p_enable, ld_player, up, down, p_y);
	assign p_coord = {p_x, p_y};

endmodule

module player_move_x(
	input move_reset,
	input move_clock,
	input [7:0] x_in,
	input move_enable,
	input ld_player,
	input left, right, 
	output reg [7:0] player_x
	);

	always @(posedge move_clock)
	begin
		if (~move_reset)
			player_x <= 8'b0;
		else 
		begin
			if (player_x == 8'b0)
				player_x <= player_x;
			if (ld_player)
				player_x <= x_in;
			else if (player_x != 8'b0)
			begin
				if (move_enable)
				begin
					if (left)
					begin
						if (player_x == 8'b00011011)
							player_x <= player_x;
						else
						begin
							player_x <= player_x - 8'd21;
						end
					end
					if (right)
					begin
						if (player_x == 8'b01101111)
							player_x <= player_x;
						else
						begin
							player_x <= player_x + 8'd21;
						end
					end
				end
			end
		end
	end
endmodule

module player_move_y(
	input move_reset,
	input move_clock,
	input [6:0] y_in,
	input move_enable,
	input ld_player,
	input up, down, 
	output reg [6:0] player_y
	);

	always @(posedge move_clock)
	begin
		if (~move_reset)
			player_y <= 7'b0;
		else
		begin
			if (player_y == 7'b0)
				player_y <= player_y;
			if (ld_player)
				player_y <= y_in;
			else if (player_y != 7'b0)
			begin
				if (move_enable)
				begin
					if (up)
					begin
						if (player_y == 7'b0000111)
							player_y <= player_y;
						else
						begin
							player_y <= player_y - 7'd21;
						end
					end
					if (down)
					begin
						if (player_y == 7'b1011011)
							player_y <= player_y;
						else
						begin
							player_y <= player_y + 7'd21;
						end
					end
					else
					begin
						player_y <= player_y;
					end
				end
			end
		end
	end
endmodule

module keyboard_dir(
	input left, right, up, down,
	input [1:0] direction,
	output reg left_d, right_d, up_d, down_d
	);
	always @(direction)
	begin
		if (direction == 2'b00)
		begin
			left_d = left;
			right_d = right;
			up_d = up;
			down_d = down;
		end
		if (direction == 2'b01)
		begin
			left_d = up;
			right_d = down;
			up_d = right;
			down_d = left;
		end
		if (direction == 2'b10)
		begin
			left_d = right;
			right_d = left;
			up_d = down;
			down_d = up;
		end
		if (direction == 2'b11)
		begin
			left_d = down;
			right_d = up;
			up_d = left;
			down_d = right;
		end
	end
endmodule