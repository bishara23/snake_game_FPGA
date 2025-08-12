`timescale 1ns/1ps

module Snake_Logic_tb;
  //smaller grid for checking
  localparam GRID_W   = 5;
  localparam GRID_H   = 4;
  localparam MAX_LEN  = 6;
  localparam INIT_LEN = 3;
  localparam POS_BITS = $clog2(GRID_W*GRID_H);

  //signals
  reg                clk, rstn;
  reg                update_snake, food_eaten;
  reg  [1:0]         direction_in;
  wire [POS_BITS-1:0]     snake_head;
  wire [$clog2(MAX_LEN):0] snake_length;
  wire [POS_BITS*MAX_LEN-1:0] snake_body_flat;

  //dut
  Snake_Logic #(
    .GRID_W   (GRID_W),
    .GRID_H   (GRID_H),
    .MAX_LEN  (MAX_LEN),
    .INIT_LEN (INIT_LEN),
    .POS_BITS (POS_BITS)
  ) dut (
    .clk            (clk),
    .rstn           (rstn),
    .update_snake   (update_snake),
    .food_eaten     (food_eaten),
    .direction_in   (direction_in),
    .snake_head     (snake_head),
    .snake_length   (snake_length),
    .snake_body_flat(snake_body_flat)
  );

 
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    // reset sequence
    rstn         = 0;
    update_snake = 0;
    food_eaten   = 0;
    direction_in = 2'b01;  // Right
    #20 rstn = 1;
    @(posedge clk);

    // 0) initial state
    $display("INIT : head=%0d, len=%0d, body=[%0d,%0d,%0d]",
      dut.snake_head, dut.snake_length,
      dut.snake_body[0], dut.snake_body[1], dut.snake_body[2]
    );

    // 1) move right
    update_snake = 1;
    @(posedge clk);
    update_snake = 0;
    @(posedge clk);  // wait stage-2
    $display("MOVE1: head=%0d, len=%0d, body=[%0d,%0d,%0d,%0d]",
      dut.snake_head, dut.snake_length,
      dut.snake_body[0], dut.snake_body[1],
      dut.snake_body[2], dut.snake_body[3]
    );

    // 2) eat & grow
    food_eaten   = 1;
    update_snake = 1;
    @(posedge clk);
    update_snake = 0;
    food_eaten   = 0;
    @(posedge clk);  // wait stage-2
    $display("GROW1: head=%0d, len=%0d, body=[%0d,%0d,%0d,%0d]",
      dut.snake_head, dut.snake_length,
      dut.snake_body[0], dut.snake_body[1],
      dut.snake_body[2], dut.snake_body[3]
    );

    // 3) change direction ? Down + move
    direction_in = 2'b10;
    update_snake = 1;
    @(posedge clk);
    update_snake = 0;
    @(posedge clk);  // wait stage-2
    $display("MOVE2: head=%0d, len=%0d, body=[%0d,%0d,%0d,%0d]",
      dut.snake_head, dut.snake_length,
      dut.snake_body[0], dut.snake_body[1],
      dut.snake_body[2], dut.snake_body[3]
    );

    #20 $finish;
  end
endmodule
