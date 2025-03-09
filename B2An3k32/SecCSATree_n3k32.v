//////////////////////////////////////////////////////////////////////////////////
// Company       : TSU
// Engineer      : 
// 
// Create Date   : 2024-04-26
// File Name     : SecCSATree_n3k32.v
// Project Name  : 
// Design Name   : 
// Description   : 
//                
// 
// Dependencies  : 
// 
// Revision      : 
//                 - V1.0 File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// 
// WARNING: THIS FILE IS AUTOGENERATED
// ANY MANUAL CHANGES WILL BE LOST

`timescale 1ns/1ps
module SecCSATree_n3k32(
    input  wire        clk_i,
    input  wire        rst_ni,
    input  wire        i_dvld,
    input  wire        i_rvld,
    input  wire [95:0] i_n,
    input  wire [95:0] i_x,
    output wire [95:0] o_s,
    output wire [95:0] o_c,
    output wire        o_dvld);

wire     [95:0] y1;
wire     [95:0] y2;
wire     [95:0] y3;
wire            vc;

// ------------------------------------------------------------------------------
// y1[0]= x[0];
// y1[1]= 0;
// y1[2]= 0;
// ------------------------------------------------------------------------------
assign y1[0+:32] = i_x[0+:32];
assign y1[32+:32] = 32'd0;
assign y1[64+:32] = 32'd0;

// ------------------------------------------------------------------------------
// y2[0]= 0;
// y2[1]= x[1];
// y2[2]= 0;
// ------------------------------------------------------------------------------
assign y2[0+:32] = 32'd0;
assign y2[32+:32] = i_x[32+:32];
assign y2[64+:32] = 32'd0;

// ------------------------------------------------------------------------------
// y3[0]= 0;
// y3[1]= 0;
// y3[2]= x[2];
// ------------------------------------------------------------------------------
assign y3[0+:32] = 32'd0;
assign y3[32+:32] = 32'd0;
assign y3[64+:32] = i_x[64+:32];

// ------------------------------------------------------------------------------
// connect i_dvld to csa valid
// ------------------------------------------------------------------------------
assign vc = i_dvld;

// ------------------------------------------------------------------------------
// Do SecCSA instance
// ------------------------------------------------------------------------------
SecCSA_n3k32
  u0_SecCSA_n3k32
   (.clk_i  (clk_i),
    .rst_ni (rst_ni),
    .i_dvld (vc),
    .i_rvld (i_rvld),
    .i_n    (i_n[0+:96]),
    .i_x    (y1),
    .i_y    (y2),
    .i_c_in (y3),
    .o_s    (o_s),
    .o_c    (o_c),
    .o_dvld (o_dvld));


endmodule
