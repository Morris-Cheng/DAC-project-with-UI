`timescale 1ns / 1ps

module top(
        input  wire       clk,
        input  wire       reset,
        input  wire       dac_enable,
        input  wire       uart_rx,
        output wire       cs,
        output wire       sclk,
        output wire       d_in,
        output wire [7:0] seg,
        output wire [3:0] an,
        output wire [15:0] LD
    );
    
    wire [15:0] rx_value; //input rx value from the computer
    wire        rx_ready; //ready signal from the rx module
        
    uart_rx uart_rx_inst (
        .clk(clk),
        .i_rx(uart_rx),
        .o_data(rx_value),
        .o_ready(rx_ready)
    );
    
    reg [15:0] received_voltage;
        
    //updating the voltage value
    always @(posedge clk) begin
        if(rx_ready) begin
            received_voltage <= rx_value;
        end
    end
    
    wire [15:0] voltage_output = 250; //storing the voltage from computer to voltage output for dac
    wire busy;
    wire [23:0] output_voltage;
    
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
        .busy_out(busy),
        
        .test(output_voltage)
    );
    
    assign LD = output_voltage[21:6];
    
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
