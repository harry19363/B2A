`timescale 1ns / 100ps

module tb_SecA2B();

localparam K_WIDTH = 32;

localparam DELAY_AND = 1;
localparam DELAY_KSA = ($clog2(K_WIDTH-1) + 1) * DELAY_AND;

/*
// N_SHARES = 3
localparam N_SHARES = 3;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam RANDNUM = 6 + 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1);

localparam DELAY_CSA = DELAY_AND;

logic clk, rst_n;
logic dvld, ena;
logic [MASKWIDTH-1 : 0] i_a;
logic [MASKWIDTH-1 : 0] o_z;
logic ovld;
logic [RANDNUM*K_WIDTH-1 : 0] rnd;

SecA2B_n3 #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECA2BN3(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd),
	.i_a(i_a),
	.o_z(o_z),
	.ovld(ovld)
	);
*/

/*
// N_SHARES = 4
localparam N_SHARES = 4;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam RANDNUM = 18 + 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1);

localparam DELAY_CSA = 2 * DELAY_AND;

logic clk, rst_n;
logic dvld, ena;
logic [MASKWIDTH-1 : 0] i_a;
logic [MASKWIDTH-1 : 0] o_z;
logic ovld;
logic [RANDNUM*K_WIDTH-1 : 0] rnd;

SecA2B_n4 #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECA2BN4(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd),
	.i_a(i_a),
	.o_z(o_z),
	.ovld(ovld)
	);
*/

/*
// N_SHARES = 5
localparam N_SHARES = 5;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam RANDNUM = 38 + 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1);

localparam DELAY_CSA = 3 * DELAY_AND;

logic clk, rst_n;
logic dvld, ena;
logic [MASKWIDTH-1 : 0] i_a;
logic [MASKWIDTH-1 : 0] o_z;
logic ovld;
logic [RANDNUM*K_WIDTH-1 : 0] rnd;

SecA2B_n5 #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECA2BN5(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd),
	.i_a(i_a),
	.o_z(o_z),
	.ovld(ovld)
	);
*/

// N_SHARES = 8
localparam N_SHARES = 8;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam RANDNUM = 148 + 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1);

localparam DELAY_CSA = 4 * DELAY_AND;

logic clk, rst_n;
logic dvld, ena;
logic [MASKWIDTH-1 : 0] i_a;
logic [MASKWIDTH-1 : 0] o_z;
logic ovld;
logic [RANDNUM*K_WIDTH-1 : 0] rnd;

SecA2B_n8 #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECA2BN8(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd),
	.i_a(i_a),
	.o_z(o_z),
	.ovld(ovld)
	);

// Code below need not be changed

logic [K_WIDTH-1 : 0] a_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] z_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] z_result;
logic [K_WIDTH-1 : 0] z_ref_t;
logic [K_WIDTH-1 : 0] z_ref;
logic [K_WIDTH-1 : 0] z_ref_reg [0 : DELAY_CSA + DELAY_KSA - 1];

logic correct;
	
integer i;

always @(*)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		i_a[i*K_WIDTH +: K_WIDTH] = a_probe[i];
		z_probe[i] = o_z[i*K_WIDTH +: K_WIDTH];
	end
end

always @(*)
begin
	z_ref_t = 'b0;
	for(i = 0; i < N_SHARES; i = i + 1) begin
		z_ref_t = z_ref_t + a_probe[i];
	end
end

always @(posedge clk, negedge rst_n)
begin
	if(~rst_n) begin
		for(i = 0; i < DELAY_CSA + DELAY_KSA; i = i + 1) begin
			z_ref_reg[i] <= 'b0;
		end
	end
	else begin
		z_ref_reg[0] <= z_ref_t;
		for(i = 0; i < DELAY_CSA + DELAY_KSA - 1; i = i + 1) begin
			z_ref_reg[i+1] <= z_ref_reg[i];
		end
	end
end
assign z_ref = z_ref_reg[DELAY_CSA + DELAY_KSA - 1];

always @(*)
begin
	z_result = 'b0;
	for(i = 0; i < N_SHARES; i = i + 1) begin
		z_result = z_result ^ z_probe[i];
	end
end

assign correct = ovld ? (z_ref == z_result) : 1'b0;

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	dvld = 1'b0;
	ena = 1'b0;
	rnd = 'b0;
	i_a = 'b0;
	#10
	rst_n = 1'b1;
	dvld = 1'b1;
	ena = 1'b1;
end
always #5 clk = ~clk;

always @(negedge clk)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		a_probe[i] <= $urandom;
	end
	for(i = 0; i < RANDNUM; i = i + 1) begin
		rnd[i*K_WIDTH +: K_WIDTH] <= $urandom;
	end
end

endmodule