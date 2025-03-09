`timescale 1ns / 1ps

module tb_SecB2A();

localparam K_WIDTH = 32;
localparam N_SHARES = 3;
localparam MASKWIDTH = K_WIDTH * N_SHARES;
localparam LOG_K = $clog2(N_SHARES+1) - 1;
localparam RAND_INIT = N_SHARES - 1;
localparam RAND_A2B = (2*$clog2(K_WIDTH-1) + N_SHARES-2) * N_SHARES*(N_SHARES-1)/2;
localparam RAND_KSA = 2*$clog2(K_WIDTH-1) * N_SHARES*(N_SHARES-1)/2;
localparam RAND_FXOR = (N_SHARES==1) ? 0 : LOG_K * 2**(LOG_K-1) + N_SHARES - 2**LOG_K;
localparam RANDNUM = RAND_INIT + RAND_A2B + RAND_KSA + RAND_FXOR;

reg clk_i;
reg rst_ni;
reg i_dvld;
reg i_rvld;
reg [K_WIDTH*RANDNUM-1:0] i_n;
reg [MASKWIDTH-1:0] i_x;
wire [MASKWIDTH-1:0] o_z;
wire o_dvld;

// Init 2 cycles, A2B 14 cycles, KSA 12 cycles, FullXOR 2 cycles
logic [K_WIDTH-1:0] res;
logic [K_WIDTH-1:0] res_tmp[0:29];
logic signed [K_WIDTH-1:0] A_res;

logic signed [K_WIDTH-1:0] probe_z[2:0];
assign {probe_z[2], probe_z[1], probe_z[0]} = o_z;
assign A_res = probe_z[2] + probe_z[1] + probe_z[0];

wire [K_WIDTH-1:0] probe_a[2:0];
wire [K_WIDTH-1:0] probe_an[2:0];
wire [K_WIDTH-1:0] probe_b[2:0];
wire [K_WIDTH-1:0] probe_x[2:0];
wire [K_WIDTH-1:0] probe_y[2:0];
assign {probe_a[2], probe_a[1], probe_a[0]} = SECB2A0.A;
assign {probe_an[2], probe_an[1], probe_an[0]} = SECB2A0.An;
assign {probe_b[2], probe_b[1], probe_b[0]} = SECB2A0.y;
assign {probe_x[2], probe_x[1], probe_x[0]} = SECB2A0.b_r;
assign {probe_y[2], probe_y[1], probe_y[0]} = SECB2A0.z;
wire [K_WIDTH-1:0] ref_pa, ref_pan, ref_pb, ref_px, ref_py;
wire [K_WIDTH-1:0] res_y;
assign res_y = probe_y[2] + probe_y[1] + probe_y[0];
assign ref_pa = probe_a[1] + probe_a[0];
assign ref_pan = probe_an[2] + probe_an[1] + probe_an[0];
assign ref_pb = probe_b[2] ^ probe_b[1] ^ probe_b[0];
assign ref_px = probe_x[2] ^ probe_x[1] ^ probe_x[0];
assign ref_py = ref_pb + ref_px;

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
always #5 clk_i = ~clk_i;

initial begin
	i_n = 'b0;
	i_x = 'b0;
	// for(int i = 0; i < RANDNUM; i = i+1) begin
		// i_n[i*K_WIDTH +: K_WIDTH] = $random;
	// end
	repeat(100) begin
		#10
		for(int i = 0; i < RANDNUM; i = i+1) begin
			i_n[i*K_WIDTH +: K_WIDTH] = $random;
		end
		for(int i = 0; i < N_SHARES; i = i+1) begin
			i_x[i*K_WIDTH +: K_WIDTH] = $random;
		end
	end
end

initial begin
	#10;
	forever begin
		@(posedge clk_i);
		res_tmp[0] <= i_x[0 +: K_WIDTH] ^ i_x[K_WIDTH +: K_WIDTH] ^ i_x[2*K_WIDTH +: K_WIDTH];
		for(int i = 1; i <= 29; i = i+1)
			res_tmp[i] <= res_tmp[i-1];
	end
end
assign res = res_tmp[29];

SecB2A #(
	.K_WIDTH(K_WIDTH),
	.N_SHARES(N_SHARES)
	) SECB2A0(
	.clk_i(clk_i),
	.rst_ni(rst_ni),
	.i_dvld(i_dvld),
	.i_rvld(i_rvld),
	.i_n(i_n),
	.i_b(i_x),
	.o_a(o_z),
	.o_dvld(o_dvld)
);

endmodule
