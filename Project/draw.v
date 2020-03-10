module draw(
	input reset,
	input clock,
	input enable,
	input [14:0] new_coord,
	output [7:0] x,
	output [6:0] y,
	output [2:0] colour
	);
	wire [4:0] count0, count1;

	counter_draw_x t0(clock, reset, enable, count0);
	rate_divider_draw t1(clock, reset, enable, r_d);
	counter_draw_y t3(clock, reset, r_d, count1);
	assign x = new_coord[14:7] + count0;
	assign y = new_coord[6:0] + count1;
	assign colour = 3'b100;
endmodule

module erase(
	input reset,
	input clock,
	input enable,
	input [14:0] new_coord,
	output [7:0] x,
	output [6:0] y,
	output [2:0] colour
	);
	wire [4:0] count0, count1;
	
	counter_draw_x t0(clock, reset, enable, count0);
	rate_divider_draw t1(clock, reset, enable, r_d);
	counter_draw_y t3(clock, reset, r_d, count1);
	assign x = new_coord[14:7] + count0;
	assign y = new_coord[6:0] + count1;
	assign colour = 3'b000;

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
			q <= 5'b10100;
		else if (en)
		begin
			if (q == 5'b10100)
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
			q <= 5'b0;
		else if (en)
		begin
			if (q == 5'b10100)
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
			out <= 5'b10101;
		else if (en)
		begin 
			if (out == 5'b00000)
				out <= 5'b10100;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 5'b00000) ? 1 : 0;

endmodule