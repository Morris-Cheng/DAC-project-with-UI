`timescale 1ns / 1ps

module top(
        input  wire       clk,
        input  wire       reset,
        input  wire       dac_enable,
        input  wire       switch250,
        input  wire       switch200,
        input  wire       switch100,
        output wire       cs,
        output wire       sclk,
        output wire       d_in,
        output wire       ldac,
        output wire [7:0] seg,
        output wire [3:0] an
    );
    
    wire busy;
    wire clk_200Mhz;
    wire locked;
    clk_wiz_0 clock_wizard
    (
        // Clock out ports
        .clk_out1(clk_200Mhz),     // output clk_out1
        // Status and control signals
        .reset(reset), // input reset
        .locked(locked),       // output locked
       // Clock in ports
        .clk_in1(clk)      // input clk_in1
    );
    
    reg [15:0] received_voltage =  0;
    always @(posedge clk) begin
        if(switch250 == 1) begin
            received_voltage <= 250;
        end
        else if (switch200 == 1) begin
            received_voltage <= 125;
        end
        else if (switch100 == 1) begin
            received_voltage <= 100;
        end
        else begin
            received_voltage <= 0;
        end
    end
    
    reg [15:0] dac_out = 0;
    reg [15:0] dac_output = 0;
    reg [23:0] intermediate = 0;
    always @(posedge clk) begin
        // Step 1: Multiply input by the 16-bit max value (65535)
        intermediate <= received_voltage * 16'hFFFF;
        
        // Step 2: Divide by your maximum input scale (250)
        dac_out <= (intermediate * 262) >> 16;
        dac_output <= dac_out;
    end
    
    dac #(
        .N(16),
        .CLK_PERIOD(5),
        .SCLK_PERIOD(20),
        .t10(20),
        .t11(10),
        .t12(15)
    ) dac(
        .clk(clk),
        .reset(reset),
        .locked(locked),
        .voltage_output(dac_output),
        .dac_enable(dac_enable),
        .cs_out(cs),
        .sclk_out(sclk),
        .ldac_out(ldac),
        .data_out(d_in),
        .busy_out(busy)
    );
    
    wire [15:0] value = received_voltage * 10;
    
    display #(
        .N(16)
    ) display_inst(
        .clk(clk),
        .value(value),
        .seg(seg),
        .an(an)
    );
endmodule
