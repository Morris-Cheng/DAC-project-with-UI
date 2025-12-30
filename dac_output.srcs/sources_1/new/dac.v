`timescale 1ns / 1ps

module dac#(
        parameter N_tot   = 1, //total number of bits that needs to be send
        parameter N_valid = 1, //total number of valid bits
        
        //please refer to data sheet for values
        parameter Vref  = 1, //units: V
        parameter tCH   = 1, //units: ns
        parameter tCL   = 1, //units: ns
        parameter tCSS0 = 1, //units: ns
        parameter tCSF  = 1, //units: ns
        parameter tSCPW = 1 //units: ns
    )(
        input  wire                   clk,
        input  wire                   reset,
        input  wire [N_valid - 1 : 0] voltage_output,
        input  wire                   dac_enable,
        output wire                   cs_out,
        output wire                   sclk_out,
        output reg                    d_out,
        output wire                   busy_out,
        
        output wire [23:0] test //debug
    );
    
    localparam integer FULL_SCALE = (1 << 16);
    localparam integer INV_VREF = (1 << 24) / Vref;
    reg [63:0] mult_stage;        // Stage 1: multiplication
    reg [63:0] scale_stage;       // Stage 2: scaling (division replacement)
    reg [N_tot-1:0] output_data;  // Stage 3: packed DAC frame
    
    always @(posedge clk) begin
        if (reset) begin
            mult_stage <= 0;
        end
        else if (busy_out == 0) begin
            // voltage_output × full-scale constant
            mult_stage <= voltage_output * FULL_SCALE;
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            scale_stage <= 0;
        end
        else begin
            // Multiply by reciprocal instead of dividing
            scale_stage <= (mult_stage * INV_VREF) >> 24;
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            output_data <= 0;
        end
        else begin
            output_data <= {2'b01,
                            scale_stage[N_valid-1:0],
                            {(N_tot - (N_valid + 2)){1'b0}}};
        end
    end
    
    
    assign test = output_data; //debug
    
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
        sclk_clock_enable = sclk_clock_enable;
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
                //pulls busy indicator high to indicate busy state
                busy <= 1;
                //pulls cs pin high for tCSPW ns
                cs_reg <= 1;
            end
            
            if(state == CONV) begin : CONV_register_update
                busy <= 1;
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
