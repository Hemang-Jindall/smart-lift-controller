`timescale 1ns / 1ps

module lift_fsm #(
    parameter MOVE_TICKS = 187_500_000, // 1.50 s travel time between floors (at 125 MHz)
    parameter DOOR_TICKS = 250_000_000  // 2.00 s door open duration (at 125 MHz)
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       door_hold,
    input  wire [3:0] btn_press,
    output reg  [3:0] led,
    output reg        led4_r,
    output reg        led4_g,
    output reg        led4_b,
    output reg        led5_r,
    output reg        led5_b
);

    // FSM State Encoding
    localparam S_IDLE      = 3'd0,
               S_MOVE_UP   = 3'd1,
               S_MOVE_DN   = 3'd2,
               S_DOOR_OPEN = 3'd3,
               S_DOOR_HOLD = 3'd4;

    reg [2:0]  state       = S_IDLE;
    reg [1:0]  curr_floor  = 2'd0;
    reg        dir_up      = 1'b1;
    reg [3:0]  req_pending = 4'b0000;
    reg [28:0] timer       = 29'd0;

    reg req_above;
    reg req_below;

    // 1. Latch incoming floor button presses & clear current floor when doors open
    always @(posedge clk) begin
        if (rst) begin
            req_pending <= 4'b0000;
        end else begin
            if (state == S_DOOR_OPEN || state == S_DOOR_HOLD)
                req_pending <= (req_pending | btn_press) & ~(4'b0001 << curr_floor);
            else
                req_pending <= req_pending | btn_press;
        end
    end

    // 2. Combinational check for pending requests above or below current floor
    always @(*) begin
        case (curr_floor)
            2'd0: begin
                req_above = |req_pending[3:1];
                req_below = 1'b0;
            end
            2'd1: begin
                req_above = |req_pending[3:2];
                req_below = req_pending[0];
            end
            2'd2: begin
                req_above = req_pending[3];
                req_below = |req_pending[1:0];
            end
            2'd3: begin
                req_above = 1'b0;
                req_below = |req_pending[2:0];
            end
            default: begin
                req_above = 1'b0;
                req_below = 1'b0;
            end
        endcase
    end

    // 3. Sequential Lift Controller FSM (Directional SCAN Scheduling)
    always @(posedge clk) begin
        if (rst) begin
            state      <= S_IDLE;
            curr_floor <= 2'd0;
            dir_up     <= 1'b1;
            timer      <= 29'd0;
        end else begin
            case (state)
                S_IDLE: begin
                    timer <= 29'd0;
                    if (door_hold) begin
                        state <= S_DOOR_HOLD;
                    end else if (req_pending[curr_floor]) begin
                        state <= S_DOOR_OPEN;
                    end else if (dir_up) begin
                        if (req_above) begin
                            state <= S_MOVE_UP;
                        end else if (req_below) begin
                            dir_up <= 1'b0;
                            state  <= S_MOVE_DN;
                        end
                    end else begin
                        if (req_below) begin
                            state <= S_MOVE_DN;
                        end else if (req_above) begin
                            dir_up <= 1'b1;
                            state  <= S_MOVE_UP;
                        end
                    end
                end

                S_MOVE_UP: begin
                    if (timer >= MOVE_TICKS - 1) begin
                        timer      <= 29'd0;
                        curr_floor <= curr_floor + 2'd1;
                        if (req_pending[curr_floor + 2'd1]) begin
                            state <= S_DOOR_OPEN;
                        end else if ((curr_floor + 2'd1) == 2'd3) begin
                            dir_up <= 1'b0;
                            state  <= S_IDLE;
                        end
                    end else begin
                        timer <= timer + 29'd1;
                    end
                end

                S_MOVE_DN: begin
                    if (timer >= MOVE_TICKS - 1) begin
                        timer      <= 29'd0;
                        curr_floor <= curr_floor - 2'd1;
                        if (req_pending[curr_floor - 2'd1]) begin
                            state <= S_DOOR_OPEN;
                        end else if ((curr_floor - 2'd1) == 2'd0) begin
                            dir_up <= 1'b1;
                            state  <= S_IDLE;
                        end
                    end else begin
                        timer <= timer + 29'd1;
                    end
                end

                S_DOOR_OPEN: begin
                    if (door_hold) begin
                        timer <= 29'd0;
                        state <= S_DOOR_HOLD;
                    end else if (timer >= DOOR_TICKS - 1) begin
                        timer <= 29'd0;
                        state <= S_IDLE;
                    end else begin
                        timer <= timer + 29'd1;
                    end
                end

                S_DOOR_HOLD: begin
                    timer <= 29'd0;
                    if (!door_hold) begin
                        state <= S_DOOR_OPEN;
                    end
                end

                default: begin
                    state <= S_IDLE;
                    timer <= 29'd0;
                end
            endcase
        end
    end

    // 4. Output LED Logic
    always @(*) begin
        // Green LEDs (LD0..LD3): One-hot floor position
        led = 4'b0001 << curr_floor;

        // LD5 RGB: Travel direction (Blue = Up, Red = Down)
        led5_b = dir_up;
        led5_r = ~dir_up;

        // LD4 RGB: Cabin & Door status
        case (state)
            S_IDLE: begin
                led4_r = 1'b1; led4_g = 1'b1; led4_b = 1'b1; // White
            end
            S_MOVE_UP, S_MOVE_DN: begin
                led4_r = 1'b0; led4_g = 1'b0; led4_b = 1'b1; // Blue
            end
            S_DOOR_OPEN: begin
                led4_r = 1'b0; led4_g = 1'b1; led4_b = 1'b0; // Green
            end
            S_DOOR_HOLD: begin
                led4_r = 1'b1; led4_g = 1'b1; led4_b = 1'b0; // Yellow
            end
            default: begin
                led4_r = 1'b0; led4_g = 1'b0; led4_b = 1'b0;
            end
        endcase
    end

endmodule