`timescale 1ns/1ps

module Direction_Decoder_tb;
    // Testbench signals
    reg         clk;
    reg         rstn;
    reg  [7:0]  scancode;
    reg         scancode_valid;
    wire [1:0]  direction;

    // Instantiate the DUT (Device Under Test)
    Direction_Decoder uut (
        .clk            (clk),
        .rstn           (rstn),
        .scancode       (scancode),
        .scancode_valid (scancode_valid),
        .direction      (direction)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize inputs
        rstn = 0;
        scancode = 8'h00;
        scancode_valid = 0;
        #20;
        rstn = 1;  // Release reset after 20ns

        // 1) Press '8' ? Up
        #10 scancode = 8'h75; scancode_valid = 1;
        #10 scancode_valid = 0;
        #20 $display("direction = %b (expected 00 = UP)", direction);

        // 2) Immediately press '5' ? Down (180 reversal) should be blocked
        #10 scancode = 8'h73; scancode_valid = 1;
        #10 scancode_valid = 0;
        #20 $display("direction = %b (expected 00 = still UP)", direction);

        // 3) Press '6' ? Right
        #10 scancode = 8'h74; scancode_valid = 1;
        #10 scancode_valid = 0;
        #20 $display("direction = %b (expected 01 = RIGHT)", direction);

        // 4) Press '4' ? Left (180 reversal from RIGHT) blocked
        #10 scancode = 8'h6B; scancode_valid = 1;
        #10 scancode_valid = 0;
        #20 $display("direction = %b (expected 01 = still RIGHT)", direction);

        // 5) Press '5' ? Down allowed
        #10 scancode = 8'h73; scancode_valid = 1;
        #10 scancode_valid = 0;
        #20 $display("direction = %b (expected 10 = DOWN)", direction);
        
        // 6) Press '4' ? Left (now allowed)
        #10 scancode = 8'h6B; scancode_valid = 1;
        #10 scancode_valid = 0;
        #20 $display("direction = %b (expected 11 = LEFT)", direction);

        #50 $finish;
    end
endmodule
