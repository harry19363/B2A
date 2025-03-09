`timescale 1ns / 100ps


module tb_secksa();

reg [31:0] x1, x2, x3, y1, y2, y3;
wire [95:0] x, y;

assign x = {x3, x2, x1},
		y = {y3, y2, y1};

wire [95:0] z;
wire [31:0] result;

assign result = z[0+:32] ^ z[32+:32] ^ z[64+:32];

wire [31:0] ref_x, ref_y, ref_z;
assign ref_x = x1 ^ x2 ^ x3, 
		ref_y = y1 ^ y2 ^ y3,
		ref_z = ref_x + ref_y;
		
reg [959:0] n;
integer i;
initial begin
	for(i = 0; i < 30; i = i + 1) begin
		n[32 * i +: 32] = $urandom;
	end
	x1 = $urandom;
	x2 = $urandom;
	x3 = $urandom;
	y1 = $urandom;
	y2 = $urandom;
	y3 = $urandom;
end

reg clk_i, rst_ni, i_dvld, i_rvld;
wire o_dvld;

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

SecKSA_n3k32_1 SECKSA0(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .i_dvld(i_dvld),
    .i_rvld(i_rvld),
    .i_n(n),
    .i_x(x),
    .i_y(y),
    .o_z(z),
    .o_dvld(o_dvld)
	);

endmodule
