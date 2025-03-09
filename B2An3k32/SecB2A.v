`timescale 1 ns / 1 ps


module SecB2A #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 3,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	// A2B: CSA=(n-2)*SecAnd, KSA=2log(k-1)*SecAnd; B2A: KSA=2log(k-1)*SecAnd, FullXOR=, INIT=(n-1)
	parameter LOG_K = $clog2(N_SHARES+1) - 1,
	parameter RAND_INIT = N_SHARES - 1,
	parameter RAND_A2B = (2*$clog2(K_WIDTH-1) + N_SHARES-2) * N_SHARES*(N_SHARES-1)/2,
	parameter RAND_KSA = 2*$clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1)/2,
	parameter RAND_FXOR = (N_SHARES==1) ? 0 : LOG_K * 2**(LOG_K-1) + N_SHARES - 2**LOG_K,
	parameter RANDNUM = RAND_INIT + RAND_A2B + RAND_KSA + RAND_FXOR
	)(
	input clk_i,
	input rst_ni,
	input i_dvld,
	input i_rvld,
	input [K_WIDTH * RANDNUM - 1:0] i_n,
	input [MASKWIDTH-1:0] i_b,
	output [MASKWIDTH-1:0] o_a,
	output o_dvld
);

wire [MASKWIDTH-K_WIDTH-1:0] A;
wire [MASKWIDTH-1:0] An;
wire [MASKWIDTH-1:0] y;
wire [MASKWIDTH-1:0] z;
wire dvld_init0, dvld_init1, dvld_A2B, dvld_KSA, dvld_FXOR;
wire [MASKWIDTH-1:0] b_r;  // delay i_b
wire [MASKWIDTH-1:0] A_r;  // delay A


// dvld
lix_reg #(
	.W(1)
	) u0_lix_reg(
	.clk_i(clk_i),
	.rst_ni(rst_ni),
	.i_vld(1'b1),
	.i_en(i_rvld),
	.i_x(i_dvld),
	.o_z(dvld_init0)
	);
	
lix_reg #(
	.W(1)
	) u1_lix_reg(
	.clk_i(clk_i),
	.rst_ni(rst_ni),
	.i_vld(1'b1),
	.i_en(i_rvld),
	.i_x(dvld_init0),
	.o_z(dvld_init1)
	);
	
// b_r
genvar i;
generate
	for(i = 0; i < N_SHARES; i = i+1)
		lix_shr0 #(
			.W(K_WIDTH),
			.N(16)  // 2 + 14
			) u2_lix_shr0(
			.clk_i(clk_i),
			.rst_ni(rst_ni),
			.i_vld(i_dvld),
			.i_en(i_rvld),
			.i_x(i_b[i*K_WIDTH +: K_WIDTH]),
			.o_z(b_r[i*K_WIDTH +: K_WIDTH])
			);
endgenerate

// A init
generate 
	for(i = 0; i < N_SHARES - 1; i = i+1)
		lix_reg #(
			.W(K_WIDTH)
			) u3_lix_reg(
			.clk_i(clk_i),
			.rst_ni(rst_ni),
			.i_vld(i_dvld),
			.i_en(i_rvld),
			.i_x(i_n[i*K_WIDTH +: K_WIDTH]),
			.o_z(A[i*K_WIDTH +: K_WIDTH])
			);
endgenerate

// An init
generate 
	for(i = 0; i < N_SHARES - 1; i = i+1)
		lix_reg #(
			.W(K_WIDTH)
			) u4_lix_reg(
			.clk_i(clk_i),
			.rst_ni(rst_ni),
			.i_vld(dvld_init0),
			.i_en(i_rvld),
			.i_x(~A[i*K_WIDTH +: K_WIDTH] + 1'b1),
			.o_z(An[i*K_WIDTH +: K_WIDTH])
			);
endgenerate

lix_reg #(
	.W(K_WIDTH)
	) u5_lix_reg(
	.clk_i(clk_i),
	.rst_ni(rst_ni),
	.i_vld(dvld_init0),
	.i_en(i_rvld),
	.i_x('b0),
	.o_z(An[(N_SHARES-1) * K_WIDTH +: K_WIDTH])
	);

// A_r
generate
	for(i = 0; i < N_SHARES; i = i+1)
		lix_shr0 #(
			.W(K_WIDTH),
			.N(29)  // 1 + 14 + 12 + 2
			) u6_lix_shr0(
			.clk_i(clk_i),
			.rst_ni(rst_ni),
			.i_vld(dvld_init0),
			.i_en(i_rvld),
			.i_x(A[i*K_WIDTH +: K_WIDTH]),
			.o_z(A_r[i*K_WIDTH +: K_WIDTH])
			);
endgenerate
	
// A2B
SecA2B_n3k32_1 SECA2B0(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .i_dvld(dvld_init1),
    .i_rvld(i_rvld),
    .i_n(i_n[RAND_INIT*K_WIDTH +: RAND_A2B*K_WIDTH]),
    .i_a(An),
    .o_z(y),
    .o_dvld(dvld_A2B));

// KSA
SecKSA_n3k32_1 SECKSA0(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .i_dvld(dvld_A2B),
    .i_rvld(i_rvld),
    .i_n(i_n[(RAND_INIT + RAND_A2B)*K_WIDTH +: RAND_KSA*K_WIDTH]),
    .i_x(b_r),
    .i_y(y),
    .o_z(z),
    .o_dvld(dvld_KSA));

// FullXOR
FullXOR #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) FXOR(
	.clk_i(clk_i),
	.rst_ni(rst_ni),
	.i_dvld(dvld_KSA),
	.i_rvld(i_rvld),
	.i_n(i_n[(RAND_INIT + RAND_A2B + RAND_KSA)*K_WIDTH +: RAND_FXOR*K_WIDTH]),
	.i_x(z),
	.o_z(A_r[(N_SHARES-1) * K_WIDTH +: K_WIDTH]),
	.o_dvld(dvld_FXOR)
	);
	
assign o_a = A_r;
assign o_dvld = dvld_FXOR;

endmodule
