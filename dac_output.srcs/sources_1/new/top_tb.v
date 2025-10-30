`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/27 23:54:08
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb();
    reg clk = 0;
    reg reset = 0;
    reg [15:0] voltage_output = 100;
    reg dac_enable = 0;
    wire cs;
    wire sclk;
    wire d_out;
    wire busy;

    dac #(
        .N_tot(24),
        .N_valid(16),
        .Vref(250),
        .tCH(8),
        .tCL(8),
        .tCSS0(8),
        .tCSF(100),
        .tSCPW(20)
    ) dac(
        .clk(clk),
        .reset(reset),
        .voltage_output(voltage_output),
        .dac_enable(dac_enable),
        .cs_out(cs),
        .sclk_out(sclk),
        .d_out(d_out),
        .busy_out(busy)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        reset = 1;
        #10;
        reset = 0;
        #10;
        dac_enable = 1;
    end
endmodule
