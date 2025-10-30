`timescale 1ns / 1ps

module dac#(
        parameter N_tot   = 0, //total number of bits that needs to be send
        parameter N_valid = 0, //total number of valid bits
        
        //please refer to data sheet for values
        parameter Vref  = 0, //units: V
        parameter tCH   = 0, //units: ns
        parameter tCL   = 0, //units: ns
        parameter tCSS0 = 0, //units: ns
        parameter tCSF  = 0, //units: ns
        parameter tSCPW = 0 //units: ns
    )(
        input  wire                   clk,
        input  wire                   reset,
        input  wire [N_valid - 1 : 0] voltage_output,
        input  wire                   dac_enable,
        output wire                   cs_out,
        output wire                   sclk_out,
        output reg                    d_out,
        output wire                   busy_out
    );
    
    reg [N_valid - 1 : 0] voltage_binary = 0;
    reg [N_tot - 1 : 0] output_data = 0;
    always @(*) begin : voltage_to_binary_conversion
        voltage_binary = (voltage_output * ((1 << 16) - 1)) / Vref + 1'b1;          //converting voltage into bits
        output_data = {2'b01, voltage_binary, {(N_tot - (N_valid + 2)){1'b0}}};     //converting the bits into output data stream for dac to read
    end
    
    reg busy = 0;
    reg cs_reg = 1; //active low to activate
    
    reg dac_enable_d = 0;
    wire dac_enable_rising = dac_enable & ~dac_enable_d;
    wire cs_trigger_enable = dac_enable_rising; //raises cs to be high when dac enable rising edge detected
    wire cs_trigger_done;
    delay_timer #(
        .CLOCK_CYCLE_TIME(10),
        .DELAY_TIME(tSCPW),
        .ROUND_MODE(1)
    ) CS_trigger(
        .clk(clk),
        .enable(cs_trigger_enable),
        .done(cs_trigger_done)
    );
    
    
    wire conv_wait_enable = ~cs_reg; //conv_wait_enable triggers on the falling edge of the cs signal
    wire conv_wait_done;
    delay_timer #(
        .CLOCK_CYCLE_TIME(10),
        .DELAY_TIME(tCSS0),
        .ROUND_MODE(1)  //set mode to round up
    ) conversion_wait_timer(
        .clk(clk),
        .enable(conv_wait_enable),
        .done(conv_wait_done)
    );
    
    
    localparam SCLK_PERIOD = tCH + tCL;
    reg sclk_clock_enable = 0;
    reg sclk_reg_d = 0;
    wire sclk_reg;
    wire sclk_reg_rising = sclk_reg && ~sclk_reg_d;
    clock_divider #(
        .CLOCK_CYCLE_TIME(10),
        .NEW_CLOCK_CYCLE_TIME(SCLK_PERIOD),
        .IDLE_STATE(0),
        .ROUND_MODE(1)
    ) sclk_clock(
        .clk(clk),
        .enable(sclk_clock_enable),
        .divided_clk_out(sclk_reg)
    );
    
    reg [$clog2(N_tot + 1) : 0] current_bit = N_tot;
    wire cs_end_enable = (current_bit == 0);
    wire cs_end_done;
    delay_timer #(
        .CLOCK_CYCLE_TIME(10),
        .DELAY_TIME(tCSF),
        .ROUND_MODE(1)
    ) CS_end(
        .clk(clk),
        .enable(cs_end_enable),
        .done(cs_end_done)
    );
    
    
    reg [2:0] state = 0;
    reg [2:0] next_state = 0;
    localparam IDLE = 0;
    localparam CS_START = 1;
    localparam CONV = 2;
    localparam CONV_CONTINUE = 3;
    localparam CONV_END = 4;
    
    always @(*) begin : next_state_logic
        next_state = state;
        case(state)
            IDLE: begin
                if(dac_enable_rising) begin
                    next_state = CS_START;
                end
                else begin
                    next_state = next_state;
                end
            end
            
            CS_START: begin
                if(cs_trigger_done) begin
                    next_state = CONV;
                end
                else begin
                    next_state = next_state;
                end
            end
            
            CONV: begin
                if(conv_wait_done) begin
                    next_state = CONV_CONTINUE;
                    sclk_clock_enable = 1;
                end
                else begin
                    next_state = next_state;
                end
            end
            
            CONV_CONTINUE: begin
                if(current_bit == 0) begin
                    next_state = CONV_END;
                    sclk_clock_enable = 0;
                end
                else begin
                    next_state = next_state;
                end
            end
            
            CONV_END: begin
                if(cs_end_done) begin
                    if(dac_enable) begin
                        next_state = CONV;
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
                else begin
                    next_state = next_state;
                end
            end
        endcase
    end
    
    always @(posedge clk) begin : state_register_update
        state <= next_state;
        dac_enable_d <= dac_enable;
        sclk_reg_d <= sclk_reg;
    end
    
    always @(posedge clk) begin
        if(reset) begin
            cs_reg <= 1;
            busy <= 0;
            d_out <= 0;
            current_bit <= N_tot;
        end
        else begin
            if(state == CS_START) begin : CS_trigger_update
                //pulls cs high for tCSPW to trigger dac
                busy <= 1;
                cs_reg <= 1;
            end
            
            if(state == CONV) begin : CONV_register_update
                cs_reg <= 0;
            end
            
            else if(state == CONV_CONTINUE) begin
                if(sclk_reg_rising) begin
                    if(current_bit > 0) begin
                        current_bit <= current_bit - 1;
                    end
                    else begin
                        current_bit <= current_bit;
                    end
                end
                
                if(current_bit != 0) begin
                    d_out <= output_data[current_bit - 1];
                end
                else begin
                    d_out <= 0;
                end
            end
            
            else if(state == CONV_END) begin
                cs_reg <= 1;
                busy <= 0;
                d_out <= 0;
                current_bit <= N_tot;
            end
        end
    end
    
    assign busy_out = busy;
    assign sclk_out = sclk_reg;
    assign cs_out = cs_reg;
endmodule
