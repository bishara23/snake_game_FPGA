`timescale 1ns/1ps

module Collision_Detector_tb;


  localparam integer MAX_LEN   = 64;
  localparam integer POS_BITS  = 13;
  localparam integer GRID_W    = 100;
  localparam integer GRID_H    = 75;
  localparam integer SBF_WIDTH = MAX_LEN * POS_BITS;

  reg  [POS_BITS-1:0]        snake_head;
  reg  [SBF_WIDTH-1:0]       snake_body_flat;
  reg  [6:0]                 snake_length;
  reg  [POS_BITS-1:0]        food_pos;
  reg  [1:0]                 direction_in;
  wire                       food_eaten;
  wire                       collision;

  Collision_Detector #(
    .MAX_LEN  (MAX_LEN),
    .POS_BITS (POS_BITS),
    .GRID_W   (GRID_W),
    .GRID_H   (GRID_H)
  ) dut (
    .snake_head      (snake_head),
    .snake_body_flat (snake_body_flat),
    .snake_length    (snake_length),
    .food_pos        (food_pos),
    .direction_in    (direction_in),
    .food_eaten      (food_eaten),
    .collision       (collision)
  );

  initial begin
    // Default state
    snake_body_flat = {SBF_WIDTH{1'b0}};
    snake_length    = 1;
    direction_in    = 2'b00;

    // food_eaten when head == food
    snake_head = 123;
    food_pos   = 123;
    #1;
    if (food_eaten)
      $display("PASS: food_eaten asserted when head==food (head=%0d)", snake_head);
    else begin
      $display("FAIL: food_eaten should be 1 when head==food (head=%0d)", snake_head);
      $finish;
    end

    //food_eaten deassert when head != food
    food_pos = 122;
    #1;
    if (!food_eaten)
      $display("PASS: food_eaten deasserted when head!=food (head=%0d, food=%0d)", snake_head, food_pos);
    else begin
      $display("FAIL: food_eaten should be 0 when head!=food (head=%0d, food=%0d)", snake_head, food_pos);
      $finish;
    end

    //no collision in interior
    snake_head   = GRID_W + 5;  // e.g. (x=5,y=1)
    snake_length = 1;
    direction_in = 2'b00;
    #1;
    if (!collision)
      $display("PASS: no collision for interior cell %0d", snake_head);
    else begin
      $display("FAIL: collision incorrectly asserted for interior cell %0d", snake_head);
      $finish;
    end

    //top-wall collision
    snake_head   = 10;      // y=0
    direction_in = 2'b00;   // up
    #1;
    if (collision)
      $display("PASS: top-wall collision detected (head=%0d)", snake_head);
    else begin
      $display("FAIL: missing top-wall collision (head=%0d)", snake_head);
      $finish;
    end

    //bottom-wall collision
    snake_head   = (GRID_H-1)*GRID_W + 7; // y=GRID_H-1
    direction_in = 2'b10;                 // down
    #1;
    if (collision)
      $display("PASS: bottom-wall collision detected (head=%0d)", snake_head);
    else begin
      $display("FAIL: missing bottom-wall collision (head=%0d)", snake_head);
      $finish;
    end

    //left-wall collision
    snake_head   = 50*GRID_W + 0; // x=0
    direction_in = 2'b11;         // left
    #1;
    if (collision)
      $display("PASS: left-wall collision detected (head=%0d)", snake_head);
    else begin
      $display("FAIL: missing left-wall collision (head=%0d)", snake_head);
      $finish;
    end

    //right-wall collision
    snake_head   = 20*GRID_W + (GRID_W-1); // x=GRID_W-1
    direction_in = 2'b01;                  // right
    #1;
    if (collision)
      $display("PASS: right-wall collision detected (head=%0d)", snake_head);
    else begin
      $display("FAIL: missing right-wall collision (head=%0d)", snake_head);
      $finish;
    end

    //realistic no-self-collision:
    //    snake of length 4 at contiguous horizontal positions:
    //      body[1]=1009, body[2]=1008, body[3]=1007, head=1010
    snake_length = 4;
    snake_body_flat = {SBF_WIDTH{1'b0}};
    snake_body_flat[1*POS_BITS +: POS_BITS] = 1009;
    snake_body_flat[2*POS_BITS +: POS_BITS] = 1008;
    snake_body_flat[3*POS_BITS +: POS_BITS] = 1007;
    snake_head    = 1010;
    direction_in  = 2'b01; // moving right
    #1;
    if (!collision)
      $display("PASS: no self-collision for head=1010 vs body={1009,1008,1007}");
    else begin
      $display("FAIL: false self-collision for head=1010 vs body");
      $finish;
    end

    //self-collision:
    //head moves into its own neck at 1009
    snake_head   = 1009;
    direction_in = 2'b11; //moving left
    #1;
    if (collision)
      $display("PASS: self-collision detected when head=1009 vs body[1]=1009");
    else begin
      $display("FAIL: missing self-collision when head=1009 vs body[1]=1009");
      $finish;
    end

    $display("passed all tests");
    $finish;
  end

endmodule
