`timescale 1ns/1ps

module Food_Generator_tb;

//params
  localparam integer GRID_W    = 100;
  localparam integer GRID_H    = 75;
  localparam integer MAX_LEN   = 64;
  localparam integer POS_BITS  = 13;
  localparam integer SBF_WIDTH = MAX_LEN * POS_BITS;


  reg                        clk;
  reg                        rstn;
  reg                        food_eaten;
  reg  [SBF_WIDTH-1:0]       snake_body_flat;
  reg  [6:0]                 snake_length;  
  wire [POS_BITS-1:0]        food_pos;

  // for storing old food position
  reg  [POS_BITS-1:0]        old_food;

//dut
  Food_Generator #(
    .GRID_W   (GRID_W),
    .GRID_H   (GRID_H),
    .MAX_LEN  (MAX_LEN),
    .POS_BITS (POS_BITS)
  ) dut (
    .clk              (clk),
    .rstn             (rstn),
    .food_eaten       (food_eaten),
    .snake_body_flat  (snake_body_flat),
    .snake_length     (snake_length),
    .food_pos         (food_pos)
  );

//clk
  initial clk = 0;
  always #5 clk = ~clk;


  initial begin

//reset
    rstn            = 0;
    food_eaten      = 0;
    snake_body_flat = {SBF_WIDTH{1'b0}};
    snake_length    = 0;
    #20;
    rstn = 1;
    #20;

    if (food_pos !== 0) begin
      $display("FAIL: food_pos = %0d after reset (expected 0)", food_pos);
      $finish;
    end
    $display("PASS: food_pos == 0 after reset");

    // assume the game always starts with a 3-segment snake at cells {0,1,2}
    snake_length    = 3;
    snake_body_flat = {SBF_WIDTH{1'b0}};
    snake_body_flat[0*POS_BITS +: POS_BITS] = 0;
    snake_body_flat[1*POS_BITS +: POS_BITS] = 1;
    snake_body_flat[2*POS_BITS +: POS_BITS] = 2;

    #10 food_eaten = 1;
    #10 food_eaten = 0;
    wait (food_pos != 0);
    if (food_pos >= GRID_W * GRID_H) begin
      $display("FAIL: first food_pos %0d out of valid range", food_pos);
      $finish;
    end
    if (food_pos == 0 || food_pos == 1 || food_pos == 2) begin
      $display("FAIL: first food landed on initial snake segment %0d", food_pos);
      $finish;
    end
    $display("PASS: first food_pos = %0d (valid & avoids initial snake)", food_pos);

//another check with more cells
    old_food        = food_pos;
    snake_length    = 6;
    snake_body_flat = {SBF_WIDTH{1'b0}};
    snake_body_flat[0*POS_BITS +: POS_BITS] = old_food;
    snake_body_flat[1*POS_BITS +: POS_BITS] = 10;
    snake_body_flat[2*POS_BITS +: POS_BITS] = 20;
    snake_body_flat[3*POS_BITS +: POS_BITS] = 30;
    snake_body_flat[4*POS_BITS +: POS_BITS] = 40;
    snake_body_flat[5*POS_BITS +: POS_BITS] = 50;

    #10 food_eaten = 1;
    #10 food_eaten = 0;
    wait (food_pos != old_food &&
          food_pos != 10       &&
          food_pos != 20       &&
          food_pos != 30       &&
          food_pos != 40       &&
          food_pos != 50);
    if (food_pos == old_food ||
        food_pos == 10       ||
        food_pos == 20       ||
        food_pos == 30       ||
        food_pos == 40       ||
        food_pos == 50) begin
      $display("FAIL: multi seg avoidance failed (got %0d)", food_pos);
      $finish;
    end
    $display("PASS: multi seg new food_pos = %0d (avoids old & {10,20,30,40,50})", food_pos);

    $display("passed all tests");
    $finish;
  end

endmodule
