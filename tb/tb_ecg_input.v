`timescale 1ns/1ps

module tb_ecg_input;

    reg clk;
    reg rst_n;

    reg signed [17:0] a,b,c,d;

    reg signed [17:0] I_normal;
    reg signed [17:0] I_inverted;

    wire signed [17:0] v_normal,u_normal;
    wire signed [17:0] v_inverted,u_inverted;

    wire spike_normal;
    wire spike_inverted;

    reg signed [17:0] I_mem_normal [0:5000];
    reg signed [17:0] I_mem_inverted [0:5000];

    integer i;

    // normal neuron
    izhikevich_neuron neuron_normal(
        .clk(clk),
        .rst_n(rst_n),
        .I(I_normal),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .v(v_normal),
        .u(u_normal),
        .spike(spike_normal)
    );

    // inverted neuron
    izhikevich_neuron neuron_inverted(
        .clk(clk),
        .rst_n(rst_n),
        .I(I_inverted),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .v(v_inverted),
        .u(u_inverted),
        .spike(spike_inverted)
    );

    // clock
    initial clk = 0;
    always #15 clk = ~clk;

    initial begin

        rst_n = 0;

        a = 18'sh051E;  //0.02
        b = 18'sh3333;  //0.2
        c = 18'sh3599A; //-0.65
        d = 18'sh147B;  //0.08

        I_normal = 0;
        I_inverted = 0;

        // load ECG signals
        $readmemh("../data/ecg_normal.mem", I_mem_normal);
        $readmemh("../data/ecg_inverted.mem", I_mem_inverted);

        #20;
        rst_n = 1;

        for(i=0;i<5000;i=i+1) begin
            I_normal   = I_mem_normal[i];
            I_inverted = I_mem_inverted[i];
            @(posedge clk);
        end

        $finish;

    end

endmodule
