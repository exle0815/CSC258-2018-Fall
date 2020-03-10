module part_2(SW, CLOCK_50, HEX0);
	input [9:0] SW;
	input CLOCK_50;
	output [6:0] HEX0;
	
	wire [27:0] mux_to_rate_divider;
	wire [3:0] counter_to_hex;
	wire  rate_divider_to_counter;
	
	mux4to1 m0(
			.a(28'b0),
			.b(28'd49999999),
			.c(28'd99999999),
			.d(28'd199999999),
			.sel(SW[1:0]),
			.m(mux_to_rate_divider[27:0])
			);
			
	rate_divider m1(.d(mux_to_rate_divider[27:0]), .en(1'b1), .clk(CLOCK_50), .par_load(SW[2]), .clear_b(SW[3]), 
			.q(rate_divider_to_counter));
			
	display_counter m2(.en_display(rate_divider_to_counter), .clk(CLOCK_50), .clear_b(SW[3]), .q(counter_to_hex[3:0]));
	
	val_to_hex m3(.c(counter_to_hex[3:0]), .m(HEX0[6:0]));
	
endmodule

module mux4to1(a, b, c, d, sel, m);
	input [27:0] a, b, c, d;
	input [1:0] sel;
	output [27:0] m;
	
	reg [27:0] m;
	
	always @(*)
	
	begin
	
		case (sel[1:0])
			2'b00: m = a;
			2'b01: m = b;
			2'b10: m = c;
			2'b11: m = d;
			default: m = 28'b0;
		endcase
	end
	
endmodule

module rate_divider(d, en, clk, par_load, clear_b, q);
	input [27:0] d;
	input en, clk, par_load, clear_b;
	output q;
	
	reg [27:0] out;
	
	always @(posedge clk)
	begin
		if (clear_b == 1'b0)
			out <= 28'b1;
		else if (par_load == 1'b1)
			out <= d;
		else if (en == 1'b1)
			begin
				if (out == 28'b0)
					out <= d;
				else 
					out <= out - 1'b1;
			end
			
	end

	assign q = (out == 28'b0) ? 1 : 0;

endmodule

module display_counter(en_display, clk, clear_b, q);
	input en_display, clk, clear_b;
	output [3:0] q;
	
	reg [3:0] out;
	always @(posedge clk)
	begin
		if (clear_b == 1'b0)
			out <= 4'b0;
		else if (en_display == 1'b1)
			begin
				if (out == 4'b1111)
					out <= 4'b0;
				else
					out <= out + 4'b0001;
			end
		else if (en_display == 1'b0)
			out <= out;
	end
	assign q = out;
endmodule

module val_to_hex(c, m);
	input [3:0] c;
	output [6:0] m;
	
	reg [6:0] m;
	always @(*)
	begin
		case (c)
			4'h0: m = 7'b1000000;
			4'h1: m = 7'b1111001;
			4'h2: m = 7'b0100100;
			4'h3: m = 7'b0110000;
			4'h4: m = 7'b0011001;
			4'h5: m = 7'b0010010;
			4'h6: m = 7'b0000010;
			4'h7: m = 7'b1111000;
			4'h8: m = 7'b0000000;
			4'h9: m = 7'b0010000;
			4'ha: m = 7'b0001000;
			4'hb: m = 7'b0000011;
			4'hc: m = 7'b0000110;
			4'hd: m = 7'b0100001;
			4'he: m = 7'b0000110;
			4'hf: m = 7'b0001110;
			default m = 7'b1000000;
		endcase
	end
endmodule

			
			
	