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
