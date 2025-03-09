//////////////////////////////////////////////////////////////////////////////////
// Company       : TSU
// Engineer      : 
// 
// Create Date   : 2025-03-06
// File Name     : SecCSA_n6k32.v
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
module SecCSA_n6k32(
    input  wire         clk_i,
    input  wire         rst_ni,
    input  wire         i_dvld,
    input  wire         i_rvld,
    input  wire [479:0] i_n,
    input  wire [191:0] i_x,
    input  wire [191:0] i_y,
    input  wire [191:0] i_c_in,
    output wire [191:0] o_c,
    output wire [191:0] o_s,
    output wire         o_dvld);

wire    [191:0] a;
wire    [191:0] s;
wire    [191:0] w;
wire    [191:0] v;
wire    [191:0] vls;
wire    [191:0] sd;
wire    [191:0] xd;
wire    [191:0] xxv;

// ------------------------------------------------------------------------------
// a[i]=x[i]^y[i];
// ------------------------------------------------------------------------------
lix_xor
  #(.W (192))
  u0_lix_xor
   (.i_x (i_x),
    .i_y (i_y),
    .o_z (a));



// ------------------------------------------------------------------------------
// s[i]=a[i]^cin[i];
// ------------------------------------------------------------------------------
lix_xor
  #(.W (192))
  u1_lix_xor
   (.i_x (a),
    .i_y (i_c_in),
    .o_z (s));



// ------------------------------------------------------------------------------
// w[i]=x[i]^cin[i];
// ------------------------------------------------------------------------------
lix_xor
  #(.W (192))
  u2_lix_xor
   (.i_x (i_x),
    .i_y (i_c_in),
    .o_z (w));



// ------------------------------------------------------------------------------
// SecAnd_PINI1(a,w,v,k,n);
// ------------------------------------------------------------------------------
SecAnd_PINI1_n6k32_1
  u3_SecAnd_PINI1_n6k32_1
   (.clk_i  (clk_i),
    .rst_ni (rst_ni),
    .i_dvld (i_dvld),
    .i_rvld (i_rvld),
    .i_n    (i_n),
    .i_x    (a),
    .i_y    (w),
    .o_c    (v),
    .o_dvld (o_dvld));



// ------------------------------------------------------------------------------
// Delay s
// ------------------------------------------------------------------------------
lix_shr0
  #(.W (192),
    .N (2))
  u4_lix_shr0
   (.clk_i  (clk_i),
    .rst_ni (rst_ni),
    .i_vld  (i_dvld),
    .i_en   (i_rvld),
    .i_x    (s),
    .o_z    (sd));



// ------------------------------------------------------------------------------
// Delay i_x
// ------------------------------------------------------------------------------
lix_shr0
  #(.W (192),
    .N (2))
  u5_lix_shr0
   (.clk_i  (clk_i),
    .rst_ni (rst_ni),
    .i_vld  (i_dvld),
    .i_en   (i_rvld),
    .i_x    (i_x),
    .o_z    (xd));



// ------------------------------------------------------------------------------
// x[i] ^ v[i]
// ------------------------------------------------------------------------------
lix_xor
  #(.W (192))
  u6_lix_xor
   (.i_x (xd),
    .i_y (v),
    .o_z (xxv));



// ------------------------------------------------------------------------------
// c[i]=((x[i] ^ v[i])<<1) &MASK;
// ------------------------------------------------------------------------------
assign vls[  0+: 32] = xxv[  0+: 32]  <<  1;
assign vls[ 32+: 32] = xxv[ 32+: 32]  <<  1;
assign vls[ 64+: 32] = xxv[ 64+: 32]  <<  1;
assign vls[ 96+: 32] = xxv[ 96+: 32]  <<  1;
assign vls[128+: 32] = xxv[128+: 32]  <<  1;
assign vls[160+: 32] = xxv[160+: 32]  <<  1;


// ------------------------------------------------------------------------------
// Connect to output
// ------------------------------------------------------------------------------
assign o_c[  0+:192] = vls[  0+:192];


// ------------------------------------------------------------------------------
// Connect to output
// ------------------------------------------------------------------------------
assign o_s[  0+:192] = sd[  0+:192];

endmodule
