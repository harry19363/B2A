`timescale 1ns / 100ps

module SecA2B_n3 #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 3,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	// CSA + KSA
	parameter RANDNUM = N_SHARES*(N_SHARES-1) + 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1)
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
localparam DELAY_CSA = DELAY_AND;
localparam DELAY_KSA = ($clog2(K_WIDTH-1) + 1) * DELAY_AND;

// wire
wire [MASKWIDTH - 1 : 0] tmp0 [0 : N_SHARES - 1];
wire [MASKWIDTH - 1 : 0] s, c;
wire vld_CSA;
wire vld_KSA;

assign tmp0[0][1 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[0][2 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[1][0 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[1][2 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[2][0 * K_WIDTH +: K_WIDTH] = 'b0;
assign tmp0[2][1 * K_WIDTH +: K_WIDTH] = 'b0;

genvar i;
generate 
	for(i = 0; i < N_SHARES; i = i + 1) begin
		assign tmp0[i][i*K_WIDTH +: K_WIDTH] = i_a[i*K_WIDTH +: K_WIDTH];
	end
endgenerate

SecCSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECCSA0(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd[0 +: N_SHARES*(N_SHARES-1) * K_WIDTH]),
	.x(tmp0[0]),
	.y(tmp0[1]),
	.cin(tmp0[2]),
	.s(s),
	.cout(c),
	.ovld(vld_CSA)
	);

SecKSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECKSA0(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(vld_CSA),
	.ena(ena),
	.rnd(rnd[N_SHARES*(N_SHARES-1) * K_WIDTH +: 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1) * K_WIDTH]),
	.x(s),
	.y(c),
	.z(o_z),
	.ovld(ovld)
	);

endmodule