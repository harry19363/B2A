`timescale 1ns / 1ps

module SecA2Bn8 #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 8
	)(
    input wire clk_i,
    input wire rst_ni,
    input wire i_dvld,
    input wire i_rvld,
    // input wire [11615:0] i_n,  // 11328, 13376
	input wire [11327:0] i_n,
    input wire [255:0] i_a,
    output wire [255:0] o_z,
    output wire o_dvld
	);

wire [255:0] s;
wire [255:0] c;
wire vld_csa;

wire [127:0] s0_tmp, s1_tmp;
wire [127:0] c0_tmp, c1_tmp;
wire [255:0] s2_tmp;
wire [255:0] c2_tmp;
wire vld0, vld1, vld2, vld3;

wire [255:0] x0_tmp, x1_tmp;
wire [255:0] y0_tmp, y1_tmp;
wire [255:0] cin0_tmp, cin1_tmp;


// CSA
SecCSATree_n4k32 CSA0(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .i_dvld(i_dvld),
    .i_rvld(i_rvld),
    .i_n(i_n[0 +: 288]),
    .i_x(i_a[0 +: 128]),
    .o_s(s0_tmp),
    .o_c(c0_tmp),
    .o_dvld(vld0)
	);

SecCSATree_n4k32 CSA1(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .i_dvld(i_dvld),
    .i_rvld(i_rvld),
    .i_n(i_n[288 +: 288]),
    .i_x(i_a[128 +: 128]),
    .o_s(s1_tmp),
    .o_c(c1_tmp),
    .o_dvld(vld1)
	);
	
assign x0_tmp[0 +: 128] = s0_tmp;
assign x0_tmp[128 +: 128] = 'b0;
assign y0_tmp[0 +: 128] = c0_tmp;
assign y0_tmp[128 +: 128] = 'b0;
assign cin0_tmp[0 +: 128] = 'b0;
assign cin0_tmp[128 +: 128] = s1_tmp;

SecCSA_n8k32 CSA2(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .i_dvld(vld0 & vld1),
    .i_rvld(i_rvld),
    .i_n(i_n[576 +: 896]),
    .i_x(x0_tmp),
	.i_y(y0_tmp),
	.i_c_in(cin0_tmp),
    .o_s(s2_tmp),
    .o_c(c2_tmp),
    .o_dvld(vld2)
	);

assign x1_tmp = s2_tmp;
assign y1_tmp = c2_tmp;
assign cin1_tmp[0 +: 128] = 'b0;
// assign cin1_tmp[128 +: 128] = c1_tmp;

lix_shr0
  #(.W (128),
    .N (2))
  u0_lix_shr0
   (.clk_i  (clk_i),
    .rst_ni (rst_ni),
    .i_vld  (vld0 & vld1),
    .i_en   (i_rvld),
    .i_x    (c1_tmp),
    .o_z    (cin1_tmp[128 +: 128]));

SecCSA_n8k32 CSA3(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .i_dvld(vld2),
    .i_rvld(i_rvld),
    .i_n(i_n[1472 +: 896]),
    .i_x(x1_tmp),
	.i_y(y1_tmp),
	.i_c_in(cin1_tmp),
    .o_s(s),
    .o_c(c),
    .o_dvld(vld3)
	);

assign vld_csa = vld3;

// KSA
SecKSA_n8k32_1 KSA0(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .i_dvld(vld_csa),
    .i_rvld(i_rvld),
    .i_n(i_n[2368 +: 8960]),
    .i_x(s),
    .i_y(c),
    .o_z(o_z),
    .o_dvld(o_dvld)
	);

endmodule
