`timescale 1ns/1ps

module tb_ramp_input;

    reg signed [17:0] a,b,c,d,I;
    reg clk;
    reg rst_n;

    wire signed [17:0] v,u;
    wire spike;


    izhikevich_neuron dut(
        .clk(clk),
        .rst_n(rst_n),
        .I(I),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .v(v),
        .u(u),
        .spike(spike)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer i;

    initial begin

        // Regular Spiking parameters
        a = 18'sh051E;   //0.02
        b = 18'sh3333;   //0.2
        c = 18'sh3599A;  //-0.65
        d = 18'sh147B;   //0.08

        I = 18'sh0000;

        rst_n = 0;
        #20;
        rst_n = 1;

        // ramp input current
        for(i=0;i<500;i=i+1) begin
            #10;
            I = I + 18'sh0040;
        end

        I = 18'sh0000;
        #10000;

        $finish;
    end

endmodule
