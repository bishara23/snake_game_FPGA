`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Bshara Rhall, Lior Daniel
// 
// Create Date:     11/12/2018 08:59:38 PM
// Design Name:     EE3 lab1
// Module Name:     FA
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Well known full adder
// 
// Dependencies:    None
// 
// Revision:        2.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module FA(a, b, ci, sum, co);

  input   a, b, ci;
  output  sum, co;
  wire axb;
  
  assign axb = a^b;
  assign sum = axb ^ ci;
  assign co = (a&b) | (a&ci) | (b&ci);// FILL HERE

 
endmodule
