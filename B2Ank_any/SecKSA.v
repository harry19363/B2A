`timescale 1ns / 100ps

module SecKSA #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 3,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	parameter RANDNUM = 
)(
	input wire clk,  // clock
	input wire rst_n,  // areset on negative edge
	input wire dvld,  // data valid
	input wire ena,  // enable
	input wire [K_WIDTH * RANDNUM - 1:0] rnd,  // fresh randomness
	input wire [MASKWIDTH-1:0] x,  // input x
	input wire [MASKWIDTH-1:0] y,  // input y
	output wire [MASKWIDTH-1:0] z,  // output z
	output wire ovld  // output valid
);