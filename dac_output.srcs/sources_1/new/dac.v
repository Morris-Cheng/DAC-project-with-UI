`timescale 1ns / 1ps

module dac#(
        parameter N = 1, //total number of bits that needs to be send
        parameter CLK_PERIOD = 0,
        parameter SCLK_PERIOD = 0,
        
        //please refer to data sheet for values
        parameter t8 = 0,
        parameter t10  = 0,
        parameter t11 = 0,
        parameter t12 = 0
    )(
        input  wire             clk,
        input  wire             reset,
        input  wire             locked,
        input  wire [N - 1 : 0] voltage_output,
        input  wire             dac_enable,
        output wire             cs_out,
        output wire             sclk_out,
        output wire             ldac_out,
        output reg              data_out,
        output wire             busy_out
    );
    
    reg busy = 0;
    reg cs_reg = 0; //active low to activate
    reg sclk_reg = 1; //active high
    reg ldac_reg = 1; //active high
    
    wire cs_pulse_enable;
    wire cs_pulse_done;
    delay_timer #(
        .CLOCK_CYCLE_TIME(CLK_PERIOD),
        .DELAY_TIME(t12 - 2*CLK_PERIOD),
        .ROUND_MODE(1)
    ) CS_pulse_generate (
        .clk(clk),
        .enable(cs_pulse_enable),
        .done(cs_pulse_done)
    );
    
    wire data_hold_enable;
    wire data_hold_done;
    delay_timer #(
        .CLOCK_CYCLE_TIME(CLK_PERIOD),
        .DELAY_TIME(t8),
        .ROUND_MODE(1)
    ) data_hold (
        .clk(clk),
        .enable(data_hold_enable),
        .done(data_hold_done)
    );
    
    wire ldac_wait_enable;
    wire ldac_wait_done;
    delay_timer #(
        .CLOCK_CYCLE_TIME(CLK_PERIOD),
        .DELAY_TIME(t11 - 2*CLK_PERIOD),
        .ROUND_MODE(1)
    ) LDAC_WAIT_DELAY (
        .clk(clk),
        .enable(ldac_wait_enable),
        .done(ldac_wait_done)
    );
    
    wire ldac_pulse_enable = ldac_wait_done;
    wire ldac_pulse_done;
    delay_timer #(
        .CLOCK_CYCLE_TIME(CLK_PERIOD),
        .DELAY_TIME(t10 - CLK_PERIOD),
        .ROUND_MODE(1)
    ) LDAC_PULSE_generate (
        .clk(clk),
        .enable(ldac_pulse_enable),
        .done(ldac_pulse_done)
    );
    
    localparam IDLE = 0;
    localparam CS_START = 1;
    localparam DATA_HOLD = 2;
    localparam CONV = 3;
    localparam CONV_END = 4;
    localparam LDAC_WAIT = 5;
    localparam LDAC_PULSE = 6;
    
    
    (* fsm_safe_state = "reset_state" *) reg [2:0] state = IDLE;
    reg [2:0] next_state = 0;
    reg [$clog2(N + 1) : 0] current_bit = N;
    
    always @(*) begin : next_state_logic
        next_state = state;
        
        case(state)
            IDLE: begin
                if(dac_enable & locked) begin
                    next_state = CS_START;
                end
            end
            
            CS_START: begin
                if(cs_pulse_done) begin
                    next_state = CONV;
                end
            end
            
            DATA_HOLD: begin
                if(data_hold_done) begin
                    next_state = CONV;
                end
            end
            
            CONV: begin 
                if(current_bit == 0) begin
                    next_state = CONV_END;
                end
            end
            
            CONV_END: begin
                if(cs_reg == 1) begin
                    next_state = LDAC_WAIT;
                end
            end
            
            LDAC_WAIT: begin
                if(ldac_wait_done) begin
                    next_state = LDAC_PULSE;
                end
            end
            
            LDAC_PULSE: begin
                if(ldac_pulse_done) begin
                    next_state = IDLE;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    
    reg [2:0] sclk_counter = 0;
    reg full_period = 0;
    localparam SCLK_CYCLES = SCLK_PERIOD / (2*CLK_PERIOD) - 1;
    
    always @(posedge clk) begin
        if(reset) begin
            cs_reg <= 0;
            busy <= 0;
            sclk_reg <= 1;
            ldac_reg <= 1;
            data_out <= 0;
            state <= IDLE;
        end
        else begin
            if(state == CS_START) begin : generate_CS_pulse
                busy <= 1;
                cs_reg <= 1;
            end
            
            if(state == DATA_HOLD) begin
                cs_reg <= 0;
                data_out <= voltage_output[N - 1];
            end
            
            if(state == CONV) begin
                cs_reg <= 0;
                sclk_counter <= sclk_counter + 1;
                if(sclk_counter >= SCLK_CYCLES) begin
                    sclk_reg <= ~sclk_reg;
                    sclk_counter <= 0;
                    full_period <= ~full_period;
                    if(full_period) begin
                        current_bit <= current_bit - 1;
                    end
                    if(current_bit != 0) begin
                        data_out <= voltage_output[current_bit - 1];
                    end
                    else begin
                        data_out <= 0;
                    end
                end
            end
            
            else if(state == CONV_END) begin
                sclk_reg <= 1;
                sclk_counter <= 0;
                full_period <= 0;
                cs_reg <= 1;
            end
            
            else if(state == LDAC_PULSE) begin
                ldac_reg <= 0;
            end
            
            else if(state == IDLE) begin
                cs_reg <= 0;
                busy <= 0;
                sclk_reg <= 1;
                ldac_reg <= 1;
                data_out <= 0;
                current_bit <= N;
            end
            
            state <= next_state; //only updates state when not in reset
        end
    end
    
    assign ldac_wait_enable = state == LDAC_WAIT;
    assign cs_pulse_enable = state == CS_START;
    assign data_hold_enable = state == DATA_HOLD;
    assign busy_out = busy;
    assign cs_out = cs_reg;
    assign ldac_out = ldac_reg;
    assign sclk_out = sclk_reg;
endmodule
