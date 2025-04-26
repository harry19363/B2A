`timescale 1ns / 100ps

module SecA2B_n8 #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 8,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	// KSA + CSA
	parameter RANDNUM = 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1) + 148
)(
	input wire clk,
	input wire rst_n,
	input wire dvld,
	input wire ena,
	input wire [RANDNUM * K_WIDTH - 1 : 0] rnd,
	input wire [MASKWIDTH - 1 : 0] i_a,
	output wire [MASKWIDTH - 1 : 0] o_z,
	output wire ovld
);

localparam DELAY_AND = 1;
localparam DELAY_CSA = 4 * DELAY_AND;
localparam DELAY_KSA = ($clog2(K_WIDTH-1) + 1) * DELAY_AND;

// reg
wire [K_WIDTH - 1 : 0] a3_reg;
wire [K_WIDTH - 1 : 0] a7_reg;
wire [4 * K_WIDTH - 1 : 0] c3_reg;

// wire
wire [3*K_WIDTH - 1 : 0] tmp0 [0 : 2];
wire [3*K_WIDTH - 1 : 0] tmp1 [0 : 2];
wire [4*K_WIDTH - 1 : 0] tmp2 [0 : 2];
wire [4*K_WIDTH - 1 : 0] tmp3 [0 : 2];
wire [8*K_WIDTH - 1 : 0] tmp4 [0 : 2];
wire [8*K_WIDTH - 1 : 0] tmp5 [0 : 2];
wire [3*K_WIDTH - 1 : 0] s0, c0;
wire [3*K_WIDTH - 1 : 0] s1, c1;
wire [4*K_WIDTH - 1 : 0] s2, c2;
wire [4*K_WIDTH - 1 : 0] s3, c3;
wire [8*K_WIDTH - 1 : 0] s4, c4;
wire [8*K_WIDTH - 1 : 0] s5, c5;
wire vld_CSA[0 : 5];
wire vld_KSA;

// tmp0, tmp1
assign tmp0[0][0 * K_WIDTH +: K_WIDTH] = i_a[0 * K_WIDTH +: K_WIDTH];
assign tmp0[0][1 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[0][2 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp0[1][0 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[1][1 * K_WIDTH +: K_WIDTH] = i_a[1 * K_WIDTH +: K_WIDTH];
assign tmp0[1][2 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp0[2][0 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[2][1 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[2][2 * K_WIDTH +: K_WIDTH] = i_a[2 * K_WIDTH +: K_WIDTH];

assign tmp1[0][0 * K_WIDTH +: K_WIDTH] = i_a[4 * K_WIDTH +: K_WIDTH];
assign tmp1[0][1 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp1[0][2 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp1[1][0 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp1[1][1 * K_WIDTH +: K_WIDTH] = i_a[5 * K_WIDTH +: K_WIDTH];
assign tmp1[1][2 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp1[2][0 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp1[2][1 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp1[2][2 * K_WIDTH +: K_WIDTH] = i_a[6 * K_WIDTH +: K_WIDTH];

// a3_reg
lix_reg #(
	.W(K_WIDTH)
	) u0_reg(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(dvld),
	.i_en(ena),
	.i_x(i_a[3 * K_WIDTH +: K_WIDTH]),
	.o_z(a3_reg)
	);

// a7_reg
lix_reg #(
	.W(K_WIDTH)
	) u1_reg(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(dvld),
	.i_en(ena),
	.i_x(i_a[7 * K_WIDTH +: K_WIDTH]),
	.o_z(a7_reg)
	);

SecCSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(3)
	) SECCSA0(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd[0 +: 6 * K_WIDTH]),
	.x(tmp0[0]),
	.y(tmp0[1]),
	.cin(tmp0[2]),
	.s(s0),
	.cout(c0),
	.ovld(vld_CSA[0])
	);

SecCSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(3)
	) SECCSA1(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd[6 * K_WIDTH +: 6 * K_WIDTH]),
	.x(tmp1[0]),
	.y(tmp1[1]),
	.cin(tmp1[2]),
	.s(s1),
	.cout(c1),
	.ovld(vld_CSA[1])
	);

// tmp2, tmp3
assign tmp2[0][0 * K_WIDTH +: 3 * K_WIDTH] = s0;
assign tmp2[0][3 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp2[1][0 * K_WIDTH +: 3 * K_WIDTH] = c0;
assign tmp2[1][3 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp2[2][0 * K_WIDTH +: 3 * K_WIDTH] = 'b0;
assign tmp2[2][3 * K_WIDTH +: K_WIDTH] = a3_reg;

assign tmp3[0][0 * K_WIDTH +: 3 * K_WIDTH] = s1;
assign tmp3[0][3 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp3[1][0 * K_WIDTH +: 3 * K_WIDTH] = c1;
assign tmp3[1][3 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp3[2][0 * K_WIDTH +: 3 * K_WIDTH] = 'b0;
assign tmp3[2][3 * K_WIDTH +: K_WIDTH] = a7_reg;

SecCSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(4)
	) SECCSA2(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld_CSA[0]),
	.ena(ena),
	.rnd(rnd[12 * K_WIDTH +: 12 * K_WIDTH]),
	.x(tmp2[0]),
	.y(tmp2[1]),
	.cin(tmp2[2]),
	.s(s2),
	.cout(c2),
	.ovld(vld_CSA[2])
	);
	
SecCSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(4)
	) SECCSA3(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld_CSA[1]),
	.ena(ena),
	.rnd(rnd[24 * K_WIDTH +: 12 * K_WIDTH]),
	.x(tmp3[0]),
	.y(tmp3[1]),
	.cin(tmp3[2]),
	.s(s3),
	.cout(c3),
	.ovld(vld_CSA[3])
	);

// tmp4
assign tmp4[0][0 * K_WIDTH +: 4 * K_WIDTH] = s2;
assign tmp4[0][4 * K_WIDTH +: 4 * K_WIDTH] = 'b0;

assign tmp4[1][0 * K_WIDTH +: 4 * K_WIDTH] = c2;
assign tmp4[1][4 * K_WIDTH +: 4 * K_WIDTH] = 'b0;

assign tmp4[2][0 * K_WIDTH +: 4 * K_WIDTH] = 'b0;
assign tmp4[2][4 * K_WIDTH +: 4 * K_WIDTH] = s3;

lix_reg #(
	.W(4 * K_WIDTH)
	) u2_reg(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(vld_CSA[3]),
	.i_en(ena),
	.i_x(c3),
	.o_z(c3_reg)
	);
	
SecCSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(8)
	) SECCSA4(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld_CSA[2] & vld_CSA[3]),
	.ena(ena),
	.rnd(rnd[36 * K_WIDTH +: 56 * K_WIDTH]),
	.x(tmp4[0]),
	.y(tmp4[1]),
	.cin(tmp4[2]),
	.s(s4),
	.cout(c4),
	.ovld(vld_CSA[4])
	);
	
// tmp5
assign tmp5[0][0 * K_WIDTH +: 8 * K_WIDTH] = s4;

assign tmp5[1][0 * K_WIDTH +: 8 * K_WIDTH] = c4;

assign tmp5[2][0 * K_WIDTH +: 4 * K_WIDTH] = 'b0;
assign tmp5[2][4 * K_WIDTH +: 4 * K_WIDTH] = c3_reg;
	
SecCSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(8)
	) SECCSA5(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld_CSA[4]),
	.ena(ena),
	.rnd(rnd[92 * K_WIDTH +: 56 * K_WIDTH]),
	.x(tmp5[0]),
	.y(tmp5[1]),
	.cin(tmp5[2]),
	.s(s5),
	.cout(c5),
	.ovld(vld_CSA[5])
	);

SecKSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECKSA0(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld_CSA[5]),
	.ena(ena),
	.rnd(rnd[148 * K_WIDTH +: 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1) * K_WIDTH]),
	.x(s5),
	.y(c5),
	.z(o_z),
	.ovld(vld_KSA)
	);
assign ovld = vld_KSA;

endmodule