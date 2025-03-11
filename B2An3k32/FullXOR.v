`timescale 1ns / 1ps

(* DONT_TOUCH = "yes" *)
module FullXOR #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 3,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	parameter LOG_K = $clog2(N_SHARES+1) - 1,
	parameter LAYERS = $clog2(N_SHARES),
	parameter RANDNUM = (N_SHARES==1) ? 0 : LOG_K * 2**(LOG_K-1) + N_SHARES - 2**LOG_K
	)(
	input clk_i,
	input rst_ni,
	input i_dvld,
	input i_rvld,
	input [K_WIDTH*RANDNUM-1:0] i_n,
	input [MASKWIDTH-1:0] i_x,
	output [K_WIDTH-1:0] o_z,
	output o_dvld
	);

wire [MASKWIDTH-1:0] x_r[0:LAYERS-1];  // for register i_x
wire [K_WIDTH*RANDNUM-1:0] n_r;  // for register i_n
wire dvld_r[0:LAYERS];  // for layer-level dvld

wire [MASKWIDTH-1:0] xxn [0:LAYERS-1];  // x XOR n

wire [K_WIDTH-1:0] tmp;  // for final XOR result

assign dvld_r[0] = i_dvld;
assign o_dvld = dvld_r[LAYERS];

// dvld
genvar i;
generate
	for(i = 0; i < LAYERS; i = i+1) begin
		lix_reg #(
			.W(1)
			) u0_lix_reg(
			.clk_i(clk_i),
			.rst_ni(rst_ni),
			.i_vld(1'b1),
			.i_en(i_rvld),
			.i_x(dvld_r[i]),
			.o_z(dvld_r[i+1])
			);
	end
endgenerate
// n
generate
	for(i = 0; i < RANDNUM; i = i+1) begin
		lix_reg #(
			.W(K_WIDTH)
			) u1_lix_reg(
			.clk_i(clk_i),
			.rst_ni(rst_ni),
			.i_vld(i_dvld),
			.i_en(i_rvld),
			.i_x(i_n[i*K_WIDTH +: K_WIDTH]),
			.o_z(n_r[i*K_WIDTH +: K_WIDTH])
			);
	end
endgenerate

// x, for N = 3 temporarily
assign xxn[0][0 +: K_WIDTH] = i_x[0 +: K_WIDTH];

lix_xor #(
	.W(K_WIDTH)
	) u2_lix_xor(
	.i_x(i_x[K_WIDTH +: K_WIDTH]),
	.i_y(i_n[0 +: K_WIDTH]),
	.o_z(xxn[0][K_WIDTH +: K_WIDTH])
	);
	
lix_xor #(
	.W(K_WIDTH)
	) u3_lix_xor(
	.i_x(i_x[2*K_WIDTH +: K_WIDTH]),
	.i_y(i_n[0 +: K_WIDTH]),
	.o_z(xxn[0][2*K_WIDTH +: K_WIDTH])
	);

generate
	for(i = 0; i < N_SHARES; i = i+1) begin
		lix_reg #(
			.W(K_WIDTH)
			) u4_lix_reg(
			.clk_i(clk_i),
			.rst_ni(rst_ni),
			.i_vld(i_dvld),
			.i_en(i_rvld),
			.i_x(xxn[0][i*K_WIDTH +: K_WIDTH]),
			.o_z(x_r[0][i*K_WIDTH +: K_WIDTH])
			);
	end
endgenerate

assign xxn[1][2*K_WIDTH +: K_WIDTH] = x_r[0][2*K_WIDTH +: K_WIDTH];

lix_xor #(
	.W(K_WIDTH)
	) u5_lix_xor(
	.i_x(x_r[0][0 +: K_WIDTH]),
	.i_y(n_r[K_WIDTH +: K_WIDTH]),
	.o_z(xxn[1][0 +: K_WIDTH])
	);

lix_xor #(
	.W(K_WIDTH)
	) u6_lix_xor(
	.i_x(x_r[0][K_WIDTH +: K_WIDTH]),
	.i_y(n_r[K_WIDTH +: K_WIDTH]),
	.o_z(xxn[1][K_WIDTH +: K_WIDTH])
	);
	
generate
	for(i = 0; i < N_SHARES; i = i+1) begin
		lix_reg #(
			.W(K_WIDTH)
			) u7_lix_reg(
			.clk_i(clk_i),
			.rst_ni(rst_ni),
			.i_vld(i_dvld),
			.i_en(i_rvld),
			.i_x(xxn[1][i*K_WIDTH +: K_WIDTH]),
			.o_z(x_r[1][i*K_WIDTH +: K_WIDTH])
			);
	end
endgenerate

lix_xor #(
	.W(K_WIDTH)
	) u8_lix_xor(
	.i_x(x_r[1][0 +: K_WIDTH]),
	.i_y(x_r[1][K_WIDTH +: K_WIDTH]),
	.o_z(tmp)
	);

lix_xor #(
	.W(K_WIDTH)
	) u9_lix_xor(
	.i_x(tmp),
	.i_y(x_r[1][2*K_WIDTH +: K_WIDTH]),
	.o_z(o_z)
	);

endmodule
