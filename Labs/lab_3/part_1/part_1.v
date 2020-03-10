module part_1(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;

	mux7to1 u0(
			.Input(SW[6:0]), 
			.MuxSelect(SW[9:7]), 
			.Out(LEDR[9]));
endmodule

module mux7to1(Input, MuxSelect, Out);
	input [6:0] Input;
	input [2:0] MuxSelect;
	output Out;


	reg Out0;

	always @(*)
	begin
		case (MuxSelect[2:0])
			3'b000: Out0 = Input[0];
			3'b001: Out0 = Input[1];
			3'b010: Out0 = Input[2];
			3'b011: Out0 = Input[3];
			3'b100: Out0 = Input[4];
			3'b101: Out0 = Input[5];
			3'b110: Out0 = Input[6];
			default: Out0 = 1'b0;
		endcase
	end
	assign Out = Out0;

endmodule
