`timescale 1ns/1ps

module Collision_Detector #(
    parameter MAX_LEN   = 64,    // must match Snake_Logic.MAX_LEN
    parameter POS_BITS  = 13,    // bits needed to encode GRID_W*GRID_H
    parameter GRID_W    = 100,   // board width
    parameter GRID_H    = 75     // board height
)(
    input  wire [POS_BITS-1:0]        snake_head,
    input  wire [POS_BITS*MAX_LEN-1:0] snake_body_flat,
    input  wire [6:0]                 snake_length,
    input  wire [POS_BITS-1:0]        food_pos,
    input  wire [1:0]                 direction_in,
    output wire                       food_eaten, //high on eat 
    output wire                       collision // high when collision self or wall
);

    // Food-eaten flag
    assign food_eaten = (snake_head == food_pos);

    //Decode head X/Y to check wall hits
    wire [6:0] head_x = snake_head % GRID_W;
    wire [6:0] head_y = snake_head / GRID_W;

    wire hit_left  = (direction_in == 2'b11) && (head_x == 0);
    wire hit_right = (direction_in == 2'b01) && (head_x == GRID_W-1);
    wire hit_up    = (direction_in == 2'b00) && (head_y == 0);
    wire hit_down  = (direction_in == 2'b10) && (head_y == GRID_H-1);
    wire wall_collision = hit_left || hit_right || hit_up || hit_down;

    //Self-collision compare head to each body segment
    reg col_self;
    integer i;
    always @(*) begin
        col_self = 0;
        for (i = 1; i < MAX_LEN; i = i + 1) begin
            // only actually compare the live segments
            if (i < snake_length) begin
                if (snake_head == snake_body_flat[i*POS_BITS +: POS_BITS]) begin
                    col_self = 1;
                end
            end
        end
    end

    // collision check
    assign collision = col_self || wall_collision;

endmodule
