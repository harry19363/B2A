`timescale 1ns / 100ps

/*
For simulation of module SecB2A,
only localparams including K_WIDTH, N_SHARES, RAND_CSA, DELAY_CSA need be modified accordingly
*/
module tb_SecB2A();

localparam K_WIDTH = 16;

localparam DELAY_AND = 1;
localparam DELAY_KSA = ($clog2(K_WIDTH-1) + 1) * DELAY_AND;

// N_SHARES = 8
localparam N_SHARES = 3;
// localparam N_SHARES = 8;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam LOG_K = $clog2(N_SHARES+1) - 1;
localparam RAND_INIT = N_SHARES - 1;
localparam RAND_CSA = 6;
// localparam RAND_CSA = 148;
localparam RAND_KSA = 2*$clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1);
localparam RAND_A2B = RAND_CSA + RAND_KSA;
localparam RAND_FXOR = (N_SHARES==1) ? 0 : LOG_K * 2**(LOG_K-1) + N_SHARES - 2**LOG_K;
localparam RANDNUM = RAND_INIT + RAND_A2B + RAND_KSA + RAND_FXOR;

localparam DELAY_CSA = 1 * DELAY_AND;
// localparam DELAY_CSA = 4 * DELAY_AND;

logic clk, rst_n;
logic dvld, ena;
logic [MASKWIDTH-1 : 0] i_b;
logic [MASKWIDTH-1 : 0] o_z;
logic ovld;
logic [RANDNUM*K_WIDTH-1 : 0] rnd;

SecB2A #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECB2AN8(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd),
	.i_b(i_b),
	.o_a(o_z),
	.ovld(ovld)
	);

// Code below need not be changed

logic [K_WIDTH-1 : 0] b_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] z_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] z_result;
logic [K_WIDTH-1 : 0] z_ref;
logic [K_WIDTH-1 : 0] z_ref_t;
logic [K_WIDTH-1 : 0] z_ref_reg [0 : DELAY_CSA + 2 * DELAY_KSA];

logic correct;
	
integer i;

always @(*)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		i_b[i*K_WIDTH +: K_WIDTH] = b_probe[i];
		z_probe[i] = o_z[i*K_WIDTH +: K_WIDTH];
	end
end

always @(*)
begin
	z_ref_t = 'b0;
	for(i = 0; i < N_SHARES; i = i + 1) begin
		z_ref_t = z_ref_t ^ b_probe[i];
	end
end

always @(posedge clk, negedge rst_n)
begin
	if(~rst_n) begin
		for(i = 0; i < DELAY_CSA + 2 * DELAY_KSA + 1; i = i + 1) begin
			z_ref_reg[i] <= 'b0;
		end
	end
	else begin
		z_ref_reg[0] <= z_ref_t;
		for(i = 0; i < DELAY_CSA + 2 * DELAY_KSA; i = i + 1) begin
			z_ref_reg[i+1] <= z_ref_reg[i];
		end
	end
end
assign z_ref = z_ref_reg[DELAY_CSA + 2 * DELAY_KSA];

always @(*)
begin
	z_result = 'b0;
	for(i = 0; i < N_SHARES; i = i + 1) begin
		z_result = z_result + z_probe[i];
	end
end

assign correct = ovld ? (z_ref == z_result) : 1'b0;

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	dvld = 1'b0;
	ena = 1'b0;
	rnd = 'b0;
	i_b = 'b0;
	#10
	rst_n = 1'b1;
	dvld = 1'b1;
	ena = 1'b1;
end
always #5 clk = ~clk;

always @(negedge clk)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		b_probe[i] <= $urandom;
	end
	for(i = 0; i < RANDNUM; i = i + 1) begin
		rnd[i*K_WIDTH +: K_WIDTH] <= $urandom;
	end
end

endmodule