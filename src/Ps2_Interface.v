// Ps2_Interface.v


module Ps2_Interface (
    input  wire       PS2Clk,      // PS/2 clock (slow, only toggles during frames)
    input  wire       clk,         // 100 MHz system clock for pulse sync
    input  wire       rstn,        // async, active-low
    input  wire       PS2Data,     // PS/2 data line
    output reg  [7:0] scancode,    // latched make-code
    output reg        keyPressed   // one-cycle pulse in 'clk' domain
);


    reg  [3:0]  bit_count;       
    reg  [9:0]  shift_reg;       // { newest_bit … start_bit } which meens we push from the left the LSB's
    reg         got_make;        // used to flag
    reg         skip_next;       // used to flag after 0xF0
    reg         ps2_pulse;       // raw pulse in PS2Clk domain

    wire [7:0] data_byte = shift_reg[8:1];

    always @(negedge PS2Clk or negedge rstn) begin
        if (!rstn) begin
            bit_count   <= 4'd0;
            shift_reg   <= 10'd0;
            got_make    <= 1'b0;
            skip_next   <= 1'b0;
            ps2_pulse   <= 1'b0;
            scancode    <= 8'd0;
        end else begin
            ps2_pulse <= 1'b0;  // default: no pulse

            if (bit_count == 4'd10) begin
                // we've just shifted in parity; data_byte is valid
                if      (data_byte == 8'hE0) begin
                    // extended prefix: ignore
                end else if (data_byte == 8'hF0) begin
                    skip_next <= 1'b1;
                    got_make  <= 1'b0;
                end else if (skip_next) begin
                    // drop release scan-code
                    skip_next <= 1'b0;
                end else if (!got_make || data_byte != scancode) begin
                         // either the first make-code, or a _new_ key while holding the old one
                         scancode  <= data_byte;
                         ps2_pulse <= 1'b1;
                         got_make  <= 1'b1;
                         end
                         end

            // shift in start/data/parity (ignore stop bit)
            shift_reg <= { PS2Data, shift_reg[9:1] };
            bit_count <= (bit_count == 4'd10) ? 4'd0
                                              : bit_count + 4'd1;
        end
    end
    

    // SYSTEM-CLOCK DOMAIN 
    // Two-flop synchronizer so we can transfer ps2_pulse into clk domain
    reg sync1, sync2;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sync1      <= 1'b0;
            sync2      <= 1'b0;
            keyPressed <= 1'b0;
        end else begin
            sync1      <= ps2_pulse;
            sync2      <= sync1;
            // one-cycle pulse when ps2_pulse rises
            keyPressed <= sync1 & ~sync2;
        end
    end

endmodule