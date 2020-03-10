module random (clock, reset, r);
    input clock, reset;
    output reg [2:0] r;
    
    always @(posedge clock)
    begin
        if (~reset)
            r <= 0;
        else
        begin
            r <= {$random} % 5;
        end    
    end
    
endmodule
