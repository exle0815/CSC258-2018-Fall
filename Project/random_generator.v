module random_generator(
	input random_reset,
	input random_clock,
	input [1:0] dir,
	input capture,
	output [14:0] random_coord
	);

	wire [3:0] rand_out, current_num, prev_num;
	wire [5:0] num_dir;

	random g0(random_reset, random_clock, rand_out);
	reg_rand g1(random_reset, random_clock, capture, rand_out, current_num, prev_num);
	filter g2(random_reset, random_clock, current_num, prev_num, random_number);
	assign num_dir = {dir, random_number};
	rand_coord_mux g3(random_reset, random_clock, num_dir, random_coord);

endmodule

module random(
	input random_reset,
	input random_clock,
	output [3:0] random_out
	);
	wire random_signal;
	wire [3:0] rand_out;

	random_piece z0 (random_reset, random_clock, random_signal, ran_en0, rand_out[0]);
	random_piece_dif z1 (random_reset, random_clock, ran_en0, ran_en1, rand_out[1]);
	random_piece_dif z2 (random_reset, random_clock, ran_en1, ran_en2, rand_out[2]);
	random_piece z3 (random_reset, random_clock, ran_en2, ran_en3, rand_out[3]);
	assign random_signal = ran_en2 ^ ran_en3;
	assign random_out = rand_out % 4'd5;


endmodule

module random_piece_dif(
	input ran_reset,
	input ran_clock,
	input ran_in,
	output ran_sig,
	output ran_out
	);

	reg out;

	always @ (posedge ran_clock)
	begin
		if (~ran_reset)
			out <= 1'b1;
		else if (ran_in)
			out <= ~out;
	end

	assign ran_sig = out;
	assign ran_out = out;
endmodule

module random_piece(
	input ran_reset,
	input ran_clock,
	input ran_in,
	output ran_sig,
	output ran_out
	);

	reg out;

	always @ (posedge ran_clock)
	begin
		if (~ran_reset)
			out <= 1'b0;
		else if (ran_in)
			out <= ~out;
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