`timescale 1ns / 100ps

module KSA_gp_gen #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 3,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	parameter RANDNUM = 2 * N_SHARES * (N_SHARES-1),
	parameter  SHIFT = 1,
    parameter  POW = 2**SHIFT
)(
	input wire clk,
    input wire rst_n,
    input wire dvld,
    input wire ena,
    input wire [K_WIDTH * RANDNUM - 1:0] rnd,
    input wire [MASKWIDTH-1:0] i_p,
    input wire [MASKWIDTH-1:0] i_g,
    output wire [MASKWIDTH-1:0] o_p,
    output wire [MASKWIDTH-1:0] o_g,
    output wire ovld
);

// reg
wire [MASKWIDTH-1 : 0] g_reg;

// wire
wire [MASKWIDTH-1 : 0] p_t;
wire [MASKWIDTH-1 : 0] g_t;
wire [MASKWIDTH-1 : 0] tmp1;
wire vld1, vld2;

genvar i;
generate 
	for(i = 0; i < N_SHARES; i = i + 1) begin
		assign p_t[i*K_WIDTH +: K_WIDTH] = i_p[i*K_WIDTH +: K_WIDTH] << POW;
		assign g_t[i*K_WIDTH +: K_WIDTH] = i_g[i*K_WIDTH +: K_WIDTH] << POW;
	end
endgenerate

// always @(posedge clk)
// begin
	// if(ena && dvld) begin
		// g_reg <= i_g;
	// end
	// else begin
		// g_reg <= g_reg;
	// end
// end
lix_reg #(
	.W(MASKWIDTH)
	) u0_reg(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(dvld),
	.i_en(ena),
	.i_x(i_g),
	.o_z(g_reg)
	);

// o_g
SecAND #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECAND0(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd[0 +: N_SHARES * (N_SHARES-1) * K_WIDTH]),
	.x(i_p),
	.y(g_t),
	.z(tmp1),
	.ovld(vld1)
	);
	
// assign o_g = g_reg ^ tmp1;
lix_xor #(
	.W(MASKWIDTH)
	) u1_xor(
	.i_x(g_reg),
	.i_y(tmp1),
	.o_z(o_g)
	);

// o_p
SecAND #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECAND1(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd[N_SHARES * (N_SHARES-1) * K_WIDTH +: N_SHARES * (N_SHARES-1) * K_WIDTH]),
	.x(i_p),
	.y(p_t),
	.z(o_p),
	.ovld(vld2)
	);

// ovld
assign ovld = vld1 & vld2;

endmodule