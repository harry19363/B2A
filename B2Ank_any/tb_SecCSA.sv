`timescale 1ns / 100ps

module tb_SecCSA();
localparam K_WIDTH = 32;
localparam N_SHARES = 8;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam RANDNUM = N_SHARES*(N_SHARES-1);

logic clk, rst_n;
logic ena;
logic dvld;
logic ovld;
logic [K_WIDTH * RANDNUM - 1:0] rnd;
logic [MASKWIDTH-1:0] x;
logic [MASKWIDTH-1:0] y;
logic [MASKWIDTH-1:0] cin;
logic [MASKWIDTH-1:0] s;
logic [MASKWIDTH-1:0] cout;

logic [K_WIDTH-1 : 0] x_src;
logic [K_WIDTH-1 : 0] y_src;
logic [K_WIDTH-1 : 0] cin_src;
logic [K_WIDTH-1 : 0] s_ref;
logic [K_WIDTH-1 : 0] s_ref_reg;
logic [K_WIDTH-1 : 0] s_result;
logic [K_WIDTH-1 : 0] c_ref;
logic [K_WIDTH-1 : 0] c_ref_reg;
logic [K_WIDTH-1 : 0] c_result;
logic [K_WIDTH-1 : 0] x_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] y_probe [0 : N_SHARES-1];
logic [K_WIDTH-1 : 0] cin_probe [0 : N_SHARES-1];

logic correct;


SecCSA #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECCSA0(
	.clk(clk),
	.rst_n(rst_n),
	.dvld(dvld),
	.ena(ena),
	.rnd(rnd),
	.x(x),
	.y(y),
	.cin(cin),
	.s(s),
	.cout(cout),
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
	cin = 'b0;
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
		cin_probe[i] <= $urandom;
	end
	for(i = 0; i < RANDNUM; i = i + 1) begin
		rnd[i*K_WIDTH +: K_WIDTH] <= $urandom;
	end
end

always @(*)
begin
	x_src = 'b0;
	y_src = 'b0;
	cin_src = 'b0;
	for(i = 0; i < N_SHARES; i = i + 1) begin
		x_src = x_src ^ x_probe[i];
		y_src = y_src ^ y_probe[i];
		cin_src = cin_src ^ cin_probe[i];
	end
end

always @(posedge clk, negedge rst_n)
begin
	if(~rst_n) begin
		s_ref_reg <= 'b0;
		c_ref_reg <= 'b0;
	end
	else begin
		s_ref_reg <= x_src ^ y_src ^ cin_src;
		c_ref_reg <= (x_src & y_src ^ x_src & cin_src ^ y_src & cin_src) << 1; 
	end
end

assign s_ref = s_ref_reg;
assign c_ref = c_ref_reg;

assign correct = (s_ref == s_result) && (c_ref == c_result);

always @(*)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		x[i*K_WIDTH +: K_WIDTH] = x_probe[i];
		y[i*K_WIDTH +: K_WIDTH] = y_probe[i];
		cin[i*K_WIDTH +: K_WIDTH] = cin_probe[i];
	end
end

always @(*)
begin
	s_result = 'b0;
	c_result = 'b0;
	for(i = 0; i < N_SHARES; i = i + 1) begin
		s_result = s_result ^ s[i*K_WIDTH +: K_WIDTH];
		c_result = c_result ^ cout[i*K_WIDTH +: K_WIDTH];
	end
end

endmodule