`timescale 1ns / 1ps

module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115_200
)(
    input             clk,      //clock signal
    input             i_rx,     //rx signal input
    output reg [15:0] o_data,   //received data
    output reg        o_ready   //data avaliable signal
);
    
    localparam integer BAUD_TICK = CLK_FREQ / BAUD;

    reg [15:0] baud_cnt = 0;
    reg [3:0]  bit_idx  = 0;
    reg [7:0]  rx_buffer = 0;
    reg [15:0] data_buffer = 0;
    reg        receiving = 0;
    reg [1:0]  rx_sync = 2'b11;
    reg        first_byte_received = 0;

    // Synchronize input
    always @(posedge clk) begin
        rx_sync <= {rx_sync[0], i_rx};
    end

    wire rx_signal = rx_sync[1];
    wire start_bit = (rx_sync == 2'b10);

    always @(posedge clk) begin
        o_ready <= 0;

        if (!receiving) begin
            if (start_bit) begin
                receiving <= 1;
                baud_cnt <= BAUD_TICK + (BAUD_TICK/2);  // 1.5 bit times
                bit_idx <= 0;
                rx_buffer <= 8'h00;
            end
        end else begin
            if (baud_cnt > 0) begin
                baud_cnt <= baud_cnt - 1;
            end else begin
                $display("Else block is triggered");
                if (bit_idx < 8) begin
                    rx_buffer[bit_idx] <= rx_signal;
                    bit_idx <= bit_idx + 1;
                    baud_cnt <= BAUD_TICK;
                    $display("Index value was updated, %d", bit_idx);
                end else begin
                    // Store received byte
                    if (!first_byte_received) begin
                        data_buffer[7:0] <= rx_buffer;
                        first_byte_received <= 1;
                    end else begin
                        data_buffer[15:8] <= rx_buffer;
                        o_data <= {rx_buffer, data_buffer[7:0]}; // assemble immediately
                        o_ready <= 1;
                        first_byte_received <= 0;
                    end
                    receiving <= 0;
                end
            end
        end
    end
endmodule