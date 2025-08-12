`timescale 1ns/1ps

module Game_FSM_tb;
    // testbench signals
    reg         clk;
    reg         rstn;
    reg  [1:0]  direction_in;
    reg         food_eaten;
    reg         collision;

    wire        frame_tick;
    wire        update_snake;
    wire        score_inc;
    wire        reset_game;
    wire [1:0]  direction_out;

    // instantiate the FSM with a fast simulation tick count
    Game_FSM #(
        .TICKS_PER_FRAME(25'd50)   // 500 ns per frame_tick at 100 MHz
    ) uut (
        .clk            (clk),
        .rstn           (rstn),
        .direction_in   (direction_in),
        .food_eaten     (food_eaten),
        .collision      (collision),
        .frame_tick     (frame_tick),
        .update_snake   (update_snake),
        .score_inc      (score_inc),
        .reset_game     (reset_game),
        .direction_out  (direction_out)
    );

    // clk generation: 10 ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // initialize inputs
        rstn = 0;
        direction_in = 2'b00;
        food_eaten = 0;
        collision = 0;

        // release reset and check transition to RUN
        #20 rstn = 1;
        $display("Released reset, state should go RUN (1)");

        // Wait a couple of frame_ticks
        repeat (2) @(posedge frame_tick);
        $display("frame_tick pulse observed");

        // now food eaten
        direction_in = 2'b01;
        food_eaten = 1;
        @(posedge frame_tick);
        #1;
        $display("food_eaten -> score_inc = %b (expected 1)", score_inc);
        food_eaten = 0;

        // collision
        collision = 1;
        @(posedge frame_tick);
        #1;
        $display("collision -> reset_game = %b (expected 1)", reset_game);
        collision = 0;

        // reset
        #10 rstn = 0;
        #10 rstn = 1;
        #1;
        $display("reset asserted again, state should be IDLE then RUN, reset_game = %b (expected 0)", reset_game);

        #50 $finish;
    end
endmodule
