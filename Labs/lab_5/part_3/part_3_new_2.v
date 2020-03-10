module part_3(SW, KEY, LEDR);
	input [9:0] SW, KEY;
	output [9:0] LEDR;
	
	morsecode z0(.select(SW[2:0]), .start(KEY[1]), .clock(CLOCK_50), .clear(KEY[0]), .morseout(LEDR[0]));
endmodule

module morsecode(select, start, clock, clear, morseout);
	input [2:0] select;
	input start, clock, clear;
	output morseout;

	wire divider_to_register;
	wire [13:0] mux_to_register;

	reg rate_divider_en, par_load;

	always @(negedge start, negedge clear)
	begin
		if (clear == 1'b0)
			begin
			par_load <= 1;
			rate_divider_en <= 0;
			end
		else if (start == 1'b0)
			begin
			par_load <= 0;
			rate_divider_en <= 1;
			end
	end

	
	rate_divider r0(.d(25'd3), .en(rate_divider_en), .clk(CLOCK_50), .clear_b(clear), 
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
			.sel(select),
			.result(mux_to_register[13:0])
			);
			
	shifter r2(.data(mux_to_register[13:0]), .enable(divider_to_register), .par_load(par_load), .clear_b(clear), 
			.clk(CLOCK_50), .out(morseout));

endmodule

module shifter(data, enable, par_load, clear_b, clk, out);
	input [13:0] data;
	input enable, par_load, clear_b, clk;
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
		else if (par_load == 1'b1)
			begin
			out <=1'b0;
			q <= data;
			end
		else if (enable == 1'b1)
			begin
			out <= q[0];
			q <= q >> 1'b1;
			end
	end
endmodule

module rate_divider(d, en, clk, clear_b, q);
	input [24:0]d;
	input en, clk, clear_b;
	output q;
	
	reg [24:0] out;
	always @(posedge clk, negedge clear_b)
	begin
		if (clear_b == 1'b0)
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
	
	reg [13:0] mux_out;
	always @(*)
	begin
		case (sel[2:0])
			3'b000: mux_out = 14'b00000000010101;
			3'b001: mux_out = 14'b00000000000111;
			3'b010: mux_out = 14'b00000001110101;
			3'b011: mux_out = 14'b00000111010101;
			3'b100: mux_out = 14'b00000111011101;
			3'b101: mux_out = 14'b00011101010111;
			3'b110: mux_out = 14'b01110111010111;
			3'b111: mux_out = 14'b00010101110111;
			default: mux_out = 14'b0;
		endcase
	end
	assign result = mux_out;

endmodule