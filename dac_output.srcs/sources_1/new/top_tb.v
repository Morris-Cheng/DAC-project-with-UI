`timescale 1ns / 1ps

module top_tb();
    reg clk = 0;
    reg reset = 0;
    reg dac_enable = 0;
    wire cs;
    wire sclk;
    wire d_out;
    wire busy;
    wire LD;
    
    reg switch250 = 0;
    reg switch200 = 0;
    reg switch100 = 0;

    reg [15:0] received_voltage = 0;
    
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
        .d_out(d_out),
        .busy_out(busy)
    );
    
    assign LD = cs;
    
    always #5 clk = ~clk;
    
    initial begin
//        reset = 1;
//        #10;
//        reset = 0;
//        #10;
        dac_enable = 1;
        #2000;
        dac_enable = 0;
    end
endmodule
