//This is a version that delay counter is shrink so that it can be tested on modelsim. 
//But the frame counter is not changed.

module project(
	CLOCK_50,						
    KEY,						
	);

	input			CLOCK_50;				
	input   [3:0]   KEY;  	
	
	wire reset, go, go2;
	assign reset = KEY[0];
	assign go = ~KEY[1];
	assign go2 = ~KEY[2];
	
	wire [2:0] colour, colour_in;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire draw, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, capture, increment;
	wire [1:0] direction;
	wire stop;
	wire [4:0] count0, count1, frame_count;
	wire [3:0] blk_count;
	
	control c0(reset, CLOCK_50, go, go2, 1'b0, stop, ld_map, colour_in, direction, capture, increment, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, draw, resetn, writeEn, count_sec);

	datapath d0(reset, CLOCK_50, draw, increment, colour_in, direction, capture, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, x, y, colour, stop, reset_counter, count0, count1, frame_count, blk_count);

endmodule

module control(
	input reset,
	input clock,
	input go,
	input go2,
	input rotation,
	input stop,
	output reg ld_map,
	output reg [2:0] colour,
	output reg [1:0] direction, 
	output reg capture,
	output reg increment,
	output ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10,
	output reg draw,
	output reg resetn,
	output reg wren,
	output reg count_sec
	);

	wire [2:0] ld_num;
	wire incre;
	wire r_d_three;
	reg ld_blk;
	assign incre = increment;

	reg [4:0] current_state, next_state;

	localparam  PREPARE			= 5'd0,
					MAIN				= 5'd1,
					MAIN_WAIT 		= 5'd2,
					D0_CAPTURE		= 5'd3,
					D0_INCRE   		= 5'd4,
					D0_DRAW			= 5'd5;
	
	count_three c7 (reset, clock, incre, r_d_three);

	always @(*)
	begin: state_table
		case (current_state)
			PREPARE : next_state = MAIN;
			MAIN : next_state = go ? MAIN_WAIT : MAIN;
			MAIN_WAIT : next_state = go ? MAIN_WAIT : D0_CAPTURE;
			D0_CAPTURE: next_state = D0_INCRE;
			D0_INCRE: next_state = r_d_three ? D0_DRAW : D0_INCRE;
			D0_DRAW: next_state = stop ? D0_CAPTURE : D0_DRAW; 
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
		ld_blk = 1'b0;
		resetn = 1'b1;

		case (current_state)
			PREPARE:
			begin
				ld_map = 1'b1;
				colour = 3'b001;
			end
			D0_CAPTURE:
			begin
				direction = 2'b00;
				capture = 1'b1;
				count_sec = 1'b1;
				resetn = 1'b0;
			end
			D0_INCRE:
			begin
				direction = 2'b00;
				increment = 1'b1;
				count_sec = 1'b1;
				ld_blk = 1'b1;
			end
			D0_DRAW:
			begin
				direction = 2'b00;
				draw = 1'b1;
				colour = 3'b100;
				wren = 1'b1;
				count_sec = 1'b1;
			end
		endcase
	end

	counter_ld c3(clock, reset, capture, ld_num);
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
	input enable,
	input increment,
	input [2:0] colour_in,
	input [1:0] direction,
	input capture,
	input ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] colour_out,
	output stop,
	output reset_counter0,
	output [4:0] count00,
	output [4:0] count11,
	output [4:0] frame_count0,
	output [3:0] blk_count0
	);

	wire [14:0] rand_coord, blk;
	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] colour, colour_new;
	wire [3:0] blk_count;
	wire inc, erase;
	wire [4:0] count0, count1, frame_count;
	wire reset_counter;

	random_generator d1 (reset, clock, direction, capture, rand_coord);
	counter_1 d2 (clock, reset, reset_counter, enable, count0);
	rate_divider_count d3(clock, reset, reset_counter, enable, r_d);
	counter_2 d4 (clock, reset, reset_counter, r_d, count1);
	assign inc = (count0 == 5'b10011 & count1 == 5'b10011) ? 1 : 0;
	blk_counter d5 (reset, clock, reset_counter, inc, blk_count);
	register_blk d6 (reset, clock, rand_coord, increment, direction, ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10, blk_count, blk);
	delay_counter d7 (reset, clock, resetn, enable, rd);
	block_frame_counter d8 (reset, clock, resetn, rd, erase, frame_count);
	assign colour_new = (erase == 1'b1) ? 3'b000 : colour_in;
	assign reset_counter = (rd == 1'b1 & frame_count == 5'b11101) ? 0 : 1;
	draw d9 (reset, clock, reset_counter, enable, blk, colour_new, x, y, colour);
	assign stop = (blk_count == 4'b1001 & erase) ? 1 : 0;
	assign x_out = x;
	assign y_out = y;
	assign colour_out = colour;
	assign reset_counter0 = reset_counter;
	assign count00 = count0;
	assign count11 = count1;
	assign frame_count0 = frame_count;
	assign blk_count0 = blk_count;

endmodule

module register_blk(
	input reg_reset,
	input reg_clock,
	input [14:0] reg_coord_in,
	input reg_enable,
	input [1:0] reg_dir,
	input ld_blk1, ld_blk2, ld_blk3, ld_blk4, ld_blk5, ld_blk6, ld_blk7, ld_blk8, ld_blk9, ld_blk10,
	input [3:0] reg_count,
	output reg [14:0] blk_out
	);

	wire [14:0] blk1, blk2, blk3, blk4, blk5, blk6, blk7, blk8, blk9, blk10;

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
		case (reg_count[3:0])
			4'b0000: blk_out = blk1;
			4'b0001: blk_out = blk2;
			4'b0010: blk_out = blk3;
			4'b0011: blk_out = blk4;
			4'b0100: blk_out = blk5;
			4'b0101: blk_out = blk6;
			4'b0110: blk_out = blk7;
			4'b0111: blk_out = blk8;
			4'b1000: blk_out = blk9;
			4'b1001: blk_out = blk10;
			default: blk_out = 15'b0;
		endcase
	end
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
			q <= 3'b100;
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
			5'b00000: ld_blk1 = 1'b0;
			5'b00001: ld_blk2 = 1'b0;
			5'b00010: ld_blk3 = 1'b0;
			5'b00011: ld_blk4 = 1'b0;
			5'b00100: ld_blk5 = 1'b0;
			5'b01000: ld_blk6 = 1'b0;
			5'b01001: ld_blk7 = 1'b0;
			5'b01010: ld_blk8 = 1'b0;
			5'b01011: ld_blk9 = 1'b0;
			5'b01100: ld_blk10 = 1'b0;
			5'b10000: ld_blk1 = 1'b1;
			5'b10001: ld_blk2 = 1'b1;
			5'b10010: ld_blk3 = 1'b1;
			5'b10011: ld_blk4 = 1'b1;
			5'b10100: ld_blk5 = 1'b1;
			5'b11000: ld_blk6 = 1'b1;
			5'b11001: ld_blk7 = 1'b1;
			5'b11010: ld_blk8 = 1'b1;
			5'b11011: ld_blk9 = 1'b1;
			5'b11100: ld_blk10 = 1'b1;
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

module count_three(
	input reset,
	input clock,
	input enable,
	output out
	);

	reg [1:0] q;

	always @(posedge clock)
	begin
		if (~reset)
			q <= 2'b0;
		else if (enable)
		begin
			if (q == 2'b10)
				q <= 2'b0;
			else
				q <= q + 1'b1;
		end
	end

	assign out = (q == 2'b10) ? 1 : 0;
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
	input [1:0] dir,
	input capture,
	output [14:0] random_coord
	);

	wire [2:0] random_num, current_num, prev_num, rand_num;

	random g0(
    		.rand_reset(random_reset),
    		.rand_clock(random_clock),
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
			if (cur_num_in == prev_num_in + 1'b1)
				filt_num_out <= (cur_num_in + 1'b1) % 5;
			else if (cur_num_in == prev_num_in - 1'b1)
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
	input reset_count,
	input enable,
	input [14:0] new_coord,
	input [2:0] colour_in,
	output [7:0] x,
	output [6:0] y,
	output [2:0] colour
	);
	wire [4:0] count_0, count_1;

	counter_draw_x t0 (clock, reset, reset_count, enable, count_0);
	rate_divider_draw t1(clock, reset, reset_count, enable, rd);
	counter_draw_y t2 (clock, reset, reset_count, rd, count_1);
	assign x = new_coord[14:7] + count_0;
	assign y = new_coord[6:0] + count_1;
	assign colour = (x < 8'd20 | ~enable) ? 3'b0 : colour_in;
endmodule

module counter_draw_x(
	input clock,
	input reset,
	input reset_count,
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset | ~reset_count)
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
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset | ~reset_count)
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
	input en,
	output q
	);
	reg [4:0] out;

	always @(posedge clock)
	begin
		if (~reset | ~reset_count)
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

module counter_1(
	input clock,
	input reset,
	input reset_counter,
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset | ~reset_counter)
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

module counter_2(
	input clock,
	input reset,
	input reset_counter,
	input en,
	output reg [4:0] q
	);

	always @(posedge clock)
	begin
		if (~reset | ~reset_counter)
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

module rate_divider_count(
	input clock,
	input reset,
	input reset_counter,
	input en,
	output q
	);
	reg [4:0] out;

	always @(posedge clock)
	begin
		if (~reset | ~reset_counter)
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
	reg [7:0] out;

	always @(posedge clock)
	begin
		if (~resetn | ~resetnew)
			out <= 8'b10100110;
		else if (en)
		begin 
			if (out == 8'b0)
				out <= 8'b10100110;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 8'b0) ? 1 : 0;

endmodule

module block_frame_counter(
	input resetn,
	input clock,
	input resetnew,
	input en,
	output q,
	output reg [4:0] out
	);

	always @(posedge clock)
	begin
		if (~resetn | ~resetnew)
			out <= 5'b0000;
		else if (en)
		begin 
			if (out == 5'b11110)
				out <= 5'b0;
			else
			 	out <= out + 1'b1;
		end
	end
	assign q = (out == 5'b11110) ? 1 : 0;

endmodule

module player_frame_counter(
	input resetn,
	input clock,
	input en,
	output q
	);
	reg [3:0] out;

	always @(posedge clock)
	begin
		if (~resetn)
			out <= 4'b0111;
		else if (en)
		begin 
			if (out == 4'b0111)
				out <= 4'b0000;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 4'b0000) ? 1 : 0;

endmodule