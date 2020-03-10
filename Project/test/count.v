module count(
	input clock,
	input reset,
	input enable
	);

	wire [2:0] blk_count;
	wire resetn;
	wire [4:0] out, out_r_d;

	delay_counter c1 (reset, clock, enable, rd);
	block_frame_counter c2 (reset, clock, rd, frame_count);
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