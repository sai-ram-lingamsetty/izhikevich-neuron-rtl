`timescale 1ns/1ps
// -------------------------------------------------------------
// Izhikevich Neuron Model (Fixed-Point RTL)
// dv/dt = 0.04v^2 + 5v + 140 - u + I
// du/dt = a(bv - u)
//
// Spike condition:
// if v >= threshold
//      v = c
//      u = u + d
// -------------------------------------------------------------
module izhikevich_neuron#(
    parameter WIDTH = 18
)(
    input clk,
    input rst_n,
    input signed [WIDTH-1:0] I,
    
    input signed [WIDTH-1:0] a,
    input signed [WIDTH-1:0] b,
    input signed [WIDTH-1:0] c,
    input signed [WIDTH-1:0] d,
    
    output reg signed [WIDTH-1:0] v,
    output reg signed [WIDTH-1:0] u,
    output reg spike
);
    localparam signed [WIDTH-1:0] THRESH = $signed('h04CCD); //0.30
    localparam signed [WIDTH-1:0] CONST  = $signed('h16666); //1.4 

    wire signed [WIDTH-1:0] v2;
    wire signed [WIDTH-1:0] bv;
    wire signed [WIDTH-1:0] tempo1;
    wire signed [WIDTH-1:0] tempo2;

    wire signed [WIDTH-1:0] vnew;
    wire signed [WIDTH-1:0] unew;
    
    signed_mult #(WIDTH) m1 (.out(v2),.a(v),.b(v));
    // vnew = v + ((v^2 + 1.25v(=>5/4 = 1 + 1/4) + 0.35(=>1.4/4) - u/4 + I/4) / 4
    assign vnew = v +((v2 + v + (v >>> 2) + (CONST >>> 2) - (u >>> 2) + (I >>> 2)) >>> 2);
        
    // b*v
    signed_mult #(WIDTH) m2 (.out(bv),.a(b),.b(v));
    assign tempo1 = bv - u;
    // a*(bv-u)
    signed_mult #(WIDTH) m3 (.out(tempo2),.a(a),.b(tempo1));
    // dt = 1/16 
    assign unew = u + (tempo2 >>> 4);
    
    localparam integer refractory_count = 10;      // in clock cycles
    reg [$clog2(refractory_count+1)-1:0] refractory_period;
    
    
    always@(posedge clk) begin
        if(!rst_n) begin
            v <= $signed('h34CCD); // ≈ -0.7 => 2^18 - (0.7 * 2^16) -- 2's complement
            u <= $signed('h3CCCD); // ≈ -0.2 => 2^18 - (0.2 * 2^16) -- 2's complement
            spike <= 1'b0;
             refractory_period <= 'b0;
        end 
        else begin
            if (refractory_period > 0) begin
                v <= c;
                u <= unew;  
                spike <= 1'b0;
                refractory_period <= refractory_period - 1;
            end 
            else if(v >= THRESH) begin
                v <= c;
                u <= u + d;
                spike <= 1'b1;
                refractory_period <= refractory_count;
            end 
            else begin
                v <= vnew;
                u <= unew;
                spike <= 1'b0;
                refractory_period <= 'b0;
            end 
        end
    end
    
endmodule 
