`timescale 1ns / 1ps

module FullXOR_n5 #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 5,
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

wire [MASKWIDTH-1:0] x_r0;  // for register i_x
wire [MASKWIDTH-1:0] x_r1;  // for register xxn

wire [MASKWIDTH-1:0] xxn [0:LAYERS-1];  // x XOR n

wire [K_WIDTH-1:0] tmp[0 : N_SHARES - 2];  // for final XOR result

// x, for N = 5

// layer0
genvar i;

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
			.i_x(i_x[i*K_WIDTH +: K_WIDTH]),
			.o_z(x_r0[i*K_WIDTH +: K_WIDTH])
			);
	end
endgenerate

lix_xor #(
	.W(K_WIDTH)
	) u0_xor(
	.i_x(x_r0[0*K_WIDTH +: K_WIDTH]),
	.i_y(rnd[0*K_WIDTH +: K_WIDTH]),
	.o_z(xxn[0][0*K_WIDTH +: K_WIDTH])
	);
lix_xor #(
	.W(K_WIDTH)
	) u1_xor(
	.i_x(x_r0[1*K_WIDTH +: K_WIDTH]),
	.i_y(rnd[0*K_WIDTH +: K_WIDTH]),
	.o_z(xxn[0][1*K_WIDTH +: K_WIDTH])
	);

assign xxn[0][2*K_WIDTH +: K_WIDTH] = x_r0[2*K_WIDTH +: K_WIDTH];

lix_xor #(
	.W(K_WIDTH)
	) u2_xor(
	.i_x(x_r0[3*K_WIDTH +: K_WIDTH]),
	.i_y(rnd[1*K_WIDTH +: K_WIDTH]),
	.o_z(xxn[0][3*K_WIDTH +: K_WIDTH])
	);
lix_xor #(
	.W(K_WIDTH)
	) u3_xor(
	.i_x(x_r0[4*K_WIDTH +: K_WIDTH]),
	.i_y(rnd[1*K_WIDTH +: K_WIDTH]),
	.o_z(xxn[0][4*K_WIDTH +: K_WIDTH])
	);

// layer1
lix_xor #(
	.W(K_WIDTH)
	) u4_xor(
	.i_x(xxn[0][2*K_WIDTH +: K_WIDTH]),
	.i_y(rnd[2*K_WIDTH +: K_WIDTH]),
	.o_z(xxn[1][2*K_WIDTH +: K_WIDTH])
	);
lix_xor #(
	.W(K_WIDTH)
	) u5_xor(
	.i_x(xxn[0][3*K_WIDTH +: K_WIDTH]),
	.i_y(rnd[2*K_WIDTH +: K_WIDTH]),
	.o_z(xxn[1][3*K_WIDTH +: K_WIDTH])
	);
	
assign xxn[1][0*K_WIDTH +: K_WIDTH] = xxn[0][0*K_WIDTH +: K_WIDTH];
assign xxn[1][1*K_WIDTH +: K_WIDTH] = xxn[0][1*K_WIDTH +: K_WIDTH];
assign xxn[1][4*K_WIDTH +: K_WIDTH] = xxn[0][4*K_WIDTH +: K_WIDTH];

// layer2
generate 
	for(i = 0; i < 2; i = i + 1) begin
		lix_xor #(
			.W(K_WIDTH)
			) u6_xor(
			.i_x(xxn[1][i*K_WIDTH +: K_WIDTH]),
			.i_y(rnd[(3 + i)*K_WIDTH +: K_WIDTH]),
			.o_z(xxn[2][i*K_WIDTH +: K_WIDTH])
			);
		lix_xor #(
			.W(K_WIDTH)
			) u7_xor(
			.i_x(xxn[1][(i+2)*K_WIDTH +: K_WIDTH]),
			.i_y(rnd[(3 + i)*K_WIDTH +: K_WIDTH]),
			.o_z(xxn[2][(i+2)*K_WIDTH +: K_WIDTH])
			);
	end
endgenerate
assign xxn[2][4*K_WIDTH +: K_WIDTH] = xxn[1][4*K_WIDTH +: K_WIDTH];

// // register
// generate
	// for(i = 0; i < N_SHARES; i = i+1) begin
		// lix_reg #(
			// .W(K_WIDTH)
			// ) u8_reg(
			// .clk_i(clk),
			// .rst_ni(rst_n),
			// .i_vld(dvld),
			// .i_en(ena),
			// .i_x(xxn[LAYERS-1][i*K_WIDTH +: K_WIDTH]),
			// .o_z(x_r[i*K_WIDTH +: K_WIDTH])
			// );
	// end
// endgenerate
assign x_r1 = xxn[LAYERS-1];

// XOR

lix_xor #(
	.W(K_WIDTH)
	) u9_xor(
	.i_x(x_r1[0*K_WIDTH +: K_WIDTH]),
	.i_y(x_r1[1*K_WIDTH +: K_WIDTH]),
	.o_z(tmp[0])
	);

generate
	for(i = 0; i < N_SHARES-2; i = i + 1) begin
		lix_xor #(
			.W(K_WIDTH)
			) u10_xor(
			.i_x(tmp[i]),
			.i_y(x_r1[(i+2)*K_WIDTH +: K_WIDTH]),
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
