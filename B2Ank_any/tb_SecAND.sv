`timescale 1ns / 100ps

module tb_SecAND();
localparam K_WIDTH = 32;
localparam N_SHARES = 8;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam RANDNUM = N_SHARES * (N_SHARES-1);

logic clk, rst_n;
logic ena;
logic dvld;
logic ovld;
logic [K_WIDTH * RANDNUM - 1:0] rnd;
logic [MASKWIDTH-1:0] x;
logic [MASKWIDTH-1:0] y;
logic [MASKWIDTH-1:0] z;

logic [K_WIDTH-1 : 0] x_src;
logic [K_WIDTH-1 : 0] y_src;
logic [K_WIDTH-1 : 0] z_ref;
logic [K_WIDTH-1 : 0] z_ref_reg;
logic [K_WIDTH-1 : 0] z_result;
logic [K_WIDTH-1 : 0] x_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] y_probe [0 : N_SHARES-1];

logic correct;


SecAND #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECAND0(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd),
	.x(x),
	.y(y),
	.z(z),
	.ovld(ovld)
	);

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	ena = 1'b0;
	dvld = 1'b0;
	rnd = 'b0;
	x = 'b0;
	y = 'b0;
	#10 
	rst_n = 1'b1;
	ena = 1'b1;
	dvld = 1'b1;
end

always #5 clk = ~clk;

integer i, j;
always @(negedge clk)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		x_probe[i] <= $urandom;
		y_probe[i] <= $urandom;
	end
	for(i = 0; i < RANDNUM; i = i + 1) begin
		rnd[i*K_WIDTH +: K_WIDTH] <= $urandom;
	end
end

always @(*)
begin
	x_src = 'b0;
	y_src = 'b0;
	for(i = 0; i < N_SHARES; i = i + 1) begin
		x_src = x_src ^ x_probe[i];
		y_src = y_src ^ y_probe[i];
	end
end

assign z_ref = x_src & y_src;

always @(posedge clk, negedge rst_n)
begin
	z_ref_reg <= (~rst_n) ? 'b0: z_ref;
end

assign correct = (z_ref_reg == z_result);

always @(*)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		x[i*K_WIDTH +: K_WIDTH] = x_probe[i];
		y[i*K_WIDTH +: K_WIDTH] = y_probe[i];
	end
end

always @(*)
begin
	z_result = 'b0;
	for(i = 0; i < N_SHARES; i = i + 1) begin
		z_result = z_result ^ z[i*K_WIDTH +: K_WIDTH];
	end
end

endmodule