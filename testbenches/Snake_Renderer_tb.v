`timescale 1ns/1ps

module Snake_Renderer_tb;

  //parameters
  localparam integer GRID_W    = 100;
  localparam integer GRID_H    = 75;
  localparam integer MAX_LEN   = 64;
  localparam integer POS_BITS  = 13;
  localparam integer SBF_WIDTH = POS_BITS * MAX_LEN;

  // for text rendering
  localparam integer CHAR_W     = 8;
  localparam integer CHAR_H     = 8;
  localparam integer TEXT_CHARS = 9;
  localparam integer TEXT_W     = CHAR_W * TEXT_CHARS;   // 72
  localparam integer TEXT_H     = CHAR_H;                //  8
  localparam integer X0         = (GRID_W - TEXT_W) / 2; // 14
  localparam integer Y0         = (GRID_H - TEXT_H) / 2; // 33

  //tb signals
  reg                       clk;
  reg                       rstn;
  reg                       frame_tick;
  reg                       game_over;
  reg  [10:0]               XCoord, YCoord;
  reg  [SBF_WIDTH-1:0]      snake_body_flat;
  reg  [$clog2(MAX_LEN+1)-1:0] snake_length;
  reg  [POS_BITS-1:0]       food_pos;
  wire [3:0]                pixel_red, pixel_green, pixel_blue;

  //helpers
  integer head_pos, fx, fy;
  reg [3:0] bg_val; // capture background grayscale

  //dut
  Snake_Renderer #(
    .GRID_W   (GRID_W),
    .GRID_H   (GRID_H),
    .MAX_LEN  (MAX_LEN),
    .POS_BITS (POS_BITS)
  ) dut (
    .clk             (clk),
    .rstn            (rstn),
    .frame_tick      (frame_tick),
    .XCoord          (XCoord),
    .YCoord          (YCoord),
    .snake_body_flat (snake_body_flat),
    .snake_length    (snake_length),
    .food_pos        (food_pos),
    .game_over       (game_over),
    .pixel_red       (pixel_red),
    .pixel_green     (pixel_green),
    .pixel_blue      (pixel_blue)
  );

  //clk
  initial clk = 0;
  always #5 clk = ~clk;

  //test  
  initial begin
    // 1) Reset
    rstn            = 0;
    frame_tick      = 0;
    game_over       = 0;
    XCoord          = 0;
    YCoord          = 0;
    snake_body_flat = {SBF_WIDTH{1'b0}};
    snake_length    = 0;
    food_pos        = 0;
    #20 rstn = 1;
    #10;

    // 2) normal play: snake pixel
    head_pos        = 123;                
    snake_body_flat = {SBF_WIDTH{1'b0}};
    snake_body_flat[0*POS_BITS +: POS_BITS] = head_pos;
    snake_length    = 1;
    fx              = head_pos % GRID_W;
    fy              = head_pos / GRID_W;
    XCoord          = fx;
    YCoord          = fy;
    game_over       = 0;
    #1;
    if ({pixel_red,pixel_green,pixel_blue} === {4'h0,4'hF,4'h0})
      $display("PASS: snake pixel at (%0d,%0d) = green", fx, fy);
    else begin
      $display("FAIL: snake pixel incorrect (got R%h G%h B%h)", pixel_red, pixel_green, pixel_blue);
      $finish;
    end

    // 3) normal play: food pixel
    food_pos        = 250;                
    snake_length    = 0;                  
    fx              = food_pos % GRID_W;
    fy              = food_pos / GRID_W;
    XCoord          = fx;
    YCoord          = fy;
    #1;
    if ({pixel_red,pixel_green,pixel_blue} === {4'hF,4'h0,4'h0})
      $display("PASS: food pixel at (%0d,%0d) = red", fx, fy);
    else begin
      $display("FAIL: food pixel incorrect (got R%h G%h B%h)", pixel_red, pixel_green, pixel_blue);
      $finish;
    end

    // 4)  background pixel
    XCoord = 1; YCoord = 1;
    #1;
    if ({pixel_red,pixel_green,pixel_blue} === {4'h0,4'h0,4'h0})
      $display("PASS: background pixel at (1,1) = black");
    else begin
      $display("FAIL: background pixel incorrect (got R%h G%h B%h)", pixel_red, pixel_green, pixel_blue);
      $finish;
    end

    // 5) gameover grayscale background and inverse text
    game_over = 1;
    // background bit (font=0)
    XCoord     = X0;
    YCoord     = Y0;
    #1;
    if (pixel_red == pixel_green && pixel_green == pixel_blue) begin
      bg_val = pixel_red;
      $display("PASS: game-over background grayscale = %0h", bg_val);
    end else begin
      $display("FAIL: game-over background not grayscale (got R%h G%h B%h)", pixel_red, pixel_green, pixel_blue);
      $finish;
    end

    // text bit (font=1)
    XCoord     = X0 + 3;
    YCoord     = Y0;
    #1;
    if (pixel_red == pixel_green && pixel_green == pixel_blue && pixel_red != bg_val) begin
      $display("PASS: game-over text grayscale inverse = %0h (bg=%0h)", pixel_red, bg_val);
    end else begin
      $display("FAIL: game-over text incorrect (got R%h G%h B%h), bg=%0h", pixel_red, pixel_green, pixel_blue, bg_val);
      $finish;
    end

    $display("passed all tests");
    $finish;
  end

endmodule
