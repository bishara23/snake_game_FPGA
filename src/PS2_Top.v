`timescale 1ns/10ps

module Ps2_Top (
    input  wire       clk,     // 100 MHz system clock (W5)
    input  wire       btnC,    // button input (active-high, U18)
    input  wire       PS2Clk,  // PS2 clock (C17)
    input  wire       PS2Data, // PS2 data  (B17)
//    output wire [6:0] seg,     // segment cathodes
//    output wire [3:0] an,      // digit anodes
//    output wire       dp,      // decimal point
//    output wire       led,      // user LED strobe
    output wire [1:0] direction
);

    wire db_btnC;
    Debouncer db_reset   (.clk(clk), .input_unstable(btnC), .output_stable(db_btnC));
    wire rstn = ~db_btnC; // convert button to active-low reset

    wire [7:0] scancode;
    wire       keyPressed;

    Ps2_Interface u_iface (
        .PS2Clk     (PS2Clk),
        .clk        (clk),
        .rstn       (rstn),
        .PS2Data    (PS2Data),
        .scancode   (scancode),
        .keyPressed (keyPressed)
    );

//    Ps2_Display u_display (
//        .clk        (clk),
//        .rstn       (rstn),
//        .keyPressed (keyPressed),
//        .scancode   (direction),
//        .seg        (seg),
//        .an         (an),
//        .dp         (dp),
//        .led        (led)
//    );
    
    Direction_Decoder d_decoder (
        .clk                (clk),
        .rstn               (rstn),
        .scancode           (scancode),
        .scancode_valid     (keyPressed),
        .direction          (direction)
    );
        

endmodule