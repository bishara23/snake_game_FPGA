`timescale 1ns/1ps

module SnakeTop (
  input  wire        clk,       // 100 MHz
  input  wire        btnC,      // user reset
  input  wire        PS2Clk,
  input  wire        PS2Data,
  output wire [6:0]  seg,
  output wire [3:0]  an,
  output wire        dp,
  output wire [3:0]  vgaRed,
  output wire [3:0]  vgaGreen,
  output wire [3:0]  vgaBlue,
  output wire        Hsync,
  output wire        Vsync
);

  //constants
  localparam GRID_W   = 100;
  localparam GRID_H   = 75;
  localparam MAX_LEN  = 100;
  localparam POS_BITS = 13;

  //reset
  wire db_btnC;
  Debouncer db_rst (
    .clk(clk),
    .input_unstable(btnC),
    .output_stable(db_btnC)
  );
  wire rstn = ~db_btnC;   // active-low global reset

//wires for ps2
  wire [7:0]  scancode;
  wire        keyPressed;
  Ps2_Interface ps2_intf (
    .PS2Clk     (PS2Clk),
    .clk        (clk),
    .rstn       (rstn),
    .PS2Data    (PS2Data),
    .scancode   (scancode),
    .keyPressed (keyPressed)
  );

  wire [1:0] direction;
  Direction_Decoder dir_dec (
    .clk            (clk),
    .rstn           (rstn),
    .scancode       (scancode),
    .scancode_valid (keyPressed),
    .direction      (direction)
  );

  //game signals
  wire        collision;
  wire        food_eaten;

  wire        frame_tick;
  wire        update_snake;
  wire        score_inc;
  wire        reset_game;
  wire [1:0]  direction_out;

  // Game FSM
  Game_FSM #(
    .TICKS_PER_FRAME(25'd5_000_000)
  ) fsm (
    .clk           (clk),
    .rstn          (rstn),
    .direction_in  (direction),
    .food_eaten    (food_eaten),
    .collision     (collision),
    .frame_tick    (frame_tick),
    .update_snake  (update_snake),
    .score_inc     (score_inc),
    .reset_game    (reset_game),
    .direction_out (direction_out)
  );

  //snake logic wires
  wire [POS_BITS-1:0]           snake_head;
  wire [POS_BITS*MAX_LEN-1:0]   snake_body_flat;
  wire [6:0]                    snake_length;

  Snake_Logic #(
    .GRID_W   (GRID_W),
    .GRID_H   (GRID_H),
    .MAX_LEN  (MAX_LEN),
    .INIT_LEN (4),
    .POS_BITS (POS_BITS)
  ) snake (
    .clk             (clk),
    .rstn            (rstn),
    .update_snake    (update_snake),
    .direction_in    (direction_out),
    .food_eaten      (food_eaten),
    .snake_head      (snake_head),
    .snake_body_flat (snake_body_flat),
    .snake_length    (snake_length)
  );

  //food generator
  wire [POS_BITS-1:0] food_pos;
  Food_Generator #(
    .GRID_W   (GRID_W),
    .GRID_H   (GRID_H),
    .MAX_LEN  (MAX_LEN),
    .POS_BITS (POS_BITS)
  ) food_gen (
    .clk             (clk),
    .rstn            (rstn),
    .food_eaten      (food_eaten),
    .snake_body_flat (snake_body_flat),
    .snake_length    (snake_length),
    .food_pos        (food_pos)
  );

  //collision detector
  Collision_Detector #(
    .MAX_LEN  (MAX_LEN),
    .POS_BITS (POS_BITS),
    .GRID_W   (GRID_W),
    .GRID_H   (GRID_H)
  ) coll (
    .snake_head      (snake_head),
    .snake_body_flat (snake_body_flat),
    .snake_length    (snake_length),
    .food_pos        (food_pos),
    .direction_in    (direction_out),
    .food_eaten      (food_eaten),
    .collision       (collision)
  );

  //score and 7 seg
  wire [15:0] score;
  Score_Counter score_ctr (
    .clk       (clk),
    .rstn      (rstn),
    .score_inc (score_inc),
    .score     (score)
  );

  Seg_7_Display seg7 (
    .x   (score),
    .clk (clk),
    .clr (1'b0),
    .a_to_g(seg),
    .an  (an),
    .dp  (dp)
  );

  //vga 
  // Pixel outputs before pixel_color
  wire [3:0] pixel_red, pixel_green, pixel_blue;
  wire [11:0] pixel_color = {pixel_red, pixel_green, pixel_blue};

  wire        video_on;
  wire [10:0] XCoord, YCoord;

  VGA_Interface vga_if (
    .clk         (clk),
    .rstn        (rstn),
    .pixel_color (pixel_color),
    .vgaRed      (vgaRed),
    .vgaGreen    (vgaGreen),
    .vgaBlue     (vgaBlue),
    .Hsync       (Hsync),
    .Vsync       (Vsync),
    .XCoord      (XCoord),
    .YCoord      (YCoord)
  );

  //snake renderer
  Snake_Renderer #(
    .GRID_W   (GRID_W),
    .GRID_H   (GRID_H),
    .MAX_LEN  (MAX_LEN),
    .POS_BITS (POS_BITS)
  ) disp (
    .clk             (clk),
    .rstn            (rstn),
    .XCoord          (XCoord),
    .YCoord          (YCoord),
    .snake_body_flat (snake_body_flat),
    .snake_length    (snake_length),
    .food_pos        (food_pos),
    .game_over       (reset_game),
    .pixel_red       (pixel_red),
    .pixel_green     (pixel_green),
    .pixel_blue      (pixel_blue)
  );

endmodule