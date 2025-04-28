`timescale 1ns / 1ps

(* DONT_TOUCH = "yes" *)
module FullXOR_n3 #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 3,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	parameter LOG_K = $clog2(N_SHARES+1) - 1,
	parameter LAYERS = $clog2(N_SHARES),
	parameter RANDNUM = (N_SHARES==1) ? 0 : LOG_K * 2**(LOG_K-1) + N_SHARES - 2**LOG_K
	)(
	input wire clk,
	input wire rst_n,
	input wire dvld,
	input wire ena,
	input wire [K_WIDTH*RANDNUM-1:0] rnd,
	input wire [MASKWIDTH-1:0] i_x,
	output wire [K_WIDTH-1:0] o_z,
	output wire ovld
	);

wire [MASKWIDTH-1:0] x_r;  // for register xxn

wire [MASKWIDTH-1:0] xxn [0:LAYERS-1];  // x XOR n

wire [K_WIDTH-1:0] tmp[0 : N_SHARES - 2];  // for final XOR result

// x, for N = 3
genvar i;

// layer0
lix_xor #(
	.W(K_WIDTH)
	) u0_xor(
	.i_x(i_x[1*K_WIDTH +: K_WIDTH]),
	.i_y(rnd[0*K_WIDTH +: K_WIDTH]),
	.o_z(xxn[0][1*K_WIDTH +: K_WIDTH])
	);
lix_xor #(
	.W(K_WIDTH)
	) u1_xor(
	.i_x(i_x[2*K_WIDTH +: K_WIDTH]),
	.i_y(rnd[0*K_WIDTH +: K_WIDTH]),
	.o_z(xxn[0][2*K_WIDTH +: K_WIDTH])
	);
assign xxn[0][0*K_WIDTH +: K_WIDTH] = i_x[0*K_WIDTH +: K_WIDTH];

// layer1
lix_xor #(
	.W(K_WIDTH)
	) u2_xor(
	.i_x(xxn[0][0*K_WIDTH +: K_WIDTH]),
	.i_y(rnd[1*K_WIDTH +: K_WIDTH]),
	.o_z(xxn[1][0*K_WIDTH +: K_WIDTH])
	);
lix_xor #(
	.W(K_WIDTH)
	) u3_xor(
	.i_x(xxn[0][1*K_WIDTH +: K_WIDTH]),
	.i_y(rnd[1*K_WIDTH +: K_WIDTH]),
	.o_z(xxn[1][1*K_WIDTH +: K_WIDTH])
	);
assign xxn[1][2*K_WIDTH +: K_WIDTH] = xxn[0][2*K_WIDTH +: K_WIDTH];

// register
generate
	for(i = 0; i < N_SHARES; i = i+1) begin
		lix_reg #(
			.W(K_WIDTH)
			) u8_reg(
			.clk_i(clk),
			.rst_ni(rst_n),
			.i_vld(dvld),
			.i_en(ena),
			.i_x(xxn[LAYERS-1][i*K_WIDTH +: K_WIDTH]),
			.o_z(x_r[i*K_WIDTH +: K_WIDTH])
			);
	end
endgenerate

// XOR

lix_xor #(
	.W(K_WIDTH)
	) u9_xor(
	.i_x(x_r[0*K_WIDTH +: K_WIDTH]),
	.i_y(x_r[1*K_WIDTH +: K_WIDTH]),
	.o_z(tmp[0])
	);

generate
	for(i = 0; i < N_SHARES-2; i = i + 1) begin
		lix_xor #(
			.W(K_WIDTH)
			) u10_xor(
			.i_x(tmp[i]),
			.i_y(x_r[(i+2)*K_WIDTH +: K_WIDTH]),
			.o_z(tmp[i+1])
			);
	end
endgenerate

assign o_z = tmp[N_SHARES-2];

// dvld
lix_reg #(
	.W(1)
	) u11_reg(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(1'b1),
	.i_en(ena),
	.i_x(dvld),
	.o_z(ovld)
	);

endmodule
