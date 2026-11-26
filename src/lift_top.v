`timescale 1ns / 1ps

module lift_top #(
    parameter DEB_TICKS  = 1_250_000,
    parameter MOVE_TICKS = 187_500_000,
    parameter DOOR_TICKS = 250_000_000
)(
    input  wire       clk,
    input  wire [1:0] sw,
    input  wire [3:0] btn,
    output wire [3:0] led,
    output wire       led4_r,
    output wire       led4_g,
    output wire       led4_b,
    output wire       led5_r,
    output wire       led5_b
);
    // 2-FF Synchronizers for SW0 (Reset) and SW1 (Door Hold)
    reg [1:0] rst_sync  = 2'b00;
    reg [1:0] hold_sync = 2'b00;
    always @(posedge clk) begin
        rst_sync  <= {rst_sync[0],  sw[0]};
        hold_sync <= {hold_sync[0], sw[1]};
    end

    // Debounce all 4 floor request push buttons
    wire [3:0] btn_press;
    debounce #(.N(DEB_TICKS)) db0 (.clk(clk), .btn(btn[0]), .press(btn_press[0]));
    debounce #(.N(DEB_TICKS)) db1 (.clk(clk), .btn(btn[1]), .press(btn_press[1]));
    debounce #(.N(DEB_TICKS)) db2 (.clk(clk), .btn(btn[2]), .press(btn_press[2]));
    debounce #(.N(DEB_TICKS)) db3 (.clk(clk), .btn(btn[3]), .press(btn_press[3]));

    // Master Lift Controller FSM
    lift_fsm #(
        .MOVE_TICKS(MOVE_TICKS),
        .DOOR_TICKS(DOOR_TICKS)
    ) controller (
        .clk(clk),
        .rst(rst_sync[1]),
        .door_hold(hold_sync[1]),
        .btn_press(btn_press),
        .led(led),
        .led4_r(led4_r),
        .led4_g(led4_g),
        .led4_b(led4_b),
        .led5_r(led5_r),
        .led5_b(led5_b)
    );
endmodule