`timescale 1ns / 100ps

module SecKSA #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 3,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	parameter RANDNUM = 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1)
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

// reg
wire [MASKWIDTH-1 : 0] p0_reg;  // x ^ y reg
wire [MASKWIDTH-1 : 0] g1_reg;  // final g reg
wire [MASKWIDTH-1 : 0] xy_d;  // x ^ y delay

// wire
wire [MASKWIDTH-1 : 0] p0;
wire [MASKWIDTH-1 : 0] p[0 : $clog2(K_WIDTH-1) - 1];
wire [MASKWIDTH-1 : 0] g[0 : $clog2(K_WIDTH-1) - 1];
wire vld[0 : $clog2(K_WIDTH-1) - 1];
wire [MASKWIDTH-1 : 0] tmp0;  // g << (2log(k-1)-1)
wire [MASKWIDTH-1 : 0] tmp1;  // SecAND(p, g_t)
wire [MASKWIDTH-1 : 0] tmp2;  // p1_reg ^ tmp0
wire [MASKWIDTH-1 : 0] tmp3;  // tmp1 << 1


// p0, g0
lix_xor #(
	.W(MASKWIDTH)
	) u0_xor(
	.i_x(x),
	.i_y(y),
	.o_z(p0)
	);
lix_reg #(
	.W(MASKWIDTH)
	) u1_reg(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(dvld),
	.i_en(ena),
	.i_x(p0),
	.o_z(p0_reg)
	);

assign p[0] = p0_reg;

// xy_d
lix_shr0 #(
	.W(MASKWIDTH),
	.N($clog2(K_WIDTH-1))
	) u2_shr0(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(vld[0]),
	.i_en(ena),
	.i_x(p0_reg),
	.o_z(xy_d)
	);

SecAND #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECAND0(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd[0 +: (N_SHARES*(N_SHARES-1)*K_WIDTH)]),
	.x(x),
	.y(y),
	.z(g[0]),
	.ovld(vld[0])
	);
	
genvar i;
generate 
	for(i = 0; i < $clog2(K_WIDTH-1) - 1; i = i + 1) begin
		KSA_gp_gen #(
			.K_WIDTH(K_WIDTH),
			.N_SHARES(N_SHARES),
			.SHIFT(i)
			) GPGEN(
			.clk(clk),
			.rst_n(rst_n),
			.dvld(vld[i]),
			.ena(ena),
			.rnd(rnd[(i*2+1)*N_SHARES*(N_SHARES-1)*K_WIDTH +: 2*N_SHARES*(N_SHARES-1)*K_WIDTH]),
			.i_p(p[i]),
			.i_g(g[i]),
			.o_p(p[i+1]),
			.o_g(g[i+1]),
			.ovld(vld[i+1])
			);
	end
endgenerate

// final result
lix_reg #(
	.W(MASKWIDTH)
	) u3_reg(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(vld[$clog2(K_WIDTH-1) - 1]),
	.i_en(ena),
	.i_x(g[$clog2(K_WIDTH-1) - 1]),
	.o_z(g1_reg)
	);
	
generate
	for(i = 0; i < N_SHARES; i = i + 1) begin
		assign tmp0[i*K_WIDTH +: K_WIDTH] = g[$clog2(K_WIDTH-1) - 1][i*K_WIDTH +: K_WIDTH] << (2 ** ($clog2(K_WIDTH-1) - 1));
	end
endgenerate

SecAND #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECAND1(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld[$clog2(K_WIDTH-1) - 1]),
	.ena(ena),
	.rnd(rnd[(2 * $clog2(K_WIDTH-1) - 1)*N_SHARES*(N_SHARES-1)*K_WIDTH +: N_SHARES*(N_SHARES-1)*K_WIDTH]),
	.x(p[$clog2(K_WIDTH-1) - 1]),
	.y(tmp0),
	.z(tmp1),
	.ovld(ovld)
	);

lix_xor #(
	.W(MASKWIDTH)
	) u4_xor(
	.i_x(g1_reg),
	.i_y(tmp1),
	.o_z(tmp2)
	);
	
generate
	for(i = 0; i < N_SHARES; i = i + 1) begin
		assign tmp3[i*K_WIDTH +: K_WIDTH] = tmp2[i*K_WIDTH +: K_WIDTH] << 1;
	end
endgenerate

lix_xor #(
	.W(MASKWIDTH)
	) u5_xor(
	.i_x(xy_d),
	.i_y(tmp3),
	.o_z(z)
	);

endmodule