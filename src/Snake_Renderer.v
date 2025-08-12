`timescale 1ns/1ps

module Snake_Renderer #(
  parameter GRID_W    = 100,    // cols
  parameter GRID_H    = 75,     // rows
  parameter MAX_LEN   = 64,     // maximum snake segments
  parameter POS_BITS  = 13      // bits to index GRID_W*GRID_H 
)(
  input  wire                     clk,
  input  wire                     rstn,           
  input  wire [10:0]              XCoord,         // current cell X 
  input  wire [10:0]              YCoord,         // current cell Y 
  input  wire [POS_BITS*MAX_LEN-1:0] snake_body_flat, // snake body flat
  input  wire [$clog2(MAX_LEN+1)-1:0] snake_length,   // current snake length
  input  wire [POS_BITS-1:0]      food_pos,       // flat index for food cell
  input  wire                     game_over,      // high when game over
  output reg  [3:0]               pixel_red,
  output reg  [3:0]               pixel_green,
  output reg  [3:0]               pixel_blue
);

  localparam CHAR_W     = 8;                    // for font
  localparam CHAR_H     = 8;                    //for font
  localparam TEXT_CHARS = 9;                    // how many chars
  localparam TEXT_W     = CHAR_W * TEXT_CHARS;  // 72 cells on width
  localparam TEXT_H     = CHAR_H;               //  8 cells hight
  localparam X0         = (GRID_W - TEXT_W) / 2; //  (100 - 72)/2 = 14 pointer for the the center region
  localparam Y0         = (GRID_H - TEXT_H) / 2; //  ( 75 -  8)/2 = 33 pointer for the the center region on y

// counter generation
  localparam WIDTH = 27;
  reg [WIDTH-1:0] free_counter;
  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      free_counter <= 0;
    else
      free_counter <= free_counter + 1;
  end

    wire [3:0] fade = free_counter[26:23];
    


    //snake hit flag 
  integer i;
  reg [POS_BITS-1:0] cur_pos;
  reg snake_pixel;
  always @(*) begin
    cur_pos     = YCoord * GRID_W + XCoord;
    snake_pixel = 1'b0;
    for (i = 0; i < MAX_LEN; i = i + 1) begin
      if (i < snake_length && snake_body_flat[i*POS_BITS +: POS_BITS] == cur_pos)
        snake_pixel = 1'b1;
    end
  end


  reg [11:0] bg_color;
  reg [11:0] txt_color;
  reg  [3:0] char_idx;
  reg  [2:0] row_idx;
  reg  [2:0] bit_idx;
  wire [7:0] font_bits;

// init of font rom for the game over
  Font_ROM font_rom (
    .char_idx(char_idx),
    .row_idx (row_idx),
    .bits    (font_bits)
  );

    // paintiing the screen logic
  always @(*) begin
    if (game_over) begin
        txt_color = {fade, fade, fade}; 
        
        bg_color  = ~txt_color;

      // draw centered text
      if (XCoord >= X0 && XCoord < X0 + TEXT_W &&
          YCoord >= Y0 && YCoord < Y0 + TEXT_H) begin
        char_idx = (XCoord - X0) / CHAR_W;
        row_idx  = (YCoord - Y0);
        bit_idx  = 3'd7 - ((XCoord - X0) % CHAR_W);
        if (font_bits[bit_idx])
          {pixel_red, pixel_green, pixel_blue} = txt_color;
        else
          {pixel_red, pixel_green, pixel_blue} = bg_color;
      end else begin
        // outside text: solid background
        {pixel_red, pixel_green, pixel_blue} = bg_color;
      end

    end else begin
      // normal game rendering
      if (snake_pixel) begin
        pixel_red   = 4'h0;
        pixel_green = 4'hF;
        pixel_blue  = 4'h0;
      end else if (cur_pos == food_pos) begin
        pixel_red   = 4'hF;
        pixel_green = 4'h0;
        pixel_blue  = 4'h0;
      end else begin
        pixel_red   = 4'h0;
        pixel_green = 4'h0;
        pixel_blue  = 4'h0;
      end
    end
  end

endmodule
