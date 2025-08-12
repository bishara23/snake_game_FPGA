`timescale 1ns/1ps

module Food_Generator #(
    parameter integer GRID_W     = 100,
    parameter integer GRID_H     = 75,
    parameter integer MAX_LEN    = 64,
    parameter integer POS_BITS   = 13
)(
    input  wire                         clk,
    input  wire                         rstn,
    input  wire                         food_eaten,        // snake just ate
    input  wire [POS_BITS*MAX_LEN-1:0]  snake_body_flat,   // body indices
    input  wire [$clog2(MAX_LEN):0]     snake_length,
    output reg  [POS_BITS-1:0]          food_pos           // current food
);


    localparam integer TOTAL_CELLS = GRID_W * GRID_H;
    // FSM states
    localparam S_IDLE   = 1'b0;
    localparam S_SEARCH = 1'b1;


    // 13-bit Galois LFSR

    reg  [POS_BITS-1:0] lfsr_q = 13'h1;  // non-zero seed
    wire feedback = lfsr_q[12] ^ lfsr_q[3] ^ lfsr_q[2] ^ lfsr_q[0];
    wire [POS_BITS-1:0] lfsr_nxt = {lfsr_q[11:0], feedback};


    // FSM regs

    reg state_q = S_IDLE, state_d;

    // candidate chosen this cycle 
    reg [POS_BITS-1:0] cand_idx;


    //scans current snake list

    //returns 1 if idx equals any element in snake_body_flat
    function automatic collides;
        input [POS_BITS-1:0] idx;
        integer i;
        begin
            collides = 1'b0;
            for (i = 0; i < MAX_LEN; i = i + 1) begin : OCC
                if (i < snake_length) begin
                    if (snake_body_flat[i*POS_BITS +: POS_BITS] == idx)
                        collides = 1'b1;
                end
            end
        end
    endfunction


    // Sequential part

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state_q <= S_IDLE;
            lfsr_q  <= 13'h1;
            food_pos<= 0;               // top-left by default
        end else begin
            state_q <= state_d;
            lfsr_q  <= lfsr_nxt;
            if (state_q == S_SEARCH && state_d == S_IDLE) begin
                // just accepted cand_idx
                food_pos <= cand_idx;
            end
        end
    end


    //next state logic

    always @* begin
        state_d  = state_q;   // default stay
        cand_idx = food_pos;  // default hold

        case (state_q)
            S_IDLE: begin
                if (food_eaten) begin
                    state_d = S_SEARCH;
                end
            end

            S_SEARCH: begin
                //stay here until valid val found
                if (lfsr_nxt < TOTAL_CELLS && !collides(lfsr_nxt)) begin
                    cand_idx = lfsr_nxt;
                    state_d  = S_IDLE;   // accept & return to idle
                end else begin
                    state_d  = S_SEARCH; // stay and try next value next cycle
                end
            end
        endcase
    end

endmodule
