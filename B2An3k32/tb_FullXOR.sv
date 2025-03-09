`timescale 1ns / 1ps

module tb_FullXOR();

localparam K_WIDTH = 32;
localparam N_SHARES = 3;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam LOG_K = $clog2(N_SHARES+1) - 1;
localparam LAYERS = $clog2(N_SHARES);
localparam RANDNUM = (N_SHARES==1) ? 0 : LOG_K * 2**(LOG_K-1) + N_SHARES - 2**LOG_K;

reg clk_i;
reg rst_ni;
reg i_dvld;
reg i_rvld;
reg [K_WIDTH*RANDNUM-1:0] i_n;
reg [MASKWIDTH-1:0] i_x;
wire [K_WIDTH-1:0] o_z;
wire o_dvld;

logic [K_WIDTH-1:0] res;
logic [K_WIDTH-1:0] res_tmp[0:1];

initial begin
	#10;
	forever begin
		@(posedge clk_i);
		res_tmp[0] <= i_x[0 +: K_WIDTH] ^ i_x[K_WIDTH +: K_WIDTH] ^ i_x[2*K_WIDTH +: K_WIDTH];
		res_tmp[1] <= res_tmp[0];
	end
end

assign res = res_tmp[1];

initial begin
	clk_i = 1'b0;
	rst_ni = 1'b0;
	i_dvld = 1'b0;
	i_rvld = 1'b0;
	#10
	rst_ni = 1'b1;
	i_dvld = 1'b1;
	i_rvld = 1'b1;
end

initial begin
	i_n = 'b0;
	i_x = 'b0;
	repeat(100) begin
		#10
		for(int i = 0; i < RANDNUM; i = i+1) begin
			i_n[i*K_WIDTH +: K_WIDTH] = $urandom;
		end
		for(int i = 0; i < N_SHARES; i = i+1) begin
			i_x[i*K_WIDTH +: K_WIDTH] = $urandom;
		end
	end
end

always #5 clk_i = ~clk_i;

FullXOR #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	)FXOR0(
	.clk_i(clk_i),
	.rst_ni(rst_ni),
	.i_dvld(i_dvld),
	.i_rvld(i_rvld),
	.i_n(i_n),
	.i_x(i_x),
	.o_z(o_z),
	.o_dvld(o_dvld)
	);

endmodule
