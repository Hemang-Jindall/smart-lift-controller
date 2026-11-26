`timescale 1ns / 1ps

module debounce #(
    parameter N = 1_250_000  // 10 ms debounce window at 125 MHz
)(
    input  wire clk,
    input  wire btn,
    output wire press
);
    reg sync0 = 1'b0, sync1 = 1'b0;
    reg stable = 1'b0, stable_d = 1'b0;
    reg [$clog2(N+1)-1:0] cnt = 0;

    always @(posedge clk) begin
        sync0 <= btn;
        sync1 <= sync0;

        if (sync1 != stable) begin
            if (cnt == N - 1) begin
                stable <= sync1;
                cnt    <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end else begin
            cnt <= 0;
        end

        stable_d <= stable;
    end

    assign press = stable & ~stable_d;
endmodule