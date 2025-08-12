`timescale 1ns/1ps

module Font_ROM (
  input  wire [3:0] char_idx,   // which character (0-8)
  input  wire [2:0] row_idx,    // which row of the 8X8 letter
  output reg  [7:0] bits        // 1=pixel on 0=off 
);

always @(*) begin
  case (char_idx)
    4'd0: // 'G'
      case (row_idx)
        3'd0: bits = 8'b00111100;
        3'd1: bits = 8'b01000010;
        3'd2: bits = 8'b01000000;
        3'd3: bits = 8'b01001110;
        3'd4: bits = 8'b01000010;
        3'd5: bits = 8'b01000010;
        3'd6: bits = 8'b01000110;
        3'd7: bits = 8'b00111000;
      endcase

    4'd1: // 'A'
      case (row_idx)
        3'd0: bits = 8'b00011000;
        3'd1: bits = 8'b00100100;
        3'd2: bits = 8'b01000010;
        3'd3: bits = 8'b01000010;
        3'd4: bits = 8'b01111110;
        3'd5: bits = 8'b01000010;
        3'd6: bits = 8'b01000010;
        3'd7: bits = 8'b01000010;
      endcase

    4'd2: // 'M'
      case (row_idx)
        3'd0: bits = 8'b01000010;
        3'd1: bits = 8'b01100110;
        3'd2: bits = 8'b01011010;
        3'd3: bits = 8'b01000010;
        3'd4: bits = 8'b01000010;
        3'd5: bits = 8'b01000010;
        3'd6: bits = 8'b01000010;
        3'd7: bits = 8'b01000010;
      endcase

    4'd3: // 'E'
      case (row_idx)
        3'd0: bits = 8'b01111110;
        3'd1: bits = 8'b01000000;
        3'd2: bits = 8'b01000000;
        3'd3: bits = 8'b01111100;
        3'd4: bits = 8'b01000000;
        3'd5: bits = 8'b01000000;
        3'd6: bits = 8'b01000000;
        3'd7: bits = 8'b01111110;
      endcase

    4'd4: // ' ' (space)
      bits = 8'b00000000;

    4'd5: // 'O'
      case (row_idx)
        3'd0: bits = 8'b00111100;
        3'd1: bits = 8'b01000010;
        3'd2: bits = 8'b01000010;
        3'd3: bits = 8'b01000010;
        3'd4: bits = 8'b01000010;
        3'd5: bits = 8'b01000010;
        3'd6: bits = 8'b01000010;
        3'd7: bits = 8'b00111100;
      endcase

    4'd6: // 'V'
      case (row_idx)
        3'd0: bits = 8'b01000010;
        3'd1: bits = 8'b01000010;
        3'd2: bits = 8'b01000010;
        3'd3: bits = 8'b01000010;
        3'd4: bits = 8'b01000010;
        3'd5: bits = 8'b00100100;
        3'd6: bits = 8'b00100100;
        3'd7: bits = 8'b00011000;
      endcase

    4'd7: // 'E' (repeat)
      case (row_idx)
        3'd0: bits = 8'b01111110;
        3'd1: bits = 8'b01000000;
        3'd2: bits = 8'b01000000;
        3'd3: bits = 8'b01111100;
        3'd4: bits = 8'b01000000;
        3'd5: bits = 8'b01000000;
        3'd6: bits = 8'b01000000;
        3'd7: bits = 8'b01111110;
      endcase

    4'd8: // 'R'
      case (row_idx)
        3'd0: bits = 8'b01111100;
        3'd1: bits = 8'b01000010;
        3'd2: bits = 8'b01000010;
        3'd3: bits = 8'b01111100;
        3'd4: bits = 8'b01010000;
        3'd5: bits = 8'b01001000;
        3'd6: bits = 8'b01000100;
        3'd7: bits = 8'b01000010;
      endcase

    default:
      bits = 8'b00000000;
  endcase
end

endmodule
