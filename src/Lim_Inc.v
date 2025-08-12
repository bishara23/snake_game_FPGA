`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Bshara Rhall, Lior Daniel
// 
// Create Date:     11/12/2018 08:59:38 PM
// Design Name:     EE3 lab1
// Module Name:     Lim_Inc
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Incrementor modulo L, where the input a is *saturated* at L 
//                  If a+ci>L, then the output will be s=0,co=1 anyway.
// 
// Dependencies:    CSA
// 
// Revision:        2.0
// Revision         2.1 - Fall 2018 - changed parameter to localparam
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Lim_Inc(a, ci, sum, co);
    
    parameter L = 10;
    parameter N = $clog2(L);
    
    input [N-1:0] a;
    input ci;
    output [N-1:0] sum;
    output co;

    wire [N-1:0] sum_csa;
    wire co_csa;
    
   CSA #(.N(N)) csa_inst (
            .a(a),
            .b({N{1'b0}}),
            .ci(ci),
            .sum(sum_csa),
            .co(co_csa)
        );
    
    wire [N:0] result = {co_csa,sum_csa};
    assign co = (result >= L ) ? 1'b1 : 1'b0;
    assign sum = (co) ? {N{1'b0}} : sum_csa;
endmodule
