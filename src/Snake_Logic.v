`timescale 1ns/1ps

module Snake_Logic #(
  parameter GRID_W   = 100,    // X
  parameter GRID_H   = 75,     // Y
  parameter MAX_LEN  = 64,     // maximum snake segments
  parameter INIT_LEN = 4,      // initial snake length
  parameter POS_BITS = 13      // bits to encode GRID_WªGRID_H
)(
  input  wire                   clk,
  input  wire                   rstn,          // async, active-low reset
  input  wire                   update_snake,  // 1-cycle move pulse
  input  wire                   food_eaten,    // 1-cycle grow-on-eat pulse
  input  wire [1:0]             direction_in,  // 00=Up,01=Right,10=Down,11=Left
  output reg  [POS_BITS-1:0]    snake_head,    // flat index of head
  output reg  [$clog2(MAX_LEN):0] snake_length, // current snake length
  output wire [POS_BITS*MAX_LEN-1:0] snake_body_flat
);

//pipe;ine regs
  reg [POS_BITS-1:0] snake_body [0:MAX_LEN-1];
  reg [POS_BITS-1:0] new_head;         // temp for computed flat index
  reg [6:0]          head_x, head_y;   // head coordinates
  reg                upd_s1, eat_s1;   // stage-1 control latches
  reg                grow_req;         // remember eat until next move
  integer            i;

  //stage 1: sample inputs & move head_x/head_y
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      head_x <= GRID_W/2;
      head_y <= GRID_H/2;
      upd_s1 <= 1'b0;
      eat_s1 <= 1'b0;
    end else begin
      // latch the control pulses
      upd_s1 <= update_snake;
      eat_s1 <= food_eaten;
      // update Cartesian head position
      if (update_snake) begin
        case (direction_in)
          2'b00: head_y <= (head_y == 0        ? GRID_H-1 : head_y-1);
          2'b01: head_x <= (head_x == GRID_W-1 ? 0        : head_x+1);
          2'b10: head_y <= (head_y == GRID_H-1 ? 0        : head_y+1);
          2'b11: head_x <= (head_x == 0        ? GRID_W-1 : head_x-1);
        endcase
      end
    end
  end

  //stage 2:compute index, shift & grow, update head & length
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      // initialize length, head, body-array, grow flag
      snake_length <= INIT_LEN;
      snake_head   <= (GRID_H/2)*GRID_W + (GRID_W/2);
      grow_req     <= 1'b0;
      for (i = 0; i < INIT_LEN;  i = i + 1)
        snake_body[i] <= (GRID_H/2)*GRID_W + ((GRID_W/2) - i);
      for (i = INIT_LEN; i < MAX_LEN; i = i + 1)
        snake_body[i] <= {POS_BITS{1'b0}};
    end else begin
      // manage growth flag
      if      (eat_s1)    grow_req <= 1'b1;
      else if (upd_s1)    grow_req <= 1'b0;

      if (upd_s1) begin
        // compute flat index (no division)
        new_head = head_y * GRID_W + head_x;
        // shift body down
        for (i = MAX_LEN-1; i > 0; i = i - 1)
          snake_body[i] <= snake_body[i-1];
        snake_body[0] <= new_head;
        // grow length if flagged
        if (grow_req && (snake_length < MAX_LEN))
          snake_length <= snake_length + 1;
        // update head output
        snake_head <= new_head;
      end
    end
  end

  // flatten the body array into a wide bus

  genvar idx;
  generate
    for (idx = 0; idx < MAX_LEN; idx = idx + 1) begin : FLATTEN
      assign snake_body_flat[idx*POS_BITS +: POS_BITS] = snake_body[idx];
    end
  endgenerate

endmodule
