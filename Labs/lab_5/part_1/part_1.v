module part_1(SW, KEY, HEX0, HEX1);
	input [9:0] SW, KEY;
	output [6:0] HEX0, HEX1;
	
	wire [7:0] out_to_hex;
	
	counter c0(.Enable(SW[1]), .Clear_b(SW[0]), .Clk(KEY[0]), .out(out_to_hex));
	
	value_to_HEX c1(.C(out_to_hex[3:0]), .m(HEX0));
			
	value_to_HEX c2(.C(out_to_hex[7:4]), .m(HEX1));
	
endmodule

module counter(Enable, Clear_b, Clk, out);
	input Enable, Clear_b, Clk;
	output [7:0] out;
	
	wire [7:0] next_FF;
	
	counter_piece q0(.en(Enable), .clear_b(Clear_b), .clk(Clk), .counter_out0(next_FF[0]), .counter_out1(out[0]));
	counter_piece q1(.en(next_FF[0]), .clear_b(Clear_b), .clk(Clk), .counter_out0(next_FF[1]), .counter_out1(out[1]));
	counter_piece q2(.en(next_FF[1]), .clear_b(Clear_b), .clk(Clk), .counter_out0(next_FF[2]), .counter_out1(out[2]));
	counter_piece q3(.en(next_FF[2]), .clear_b(Clear_b), .clk(Clk), .counter_out0(next_FF[3]), .counter_out1(out[3]));
	counter_piece q4(.en(next_FF[3]), .clear_b(Clear_b), .clk(Clk), .counter_out0(next_FF[4]), .counter_out1(out[4]));
	counter_piece q5(.en(next_FF[4]), .clear_b(Clear_b), .clk(Clk), .counter_out0(next_FF[5]), .counter_out1(out[5]));
	counter_piece q6(.en(next_FF[5]), .clear_b(Clear_b), .clk(Clk), .counter_out0(next_FF[6]), .counter_out1(out[6]));
	counter_piece q7(.en(next_FF[6]), .clear_b(Clear_b), .clk(Clk), .counter_out0(next_FF[7]), .counter_out1(out[7]));
	
endmodule

module counter_piece(en, clear_b, clk, counter_out0, counter_out1);
	input en, clear_b, clk;
	output counter_out0, counter_out1;
	
	reg out;
	
	always @(posedge clk, negedge clear_b)
	
	begin
		if (clear_b == 1'b0)
		
			out <= 1'b0;
		
		else if (en == 1'b1)
			
			out <= ~out;
	
	end
	
	assign counter_out0 = out & en;
	assign counter_out1 = out;
	
endmodule

module value_to_HEX(C, m);
	input [3:0]C;
	output [6:0]m;
	
	assign m[0] = (~C[3]&~C[2]&~C[1]&C[0])|(~C[3]&C[2]&~C[1]&~C[0])|(C[3]&C[2]&~C[1]&C[0])|(C[3]&~C[2]&C[1]&C[0]);
	assign m[1] = (~C[3]&C[2]&~C[1]&C[0])|(C[2]&C[1]&~C[0])|(C[3]&C[1]&C[0])|(C[3]&C[2]&~C[0]);
	assign m[2] = (~C[3]&~C[2]&C[1]&~C[0])|(C[3]&C[2]&C[1])|(C[3]&C[2]&~C[0]);
	assign m[3] = (~C[2]&~C[1]&C[0])|(C[2]&C[1]&C[0])|(~C[3]&C[2]&~C[1]&~C[0])|(C[3]&~C[2]&C[1]&~C[0]);
	assign m[4] = (~C[2]&~C[1]&C[0])|(~C[3]&C[2]&~C[1])|(~C[3]&C[1]&C[0]);
	assign m[5] = (~C[3]&~C[2]&C[0])|(~C[3]&~C[2]&C[1])|(~C[3]&C[1]&C[0])|(C[3]&C[2]&~C[1]&C[0]);
	assign m[6] = (~C[3]&~C[2]&~C[1])|(~C[3]&C[2]&C[1]&C[0])|(C[3]&C[2]&~C[1]&~C[0]);
	
endmodule
	