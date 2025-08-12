// Direction_Decoder.v


module Direction_Decoder (
    input  wire       clk,    // system clock
    input  wire       rstn,  // active-low reset
    input  wire [7:0] scancode, // 8-bit PS/2 scancode
    input  wire       scancode_valid,// high when scancode is valid
    output reg  [1:0] direction  // 00=Up, 01=Right, 10=Down, 11=Left
);

    // Direction encoding
    localparam UP    = 2'b00;
    localparam RIGHT = 2'b01;
    localparam DOWN  = 2'b10;
    localparam LEFT  = 2'b11;

    // PS2 scancode values for keys '8','6','5','4'
    localparam SC_8 = 8'h75;
    localparam SC_6 = 8'h74;
    localparam SC_5 = 8'h73;
    localparam SC_4 = 8'h6B;

    reg [1:0] next_direction;

    // Combinational logic: decode new direction and prevent reverse
    always @(*) begin
        next_direction = direction;  // default: hold current direction
        if (scancode_valid) begin
            case (scancode)
                SC_8: next_direction = UP;
                SC_6: next_direction = RIGHT;
                SC_5: next_direction = DOWN;
                SC_4: next_direction = LEFT;
                default: ;
            endcase
            // Block 180 reversal
            case (direction)
                UP:    if (next_direction == DOWN)  next_direction = direction;
                DOWN:  if (next_direction == UP)    next_direction = direction;
                LEFT:  if (next_direction == RIGHT) next_direction = direction;
                RIGHT: if (next_direction == LEFT)  next_direction = direction;
            endcase
        end
    end

    // Sequential update on clock edge or reset
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            direction <= UP;             // default direction after reset
        else
            direction <= next_direction;
    end

endmodule