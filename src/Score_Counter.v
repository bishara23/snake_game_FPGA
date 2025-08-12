`timescale 1ns/1ps

module Score_Counter (
    input  wire        clk,        // system clock
    input  wire        rstn,       // active-low reset
    input  wire        score_inc,  // pulse to increment score
    output reg  [15:0] score       // score count
);

    // wires for lim inc modules
    wire [3:0] ones_next, tens_next, hundreds_next, thousands_next;
    wire       c1, c2, c3, c4;

    // Ones digit incrementer
    Lim_Inc #(.L(10)) inc0 (
        .a   (score[3:0]),
        .ci  (score_inc),
        .sum (ones_next),
        .co  (c1)
    );

    // Tens digit increment 
    Lim_Inc #(.L(10)) inc1 (
        .a   (score[7:4]),
        .ci  (c1),
        .sum (tens_next),
        .co  (c2)
    );

    // Hundreds digit
    Lim_Inc #(.L(10)) inc2 (
        .a   (score[11:8]),
        .ci  (c2),
        .sum (hundreds_next),
        .co  (c3)
    );

    // Thousands digit
    Lim_Inc #(.L(10)) inc3 (
        .a   (score[15:12]),
        .ci  (c3),
        .sum (thousands_next),
        .co  (c4)
    );

    // Register the new score
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            score <= 16'd0;
        else if (score_inc)
            score <= {thousands_next, hundreds_next, tens_next, ones_next};
    end

endmodule