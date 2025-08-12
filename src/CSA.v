`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Bshara Rhall, Lior Daniel
// 
// Create Date:     11/10/2018 08:59:38 PM
// Design Name:     EE3 lab1
// Module Name:     CSA
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Variable length binary adder. The parameter N determines
//                  the bit width of the operands. Implemented according to 
//                  Conditional Sum Adder.
// 
// Dependencies:    FA
// 
// Revision:        2.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module CSA(a, b, ci, sum, co);

    parameter N=4;
    parameter K = N >> 1;
    
    input [N-1:0] a;
    input [N-1:0] b;
    input ci;
    output [N-1:0] sum;
    output co;
    
	generate
	   if (N==1) begin
	       FA fa_inst (.a(a[0]),.b(b[0]),.ci(ci),.sum(sum[0]),.co(co));
	       
	   end else begin
	       wire [K-1:0] sum_low;
	       wire co_low;
	       wire [N-K-1:0] sum_high_0, sum_high_1;
	       wire co_high_0, co_high_1;
	       
	       CSA #(.N(K))csa_low (.a(a[K-1:0]),.b(b[K-1:0]),.ci(ci),.sum(sum_low),.co(co_low)); // low part
	       
	       CSA #(.N(N-K))csa_high_0 (.a(a[N-1:K]),.b(b[N-1:K]),.ci(1'b0),.sum(sum_high_0),.co(co_high_0)); // high part with carry-in=0
	       
	       CSA #(.N(N-K))csa_high_1 (.a(a[N-1:K]),.b(b[N-1:K]),.ci(1'b1),.sum(sum_high_1),.co(co_high_1)); // high part with carry-in=1
	       
	       //MUX between the results
	       assign sum[K-1:0] = sum_low;
	       assign sum[N-1:K] = co_low ? sum_high_1 : sum_high_0;
	       assign co = co_low ? co_high_1 : co_high_0;
	       
	       end
           endgenerate
endmodule
