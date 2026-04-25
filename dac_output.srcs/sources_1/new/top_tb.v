`timescale 1ns / 1ps

module top_tb();
    reg clk = 0;
    reg reset = 0;
    reg dac_enable = 0;
    wire cs;
    wire sclk;
    wire ldac;
    wire data_out;
    wire busy;
    reg [15:0] received_voltage = 16'hFFFF;

    dac #(
        .N(16),
        .CLK_PERIOD(5),
        .SCLK_PERIOD(20),
        .t8(10),
        .t10(20),
        .t11(10),
        .t12(15)
    ) dac(
        .clk(clk),
        .reset(reset),
        .locked(1),
        .voltage_output(received_voltage),
        .dac_enable(dac_enable),
        .cs_out(cs),
        .sclk_out(sclk),
        .ldac_out(ldac),
        .data_out(data_out),
        .busy_out(busy)
    );
    
    always #2.5 clk = ~clk;
    
    initial begin
        reset = 1;
        #10;
        reset = 0;
        #10;
        dac_enable = 1;
        #2000;
        dac_enable = 0;
    end
endmodule
