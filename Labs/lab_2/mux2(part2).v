//SW[3:0] data inputs
//SW[9:8] select signal

//LEDR[0] output display

module mux2(LEDR, SW);
    input [9:0] SW;
    output [9:0] LEDR;

    mux4to1 u0(
        .u(SW[0]),
        .w(SW[1]),
        .v(SW[2]),
        .x(SW[3]),
        .s1(SW[8]),
        .s0(SW[9]),
        .m(LEDR[0])
        );
endmodule

module mux4to1(u, v, w, x, s0, s1, m);
    input u; //selected when s0 is 0 and s1 is 0
    input v; //selected when s0 is 1 and s1 is 0
    input w; //selected when s0 is 0 and s1 is 1
    input x; //selected when s0 is 1 and s1 is 1 
    input s0; //select signal0
    input s1; //select signal1
    output m; //output
    
    wire Connection01, Connection02; //wire connections
    
    mux2to1 b0(
        .a(u),
        .b(w),
        .s(s1),
        .out(Connection01)
        );
    
    mux2to1 b1(
        .a(v),
        .b(x),
        .s(s1),
        .out(Connection02)
        );

    mux2to1 b2(
        .a(Connection01),
        .b(Connection02),
        .s(s0),
        .out(m)
        );
endmodule

module mux2to1(a, b, s, out);
    input a; //selected when s is 0
    input b; //selected when s is 1
    input s; //select signal
    output out; //output
  
    assign out = s & b | ~s & a;

endmodule

