`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Debouncer
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices: 
// Tool versions: 
// Description:     receives an unstable (toggling) digital signal as an input
//                  outputs a single cycle high (1) pulse upon receiving 2**(COUNTER_BITS-1) more ones than zeros.
//                  This creates a hysteresis phenomenon, robust to toggling.
//              
//                  This module should be used to process a normally-off signal and to catch its long lasting "1" period and
//                  shrinking them into a single cycle "1".
//
// Dependencies:    None
//
// Revision:        3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Debouncer(clk, input_unstable, output_stable);

   input clk, input_unstable;
   output reg output_stable;
   
   parameter COUNTER_BITS = 7;
   
   reg [COUNTER_BITS-1:0] counter; // Hysteresis counter
   reg [COUNTER_BITS-1:0] prev_counter;    // we added this register in order to achieve the single cycle req
   
   always @(posedge clk)
     begin

        prev_counter <= counter; // Store previous counter value
        
        if (input_unstable == 1)
            counter <= (counter < {COUNTER_BITS{1'b1}}) ? counter  + 1 : counter;
        else
            counter <= (counter > {COUNTER_BITS{1'b0}}) ? counter  - 1 : counter;
            
        // Synchronously generate 1-cycle-pulse upon the transition from 0 mode to 1 mode.
        
        output_stable <= (counter == {COUNTER_BITS{1'b1}} && prev_counter != {COUNTER_BITS{1'b1}}); // if prev_counter reach max val -> one cycle passed
        
     end
       
endmodule
