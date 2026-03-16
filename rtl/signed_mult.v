module signed_mult #(parameter WIDTH = 18)(
    output signed [WIDTH-1:0] out,
    input  signed [WIDTH-1:0] a,
    input  signed [WIDTH-1:0] b
);

    wire signed [(2*WIDTH)-1:0] mult;

    assign mult = a * b;

    assign out = mult >>> (WIDTH-2);

endmodule
