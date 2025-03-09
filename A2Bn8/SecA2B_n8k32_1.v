//////////////////////////////////////////////////////////////////////////////////
// Company       : TSU
// Engineer      : 
// 
// Create Date   : 2025-03-06
// File Name     : SecA2B_n8k32_1.v
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
module SecA2B_n8k32_1(
    input  wire           clk_i,
    input  wire           rst_ni,
    input  wire           i_dvld,
    input  wire           i_rvld,
    input  wire [11615:0] i_n,
    input  wire   [255:0] i_a,
    output wire   [255:0] o_z,
    output wire           o_dvld);

wire    [255:0] s;
wire    [255:0] c;
wire            vk;

// ------------------------------------------------------------------------------
// Do SecCSAtree instance
// ------------------------------------------------------------------------------
SecCSATree_n8k32
  u0_SecCSATree_n8k32
   (.clk_i  (clk_i),
    .rst_ni (rst_ni),
    .i_dvld (i_dvld),
    .i_rvld (i_rvld),
    .i_n    (i_n[0+:2656]),
    .i_x    (i_a),
    .o_s    (s),
    .o_c    (c),
    .o_dvld (vk));



// ------------------------------------------------------------------------------
// Do SecKSA instance
// ------------------------------------------------------------------------------
SecKSA_n8k32_1
  u1_SecKSA_n8k32_1
   (.clk_i  (clk_i),
    .rst_ni (rst_ni),
    .i_dvld (vk),
    .i_rvld (i_rvld),
    .i_n    (i_n[2656+:8960]),
    .i_x    (s),
    .i_y    (c),
    .o_z    (o_z),
    .o_dvld (o_dvld));


endmodule
