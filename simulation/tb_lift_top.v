`timescale 1ns / 1ps

module tb_lift_top;
    reg        clk = 0;
    reg  [1:0] sw  = 2'b01; // Start in Reset (SW0=1)
    reg  [3:0] btn = 4'b0000;

    wire [3:0] led;
    wire       led4_r, led4_g, led4_b, led5_r, led5_b;

    always #4 clk = ~clk; // 125 MHz

    // Fast tick parameters for simulation
    lift_top #(
        .DEB_TICKS(4),
        .MOVE_TICKS(12),
        .DOOR_TICKS(16)
    ) dut (
        .clk(clk),
        .sw(sw),
        .btn(btn),
        .led(led),
        .led4_r(led4_r),
        .led4_g(led4_g),
        .led4_b(led4_b),
        .led5_r(led5_r),
        .led5_b(led5_b)
    );

    initial begin
        // Hold reset (sw[0] = 1)
        sw  = 2'b01;
        btn = 4'b0000;
        #40;
        @(negedge clk);
        sw[0] = 1'b0; // Release reset -> Lift idle at Floor 0 (led = 0001)

        // Call lift to Floor 2 (btn[2])
        repeat (5) @(negedge clk);
        btn[2] = 1'b1;
        repeat (10) @(negedge clk);
        btn[2] = 1'b0;

        // Wait for lift to travel Floor 0 -> 1 -> 2 and open/close doors
        repeat (120) @(negedge clk);

        // Call lift to Floor 3 (btn[3]) and Floor 1 (btn[1])
        btn[3] = 1'b1;
        repeat (10) @(negedge clk);
        btn[3] = 1'b0;
        repeat (10) @(negedge clk);
        btn[1] = 1'b1;
        repeat (10) @(negedge clk);
        btn[1] = 1'b0;

        // Wait for lift to serve Floor 3, then reverse down to Floor 1
        repeat (200) @(negedge clk);

        // Test Door Hold switch (sw[1] = 1)
        sw[1] = 1'b1;
        repeat (30) @(negedge clk);
        sw[1] = 1'b0;
        repeat (50) @(negedge clk);

        $display("*** Lift Controller Simulation Complete ***");
        $finish;
    end

endmodule