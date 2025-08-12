
module Game_FSM (
    input  wire       clk,
    input  wire       rstn,             // active-low reset
    input  wire [1:0] direction_in,     // new direction from PS2
    input  wire       food_eaten,       // from Collision_Detector
    input  wire       collision,        // from Collision_Detector
    output reg        frame_tick,       // one-clock pulse per frame
    output reg        update_snake,     // pulse to advance snake
    output reg        score_inc,        // pulse on eating food
    output reg        reset_game,       // hold high on game-over
    output reg [1:0]  direction_out     // latched direction
);

  // State encoding
  localparam IDLE     = 2'b00;
  localparam RUN      = 2'b01;
  localparam GAMEOVER = 2'b10;
  reg [1:0] state, next_state;

  // Frame-tick generator parameters
  parameter [24:0] TICKS_PER_FRAME = 25'd20_000_000;
  reg  [24:0] tick_counter;

  // Align food_eaten to the next frame_tick
  reg eaten_latched;

  // 1) Generate slow frame_tick and manage eaten_latched
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      tick_counter   <= 0;
      frame_tick     <= 0;
      eaten_latched  <= 0;
    end else begin
      // frame tick logic
      if (tick_counter == TICKS_PER_FRAME-1) begin
        tick_counter <= 0;
        frame_tick   <= 1;
      end else begin
        tick_counter <= tick_counter + 1;
        frame_tick   <= 0;
      end
      // latch food_eaten until next frame_tick
      if (food_eaten)
        eaten_latched <= 1;
      else if (frame_tick)
        eaten_latched <= 0;
    end
  end

  // 2) State register
  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      state <= IDLE;
    else
      state <= next_state;
  end

  // 3) Next-state logic and outputs
  always @(*) begin
    // default outputs
    next_state    = state;
    update_snake  = 0;
    score_inc     = 0;
    reset_game    = 0;
    direction_out = direction_in;

    case (state)
      IDLE: begin
        if (rstn)
          next_state = RUN;
      end

      RUN: begin
        if (frame_tick) begin
          update_snake = 1;
          if (eaten_latched)
            score_inc = 1;
          if (collision)
            next_state = GAMEOVER;
        end
      end

      GAMEOVER: begin
        reset_game = 1;
        if (!rstn)
          next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end

endmodule