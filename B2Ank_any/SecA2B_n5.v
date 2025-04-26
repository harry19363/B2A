`timescale 1ns / 100ps

module SecA2B_n5 #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 5,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	// KSA + CSA
	parameter RANDNUM = 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1) + 38
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
localparam DELAY_CSA = 3 * DELAY_AND;
localparam DELAY_KSA = ($clog2(K_WIDTH-1) + 1) * DELAY_AND;

// reg
wire [K_WIDTH - 1 : 0] a3_reg;
wire [K_WIDTH - 1 : 0] a4_reg;

// wire
wire [3*K_WIDTH - 1 : 0] tmp0 [0 : 2];
wire [4*K_WIDTH - 1 : 0] tmp1 [0 : 2];
wire [5*K_WIDTH - 1 : 0] tmp2 [0 : 2];
wire [3*K_WIDTH - 1 : 0] s0, c0;
wire [4*K_WIDTH - 1 : 0] s1, c1;
wire [5*K_WIDTH - 1 : 0] s2, c2;
wire vld_CSA0, vld_CSA1, vld_CSA2;
wire vld_KSA;

assign tmp0[0][0 * K_WIDTH +: K_WIDTH] = i_a[0 * K_WIDTH +: K_WIDTH];
assign tmp0[0][1 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[0][2 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp0[1][0 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[1][1 * K_WIDTH +: K_WIDTH] = i_a[1 * K_WIDTH +: K_WIDTH];
assign tmp0[1][2 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp0[2][0 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[2][1 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[2][2 * K_WIDTH +: K_WIDTH] = i_a[2 * K_WIDTH +: K_WIDTH];

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
	
// a4_reg
lix_shr0 #(
	.W(K_WIDTH),
	.N(2)
	) u1_shr0(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(dvld),
	.i_en(ena),
	.i_x(i_a[4 * K_WIDTH +: K_WIDTH]),
	.o_z(a4_reg)
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
	.ovld(vld_CSA0)
	);

// tmp1
assign tmp1[0][0 * K_WIDTH +: 3 * K_WIDTH] = s0;
assign tmp1[0][3 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp1[1][0 * K_WIDTH +: 3 * K_WIDTH] = c0;
assign tmp1[1][3 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp1[2][0 * K_WIDTH +: 3 * K_WIDTH] = 'b0;
assign tmp1[2][3 * K_WIDTH +: K_WIDTH] = a3_reg;

SecCSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(4)
	) SECCSA1(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld_CSA0),
	.ena(ena),
	.rnd(rnd[6 * K_WIDTH +: 12 * K_WIDTH]),
	.x(tmp1[0]),
	.y(tmp1[1]),
	.cin(tmp1[2]),
	.s(s1),
	.cout(c1),
	.ovld(vld_CSA1)
	);

// tmp2
assign tmp2[0][0 * K_WIDTH +: 4 * K_WIDTH] = s1;
assign tmp2[0][4 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp2[1][0 * K_WIDTH +: 4 * K_WIDTH] = c1;
assign tmp2[1][4 * K_WIDTH +: K_WIDTH] = 'b0;

assign tmp2[2][0 * K_WIDTH +: 4 * K_WIDTH] = 'b0;
assign tmp2[2][4 * K_WIDTH +: K_WIDTH] = a4_reg;
	
SecCSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(5)
	) SECCSA2(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld_CSA1),
	.ena(ena),
	.rnd(rnd[18 * K_WIDTH +: 20 * K_WIDTH]),
	.x(tmp2[0]),
	.y(tmp2[1]),
	.cin(tmp2[2]),
	.s(s2),
	.cout(c2),
	.ovld(vld_CSA2)
	);

SecKSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECKSA0(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld_CSA2),
	.ena(ena),
	.rnd(rnd[38 * K_WIDTH +: 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1) * K_WIDTH]),
	.x(s2),
	.y(c2),
	.z(o_z),
	.ovld(vld_KSA)
	);
assign ovld = vld_KSA;

endmodule