`timescale 1 ns / 1 ps


module SecB2A #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 8,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	// A2B: CSA=(n-2)*SecAnd, KSA=2log(k-1)*SecAnd; B2A: KSA=2log(k-1)*SecAnd, FullXOR=, INIT=(n-1)
	parameter LOG_K = $clog2(N_SHARES+1) - 1,
	parameter RAND_INIT = N_SHARES - 1,
	parameter RAND_CSA = 83,
	parameter RAND_KSA = 2*$clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1)/2,
	parameter RAND_A2B = RAND_CSA + RAND_KSA,
	parameter RAND_FXOR = (N_SHARES==1) ? 0 : LOG_K * 2**(LOG_K-1) + N_SHARES - 2**LOG_K,
	parameter RANDNUM = RAND_INIT + RAND_A2B + RAND_KSA + RAND_FXOR
	)(
	input wire clk,
	input wire rst_n,
	input wire dvld,
	input wire ena,
	input wire [K_WIDTH * RANDNUM - 1:0] rnd,  // fresh randomness
	input wire [MASKWIDTH-1:0] i_b,  // input boolean masking
	output wire [MASKWIDTH-1:0] o_a,  // output arithmetic masking
	output wire ovld
);

localparam DELAY_AND = 2;
localparam DELAY_CSA = 4 * DELAY_AND;
localparam DELAY_KSA = ($clog2(K_WIDTH-1) + 1) * DELAY_AND;

wire [MASKWIDTH - K_WIDTH - 1 : 0] A;
wire [MASKWIDTH - 1 : 0] An;
wire [MASKWIDTH - 1 : 0] y;
wire [MASKWIDTH - 1 : 0] z;
wire vld_A2B, vld_KSA, vld_FXOR;
wire [MASKWIDTH - 1 : 0] b_r;  // delay i_b
wire [MASKWIDTH - K_WIDTH - 1 : 0] A_r;  // delay A
wire [K_WIDTH - 1 : 0] A_t;  // last share of A


// A, An init
genvar i;
generate 
	for(i = 0; i < N_SHARES-1; i = i + 1) begin
		assign A[i*K_WIDTH +: K_WIDTH] = rnd[i*K_WIDTH +: K_WIDTH];
	end
endgenerate

generate
	for(i = 0; i < N_SHARES-1; i = i + 1) begin
		assign An[i*K_WIDTH +: K_WIDTH] = -A[i*K_WIDTH +: K_WIDTH];
	end
endgenerate

assign An[(N_SHARES-1)*K_WIDTH +: K_WIDTH] = 'b0;
	
// b_r
generate
	for(i = 0; i < N_SHARES; i = i+1)
		lix_shr0 #(
			.W(K_WIDTH),
			.N(DELAY_CSA + DELAY_KSA)  // 
			) u2_lix_shr0(
			.clk_i(clk),
			.rst_ni(rst_n),
			.i_vld(dvld),
			.i_en(ena),
			.i_x(i_b[i*K_WIDTH +: K_WIDTH]),
			.o_z(b_r[i*K_WIDTH +: K_WIDTH])
			);
endgenerate

// A_r
generate
	for(i = 0; i < N_SHARES - 1; i = i+1)
		lix_shr0 #(
			.W(K_WIDTH),
			.N(DELAY_CSA + 2 * DELAY_KSA + 1)  // 
			) u6_lix_shr0(
			.clk_i(clk),
			.rst_ni(rst_n),
			.i_vld(dvld),
			.i_en(ena),
			.i_x(A[i*K_WIDTH +: K_WIDTH]),
			.o_z(A_r[i*K_WIDTH +: K_WIDTH])
			);
endgenerate
	
// A2B
SecA2B_n8k32_1 SECA2B0(
    .clk_i(clk),
    .rst_ni(rst_n),
    .i_dvld(dvld),
    .i_rvld(ena),
    .i_n(rnd[RAND_INIT*K_WIDTH +: RAND_A2B*K_WIDTH]),
    .i_a(An),
    .o_z(y),
    .o_dvld(vld_A2B));

// KSA
SecKSA_n8k32_1 SECKSA0(
    .clk_i(clk),
    .rst_ni(rst_n),
    .i_dvld(vld_A2B),
    .i_rvld(ena),
    .i_n(rnd[(RAND_INIT + RAND_A2B)*K_WIDTH +: RAND_KSA*K_WIDTH]),
    .i_x(b_r),
    .i_y(y),
    .o_z(z),
    .o_dvld(vld_KSA));

// FullXOR
FullXOR_n8 #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) FXOR(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld_KSA),
	.ena(ena),
	.rnd(rnd[(RAND_INIT + RAND_A2B + RAND_KSA)*K_WIDTH +: RAND_FXOR*K_WIDTH]),
	.i_x(z),
	.o_z(A_t),
	.ovld(vld_FXOR)
	);
	
assign o_a = {A_t, A_r};
assign ovld = vld_FXOR;

endmodule
