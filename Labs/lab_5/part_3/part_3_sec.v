module part_3(SW, KEY, LEDR);
	input [9:0] SW, KEY;
	output [9:0] LEDR;
	
	wire divider_to_register;
	wire [13:0] mux_to_register;
	
	rate_divider r0(.start(KEY[1]), .d(25'd24999999), .en(1'b1), .clk(CLOCK_50), .clear_b(KEY[0]), 
			.q(divider_to_register));
	mux8to1 r1(
			.s(14'b10101000000000), 
			.t(14'b11100000000000),
			.u(14'b10101110000000),
			.v(14'b10101011100000),
			.w(14'b10111011100000),
			.x(14'b11101010111000),
			.y(14'b11101011101110),
			.z(14'b11101110101000),
			.sel(SW[2:0]),
			.result(mux_to_register[13:0])
			);
	shift_register r2(.d(mux_to_register[13:0]), .en(divider_to_register), .clk(CLOCK_50), .clear_b(KEY[0]),
			.q(LEDR[0]));
endmodule

module rate_divider(start, d, en, clk, clear_b, q);
	input [24:0]d;
	input start, en, clk, clear_b;
	output q;
	
	reg [24:0] out;
	always @(posedge clk, negedge clear_b)
	begin
		if (clear_b == 1'b0)
			out <= 25'b1;
		else if (start == 1'b0)
			out <= d;
		else if (en == 1'b1)
			begin
				if (out == 25'b0)
					out <= d;
				else
					out <= out - 1'b1;
			end
	end
   assign q = (out == 25'b0) ? 1 : 0;
endmodule

module mux8to1(s, t, u, v, w, x, y, z, sel, result);
	input [13:0] s, t, u, v, w, x, y, z;
	input [2:0] sel;
	output [13:0] result;
	
	reg [13:0] result;
	always @(*)
	begin
		case (sel[2:0])
			3'b000: result = 14'b00000000010101;
			3'b001: result = 14'b00000000000111;
			3'b010: result = 14'b00000001110101;
			3'b011: result = 14'b00000111010101;
			3'b100: result = 14'b00000111011101;
			3'b101: result = 14'b00011101010111;
			3'b110: result = 14'b01110111010111;
			3'b111: result = 14'b00010101110111;
			default: result = 14'b0;
		endcase
	end
endmodule

module shift_register(d, en, clear_b, clk, q);
	input [13:0] d;
	input en, clear_b, clk;
	output q;
	
	wire [12:0] piece_between;
	
	shift_register_piece s0(.piece_d(d[13:0]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[0]));
	shift_register_piece s1(.piece_d(piece_between[0]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[1]));
	shift_register_piece s2(.piece_d(piece_between[1]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[2]));
	shift_register_piece s3(.piece_d(piece_between[2]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[3]));
	shift_register_piece s4(.piece_d(piece_between[3]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[4]));
	shift_register_piece s5(.piece_d(piece_between[4]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[5]));
	shift_register_piece s6(.piece_d(piece_between[5]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[6]));
	shift_register_piece s7(.piece_d(piece_between[6]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[7]));
	shift_register_piece s8(.piece_d(piece_between[7]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[8]));
	shift_register_piece s9(.piece_d(piece_between[8]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[9]));
	shift_register_piece s10(.piece_d(piece_between[9]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[10]));
	shift_register_piece s11(.piece_d(piece_between[10]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[11]));
	shift_register_piece s12(.piece_d(piece_between[11]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(piece_between[12]));
	shift_register_piece s13(.piece_d(piece_between[12]), .piece_en(en), .piece_clear_b(clear_b), .piece_clk(clk), 
			.piece_out(q));
endmodule

module shift_register_piece (piece_d, piece_en, piece_clear_b, piece_clk, piece_out);
	input piece_d, piece_en, piece_clear_b, piece_clk;
	output piece_out;
			

	reg [13:0] reg_out;
	
	always @(posedge piece_clk, negedge piece_clear_b)
	begin
		if (piece_clear_b == 1'b0)
			reg_out <= 1'b0;
		else if (piece_en == 1'b1)
			reg_out <= piece_d;
		else if (piece_en == 1'b0)
			reg_out <= reg_out;
	end
	
	assign piece_out = reg_out;
endmodule
