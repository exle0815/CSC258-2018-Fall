//Seven segment decoder for BCD inputs from 0 to 9
module seven_seg_decoder(C,HEX0);

input [3:0]C;
output [6:0]HEX0;

assign HEX0[0] = (~C[3]&~C[2]&~C[1]&C[0])|(~C[3]&C[2]&~C[1]&~C[0])|(C[3]&C[2]&~C[1]&C[0])|(C[3]&~C[2]&C[1]&C[0]);
assign HEX0[1] = (~C[3]&C[2]&~C[1]&C[0])|(C[2]&C[1]&~C[0])|(C[3]&C[1]&C[0])|(C[3]&C[2]&~C[0]);
assign HEX0[2] = (~C[3]&~C[2]&C[1]&~C[0])|(C[3]&C[2]&C[1])|(C[3]&C[2]&~C[0]);
assign HEX0[3] = (~C[2]&~C[1]&C[0])|(C[2]&C[1]&C[0])|(~C[3]&C[2]&~C[1]&~C[0])|(C[3]&~C[2]&C[1]&~C[0]);
assign HEX0[4] = (~C[2]&~C[1]&C[0])|(~C[3]&C[2]&~C[1])|(~C[3]&C[1]&C[0]);
assign HEX0[5] = (~C[3]&~C[2]&C[0])|(~C[3]&~C[2]&C[1])|(~C[3]&C[1]&C[0])|(C[3]&C[2]&~C[1]&C[0]);
assign HEX0[6] = (~C[3]&~C[2]&~C[1])|(~C[3]&C[2]&C[1]&C[0])|(C[3]&C[2]&~C[1]&~C[0]);

endmodule