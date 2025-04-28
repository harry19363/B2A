`timescale 1ns / 100ps

/*
For simulation of module FullXOR, 
only localparams incluing K_WIDTH, N_SHARES, and instance of FullXOR_n need be modified accordingly
*/
module tb_FullXOR();

localparam K_WIDTH = 32;
localparam N_SHARES = 5;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam LOG_K = $clog2(N_SHARES+1) - 1;
localparam LAYERS = $clog2(N_SHARES);
localparam RANDNUM = (N_SHARES==1) ? 0 : LOG_K * 2**(LOG_K-1) + N_SHARES - 2**LOG_K;

logic clk, rst_n, ena, dvld, ovld;
logic [RANDNUM*K_WIDTH-1 : 0] rnd;
logic [MASKWIDTH-1 : 0] i_x;
logic [K_WIDTH-1 : 0] o_z;

logic [K_WIDTH-1 : 0] x_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] z_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] z_ref_reg;
logic [K_WIDTH-1 : 0] z_ref_t;
logic [K_WIDTH-1 : 0] z_ref;
logic [K_WIDTH-1 : 0] z_result;

logic correct;

integer i;

always@(*)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		i_x[i*K_WIDTH +: K_WIDTH] = x_probe[i];
		z_probe[i] = o_z[i*K_WIDTH +: K_WIDTH];
	end
end

always@(*)
begin
	z_ref_t = 'b0;
	for(i = 0; i < N_SHARES; i = i + 1) begin
		z_ref_t = z_ref_t ^ x_probe[i];
	end
end

always@(posedge clk, negedge rst_n)
begin
	z_ref_reg <= rst_n ? z_ref_t : 'b0;
end

assign z_ref = z_ref_reg;

assign z_result = o_z;

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	ena = 1'b0;
	dvld = 1'b0;
	#10 
	rst_n = 1'b1;
	ena = 1'b1;
	dvld = 1'b1;
end

always #5 clk = ~clk;

always @(negedge clk)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		x_probe[i] <= $urandom;
	end
	for(i = 0; i < RANDNUM; i = i + 1) begin
		rnd[i*K_WIDTH +: K_WIDTH] <= $urandom;
	end
end

assign correct = ovld ? (z_ref == z_result) : 1'b0;

FullXOR_n5 #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) FULLXOR(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd),
	.i_x(i_x),
	.o_z(o_z),
	.ovld(ovld)
	);

endmodule