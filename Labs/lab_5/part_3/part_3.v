module part_3(SW, KEY, LEDR, CLOCK_50);
	input [9:0] SW, KEY;
	input CLOCK_50;
	output [9:0] LEDR;
	
	wire divider_to_register;
	wire [13:0] mux_to_register;
	
	rate_divider r0(.start(KEY[1]), .rate_d(25'd3), .en(1'b1), .clk(CLOCK_50), .clear_b(KEY[0]), 
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
			
	shifter r2(.start(KEY[1]), .shift_d(mux_to_register[13:0]), .enable(divider_to_register), .clear_b(KEY[0]), 
			.clk(CLOCK_50), .out(LEDR[0]));

endmodule

module shifter(start, shift_d, enable, clear_b, clk, out);
	input [13:0] shift_d;
	input start, enable, clear_b, clk;
	output out;

	reg out;
	reg [13:0] q;

	always @(posedge clk, negedge clear_b)
	begin
		if (clear_b == 1'b0)
			begin
			out <= 1'b0;
			q <= 14'b0;
			end
		else if (start == 1'b0)
			begin
			out <= 1'b0;
			q <= shift_d;
			end
		else if (enable == 1'b1)
			begin
			out <= q[0];
			q <= q >> 1'b1;
			end
	end
endmodule

module rate_divider(start, rate_d, en, clk, clear_b, q);
	input [24:0] rate_d;
	input start, en, clk, clear_b;
	output q;
	
	reg [24:0] out;
	always @(posedge clk, negedge clear_b)
	begin
		if (clear_b == 1'b0)
			out <= 25'd1;
		else if (start == 1'b0)
			out <= rate_d;
		else if (en == 1'b1)
			begin
				if (out == 25'b0)
					out <= rate_d;
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