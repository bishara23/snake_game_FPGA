`timescale 1ns/1ps


module Score_Counter_tb;
    reg        clk;
    reg        rstn;
    reg        score_inc;
    wire [15:0] score;

    // instantiate the Score Counter
    Score_Counter uut (
        .clk       (clk),
        .rstn      (rstn),
        .score_inc (score_inc),
        .score     (score)
    );

    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // reset
        rstn = 0;
        score_inc = 0;
        #20 rstn = 1;

        // 1) increment from 0000 ? 0001 ? 0002 ? 0003
        repeat (3) begin
            #10 score_inc = 1; #10 score_inc = 0;
        end
        #1;
        $display("Step 1: score = %0h (expected 0003)", score);

        // 2) increment to 0009 then to 0010
        repeat (6) begin
            #10 score_inc = 1; #10 score_inc = 0;
        end // now at 0009
        #1 $display("Step 2a: score = %0h (expected 0009)", score);
        #10 score_inc = 1; #10 score_inc = 0; #1;
        $display("Step 2b: score = %0h (expected 0010)", score);

        // 3) move to tens/hundreds: preset to 0098, then two pulses
        uut.score <= 16'h0098;
        #1;
        #10 score_inc = 1; #10 score_inc = 0; #1;
        $display("Step 3a: score = %0h (expected 0099)", score);
        #10 score_inc = 1; #10 score_inc = 0; #1;
        $display("Step 3b: score = %0h (expected 0100)", score);

        // 4) move through 0999 -> 1000
        uut.score <= 16'h0999;
        #1;
        #10 score_inc = 1; #10 score_inc = 0; #1;
        $display("Step 4: score = %0h (expected 1000)", score);

        // 5) limit 9999 -> 0000
        uut.score <= 16'h9999;
        #1;
        #10 score_inc = 1; #10 score_inc = 0; #1;
        $display("Step 5: score = %0h (expected 0000)", score);
        
        // ) reset check
        uut.score <= 16'h0009;
        #1;
        #10 score_inc = 1; #10 score_inc = 0; #1;
        rstn = 0;
        #10;
        $display("Step 6 (reset): score = %0h (expected 0000)", score);

        $finish;
    end
endmodule