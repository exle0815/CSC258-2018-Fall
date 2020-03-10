module project_test(
	CLOCK_50,						
    KEY,
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
	
	wire reset, go, go2;
	assign reset = KEY[0];
	assign go = ~KEY[1];
	assign go2 = ~KEY[2];
	
	wire [2:0] colour, colour_in;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire draw, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, 
	ld_blk9, ld_blk10, capture, increment;
	wire [1:0] direction;
	wire left, right, up, down, space, enter, collision;

	keyboard_tracker #(.PULSE_OR_HOLD(1)) x0 (CLOCK_50, reset, 1'b1, 1'b1, w, a, s, d, 
	left, right, up, down, space, enter);

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
		
	control c0(reset, CLOCK_50, 1'b0, collision, ld_map, colour_in, direction, capture, increment, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, ld_player, draw, writeEn, count_sec);

	datapath d0(reset, CLOCK_50, draw, increment, colour_in, direction, capture, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, ld_player, left, right, up, down, x, y, colour, collision);

endmodule

module control(
	input reset,
	input clock,
	input rotation,
	input collision,
	output reg ld_map,
	output reg colour,
	output reg direction, 
	output reg capture,
	output reg increment,
	output ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10,
	output reg ld_player,
	output reg draw,
	output reg wren,
	output reg count_sec
	);

	wire [2:0] ld_num;


	reg [4:0] current_state, next_state;

	localparam  PREPARE  		= 5'd0,
			    MAIN 			= 5'd1,
			    MAIN_WAIT		= 5'd2,
			    D0_CAPTURE		= 5'd2,
			    D0_INCRE   		= 5'd3,
				D0_DRAW			= 5'd4,
				D0_ERASE		= 5'd5,
				GAME_OVER  		= 5'd6;

	delay_counter c1 (reset, clock, enable, rd);
	block_frame_counter c2 (reset, clock, rd, frame_count);

	always @(*)
	begin: state_table
		case (current_state)
			PREPARE : next_state = go2 ? MAIN : PREPARE;
			MAIN : next_state = go ? MAIN_WAIT : MAIN;
			MAIN_WAIT : next_state = go ? MAIN_WAIT : D0_CAPTURE;
			D0_CAPTURE: next_state = D0_INCRE;
			D0_INCRE: next_state = D0_DRAW;
			D0_DRAW: next_state = frame_count ? D0_ERASE : D0_DRAW;
			D0_ERASE: next_state = D0_CAPTURE; 
			GAME_OVER: next_state = go2 ? MAIN : GAME_OVER;
			default: next_state = PREPARE;
		endcase
	end

	always @(*)
	begin: enable_signals
		direction = 2'b00;
		ld_map = 1'b0;
		colour = 1'b0;
		capture = 1'b0;
		draw = 1'b0;
		wren = 1'b0;
		increment = 1'b0;
		count_sec = 1'b0;
		ld_player = 1'b0;

		case (current_state)
			PREPARE:
			begin
				ld_map = 1'b1;
				colour = 3'b001;
				ld_player = 1'b1;
			end
			D0_CAPTURE:
			begin
				direction = 2'b00;
				capture = 1'b1;
				count_sec = 1'b1;
			end
			D0_INCRE:
			begin
				direction = 2'b00;
				increment = 1'b1;
				count_sec = 1'b1;
			end
			D0_DRAW:
			begin
				direction = 2'b00;
				draw = 1'b1;
				colour = 3'b100;
				wren = 1'b1;
				count_sec = 1'b1;
			end
			D0_ERASE:
			begin
				direction = 2'b00;
				draw = 1'b1;
				colour = 3'b000;
				wren = 1'b1;
				count_sec = 1'b1;
			end
		endcase
	end

	counter_ld c3(clock, reset, capture, ld_num);
	mux_ld_blk c4(direction, ld_num, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10);

	always @(posedge clock)
	begin: state_FFs
		if (~reset)
			current_state <= MAIN;
		else if (collision)
		begin
			next_state <= GAME_OVER;
		end
		else 
			current_state <= next_state;
	end

endmodule

module datapath(
	input reset,
	input clock,
	input enable,
	input increment,
	input [2:0] colour_in,
	input [1:0] direction,
	input capture,
	input ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10,
	input left, right, up, down,
	input ld_player,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] colour_out,
	output collision
	);

	wire [14:0] rand_coord, blk;
	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] colour;
	wire [3:0] blk_count;
	wire inc;
	wire [4:0] count0, count1;
	wire [2:0] colour_d;

	random_generator d1 (reset, clock, 1'b1, direction, capture, rand_coord);
	counter_1 d2 (clock, reset, enable, count0);
	rate_divider_draw t1(clock, reset, enable, r_d);
	counter_2 d3 (clock, reset, r_d, count1);
	assign inc = (count0 == 5'b10011 & count1 == 5'b10011) ? 1 : 0;
	blk_counter d4 (reset, clock, inc, blk_count);
	register_blk d5 (reset, clock, rand_coord, increment, direction, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, ld_player, blk_count, left, right, up, down, blk, collision, colour_en);
	assign colour_d = colour_en ? 3'b010 : colour_in;
	draw d6 (reset, clock, enable, blk, colour_d, x, y, colour);
	draw d7 (reset, clock, ld_player, 15'b01000100110001, 3'b010, x, y, colour);
	assign x_out = x;
	assign y_out = y;
	assign colour_out = colour;
endmodule

module register_blk(
	input reg_reset,
	input reg_clock,
	input [14:0] reg_coord_in,
	input reg_enable,
	input [1:0] reg_dir,
	input ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10,
	input ld_player,
	input [3:0] reg_count,
	input left, right, up, down,
	output reg [14:0] blk_out,
	output reg collision,
	output reg colour_out
	);

	wire [14:0] player, blk1, blk2, blk3, blk4, blk5, blk6, blk7, blk8, blk9, blk10;
	reg ud_or_lr;
	wire [4:0] blk_decision;

	player_move q4 (reg_reset, reg_clock, 15'b01000100110001, reg_enable, ld_player, left, right, up, down, player);
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

	always @(*)
	begin
		colour_out = 1'b0;

		case (reg_count[3:0])
			4'b0000: blk_out = player, colour_out = 1'b1;
			4'b0001: blk_out = blk1;
			4'b0010: blk_out = blk2;
			4'b0011: blk_out = blk3;
			4'b0100: blk_out = blk4;
			4'b0101: blk_out = blk5;
			4'b0110: blk_out = blk6;
			4'b0111: blk_out = blk7;
			4'b1000: blk_out = blk8;
			4'b1001: blk_out = blk9;
			4'b1010: blk_out = blk10
			default: blk_out = 15'b0;
		endcase
	end

	always @(posedge reg_clock)
	begin
		if (player == blk1 | player == blk2 | player == blk3 | player == blk4 | player == blk5 | player == blk6 | player == blk7 | player == blk8 | player == blk9 | player == blk10)
			collision = 1'b1;
		else
			collision = 1'b0;
endmodule


module counter_ld(
	input clk,
	input reset,
	input en,
	output reg [2:0] q
	);

	always @(posedge clk)
	begin
		if (~reset)
			q <= 3'b000;
		else if (en)
		begin
			if (q == 3'b100)
				q <= 3'b0;
			else
				q <= q + 1'b1;
		end
	end
endmodule

module mux_ld_blk(
	input [1:0] direction,
	input [2:0] ld_number,
	output reg ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10
	);

	reg ud_or_lr;
	wire [3:0] dir_ld_num;

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

	assign dir_ld_num = {ud_or_lr, ld_number};

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

		case (dir_ld_num [3:0])
			4'b0000: ld_blk1 = 1'b1;
			4'b0001: ld_blk2 = 1'b1;
			4'b0010: ld_blk3 = 1'b1;
			4'b0011: ld_blk4 = 1'b1;
			4'b0100: ld_blk5 = 1'b1;
			4'b1000: ld_blk6 = 1'b1;
			4'b1001: ld_blk7 = 1'b1;
			4'b1010: ld_blk8 = 1'b1;
			4'b1011: ld_blk9 = 1'b1;
			4'b1100: ld_blk10 = 1'b1;
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
	assign blk_coord = {blk_x, blk_y};

endmodule

module blk_counter(
	input reset,
	input clock,
	input en,
	output reg [3:0] q
	);

	always @(posedge clock)
	begin
		if (~reset)
			q <= 4'b0;
		else if (en)
		begin
			if (q == 4'b1001)
				q <= 4'b0;
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

	random g0(
    		.rand_reset(random_reset),
    		.rand_clock(random_clock),
    		.rand_en(random_en),
    		.rand_out(random_num)
    		);

	reg_rand g1(
			.reg_reset(random_reset),
			.reg_clock(random_clock),
			.reg_en(capture),
			.rand_num_in(random_num),
			.current(current_num),
			.prev(prev_num)
			);

	filter g2(
			.filt_reset(random_reset),
			.filt_clock(random_clock),
			.cur_num_in(current_num),
			.prev_num_in(prev_num),
			.filt_num_out(rand_num)
			);

	rand_coord_mux g3(
   			.coord_mux_reset(random_reset),
   			.coord_mux_clock(random_clock),
   			.num_dir({dir, rand_num}),
   			.random_coord(random_coord)
   			);

endmodule

module random(
	input rand_reset,
	input rand_clock,
	output reg [2:0] rand_out
	);
    
    always @(posedge rand_clock)
    begin
        if (~rand_reset)
            rand_out <= 0;
        else
        begin
            rand_out <= {$random} % 5;
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

	always @(posedge clock)
	begin
		if (~move_reset)
			player_x <= 8'b0;
		else if (ld_player)
		begin
			player_x <= x_in;
		end
		else
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
				else
				begin
					player_x <= player_x;
				end
			end
		end
	end
endmodule

module player_move_y(
	input move_reset,
	input move_clock,
	input [7:0] y_in,
	input move_enable,
	input ld_player,
	input up, down, 
	output reg [7:0] player_y
	);

	always @(posedge clock)
	begin
		if (~move_reset)
			player_y <= 7'b0;
		else if (ld_player)
		begin
			player_y <= y_in;
		end
		else
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
endmodule