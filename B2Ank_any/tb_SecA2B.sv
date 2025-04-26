`timescale 1ns / 100ps

module tb_SecA2B();

localparam K_WIDTH = 32;
localparam N_SHARES = 3;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam RANDNUM = N_SHARES*(N_SHARES-1) + 2 * $clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1);

localparam DELAY_AND = 1;
localparam DELAY_CSA = DELAY_AND;
localparam DELAY_KSA = ($clog2(K_WIDTH-1) + 1) * DELAY_AND;

logic clk, rst_n;
logic dvld, ena;
logic [RANDNUM*K_WIDTH-1 : 0] rnd;
logic [MASKWIDTH-1 : 0] i_a;
logic [MASKWIDTH-1 : 0] o_z;
logic ovld;

logic [K_WIDTH-1 : 0] a_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] z_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] z_result;
logic [K_WIDTH-1 : 0] z_ref;
logic [K_WIDTH-1 : 0] z_ref_reg [0 : DELAY_CSA + DELAY_KSA - 1];

logic correct;

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
	
integer i;

always @(*)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		i_a[i*K_WIDTH +: K_WIDTH] = a_probe[i];
		z_probe[i] = o_z[i*K_WIDTH +: K_WIDTH];
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
		z_ref_reg[0] <= a_probe[0] + a_probe[1] + a_probe[2];
		for(i = 0; i < DELAY_CSA + DELAY_KSA - 1; i = i + 1) begin
			z_ref_reg[i+1] <= z_ref_reg[i];
		end
	end
end
assign z_ref = z_ref_reg[DELAY_CSA + DELAY_KSA - 1];

assign z_result = z_probe[0] ^ z_probe[1] ^ z_probe[2];

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