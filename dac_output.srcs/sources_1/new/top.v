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
        output wire [7:0] seg,
        output wire [3:0] an,
        output wire LD
    );
    
    reg [15:0] received_voltage =  0;
    
    always @(posedge clk) begin
        if(switch250 == 1) begin
            received_voltage <= 250;
        end
        else if (switch200 == 1) begin
            received_voltage <= 200;
        end
        else if (switch100 == 1) begin
            received_voltage <= 100;
        end
        else begin
            received_voltage <= 0;
        end
    end
    
    wire busy;
    
    dac #(
        .N_tot(24),
        .N_valid(16),
        .Vref(250),
        .tCH(15),
        .tCL(15),
        .tCSS0(8),
        .tCSF(100),
        .tSCPW(20)
    ) dac(
        .clk(clk),
        .reset(reset),
        .voltage_output(received_voltage),
        .dac_enable(dac_enable),
        .cs_out(cs),
        .sclk_out(sclk),
        .d_out(d_in),
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
    
    assign LD = cs;
endmodule
