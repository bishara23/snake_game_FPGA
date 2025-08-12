`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Bshara Rhall, Lior Daniel
// 
// Create Date:     11/12/2018 08:59:38 PM
// Design Name:     EE3 lab1
// Module Name:     Counter
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     A counter that advances its reading as long as time_reading 
//                  signal is high and zeroes its reading upon init_regs=1 input.
//                  the time_reading output represents: 
//                  {dekaseconds,seconds:deciseconds,centiseconds}
// Dependencies:    Lim_Inc
//
//////////////////////////////////////////////////////////////////////////////////
module Counter(clk, init_regs, count_enabled, count_sample, show_sample, time_reading);

   parameter CLK_FREQ = 100000000;// in Hz
   
   input clk, init_regs, count_enabled, count_sample, show_sample;
   output [15:0] time_reading;

   reg [$clog2(CLK_FREQ/100)-1:0] clk_cnt;
   reg [3:0] ones_centiseconds;
   reg [3:0] tens_centiseconds;
   reg [3:0] ones_seconds;    
   reg [3:0] tens_seconds;

   // Sampled time registers
   reg [3:0] ones_csec_sampled;
   reg [3:0] tens_csec_sampled;
   reg [3:0] ones_sec_sampled;
   reg [3:0] tens_sec_sampled;
   
   // FILL HERE THE LIMITED-COUNTER INSTANCES
   wire [3:0] ones_centiseconds_next;
   wire [3:0] tens_centiseconds_next;
   wire [3:0] ones_seconds_next;
   wire [3:0] tens_seconds_next;
   
   wire co_centi, co_dsec, co_sec, co_dasec;

   Lim_Inc #(.L(10)) inc_centi (
       .a(ones_centiseconds),
       .ci(1'b1),
       .sum(ones_centiseconds_next),
       .co(co_centi)
   );

   Lim_Inc #(.L(10)) inc_dsec (
       .a(tens_centiseconds),
       .ci(co_centi),
       .sum(tens_centiseconds_next),
       .co(co_dsec)
   );

   Lim_Inc #(.L(10)) inc_sec (
       .a(ones_seconds),
       .ci(co_dsec),
       .sum(ones_seconds_next),
       .co(co_sec)
   );

   Lim_Inc #(.L(10)) inc_dasec (
       .a(tens_seconds),
       .ci(co_sec),
       .sum(tens_seconds_next),
       .co(co_dasec)
   );
   
   //------------- Synchronous ----------------
   always @(posedge clk) begin
      if (init_regs) begin
         clk_cnt <= 0;
         ones_centiseconds <= 0;
         tens_centiseconds <= 0;
         ones_seconds <= 0;
         tens_seconds <= 0;
      end else if (count_enabled) begin
         if (clk_cnt == (CLK_FREQ/100 - 1)) begin
            clk_cnt <= 0;

            // Update all time digits
            ones_centiseconds <= ones_centiseconds_next;
            tens_centiseconds <= tens_centiseconds_next;
            ones_seconds <= ones_seconds_next;
            tens_seconds <= tens_seconds_next;
         end else begin
            clk_cnt <= clk_cnt + 1;
         end
      end

      // Time sampling
      if (count_sample) begin
         ones_csec_sampled  <= ones_centiseconds;
         tens_csec_sampled  <= tens_centiseconds;
         ones_sec_sampled   <= ones_seconds;
         tens_sec_sampled   <= tens_seconds;
      end
   end

   // Output logic: live or sampled
   assign time_reading = show_sample ?
                         {tens_sec_sampled, ones_sec_sampled, tens_csec_sampled, ones_csec_sampled} :
                         {tens_seconds, ones_seconds, tens_centiseconds, ones_centiseconds};

endmodule
