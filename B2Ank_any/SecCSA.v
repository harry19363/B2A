`timescale 1ns / 100ps

module SecCSA #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 3,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	parameter RANDNUM = N_SHARES*(N_SHARES-1)
)(
	input wire clk,  // clock
	input wire rst_n,  // areset on negative edge
	input wire dvld,  // data valid
	input wire ena,  // enable
	input wire [K_WIDTH * RANDNUM - 1:0] rnd,  // fresh randomness
	input wire [MASKWIDTH-1:0] x,  // input x
	input wire [MASKWIDTH-1:0] y,  // input y
	input wire [MASKWIDTH-1:0] cin,  // input cin
	output wire [MASKWIDTH-1:0] s,  // output s
	output wire [MASKWIDTH-1:0] cout,  // output cout
	output wire ovld  // output valid
);

// reg
wire [MASKWIDTH-1 : 0] x_reg;  // delay x

// wire 
wire [MASKWIDTH-1 : 0] a;  // x ^ y
wire [MASKWIDTH-1 : 0] s_t;  // x ^ y ^ cin
wire [MASKWIDTH-1 : 0] tmp0;  // x ^ cin
wire [MASKWIDTH-1 : 0] tmp1;  // SecAND(a, tmp0)
wire [MASKWIDTH-1 : 0] c_t;  // x_reg ^ tmp1

// a, s
lix_xor #(
	.W(MASKWIDTH)
	) u0_xor(
	.i_x(x),
	.i_y(y),
	.o_z(a)
	);

lix_xor #(
	.W(MASKWIDTH)
	) u1_xor(
	.i_x(cin),
	.i_y(a),
	.o_z(s_t)
	);
	
// delay x, s
lix_reg #(
	.W(MASKWIDTH)
	) u2_reg(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(dvld),
	.i_en(ena),
	.i_x(x),
	.o_z(x_reg)
	);

lix_reg #(
	.W(MASKWIDTH)
	) u3_reg(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(dvld),
	.i_en(ena),
	.i_x(s_t),
	.o_z(s)
	);

// cout
lix_xor #(
	.W(MASKWIDTH)
	) u4_xor(
	.i_x(x),
	.i_y(cin),
	.o_z(tmp0)
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
	.x(a),
	.y(tmp0),
	.z(tmp1),
	.ovld(ovld)
	);

lix_xor #(
	.W(MASKWIDTH)
	) u5_xor(
	.i_x(x_reg),
	.i_y(tmp1),
	.o_z(c_t)
	);
	
genvar i;
generate 
	for(i = 0; i < N_SHARES; i = i + 1) begin
		assign cout[i*K_WIDTH +: K_WIDTH] = c_t[i*K_WIDTH +: K_WIDTH] << 1;
	end
endgenerate

endmodule