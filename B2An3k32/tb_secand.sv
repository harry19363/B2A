`ifndef SIM
`define SIM
`endif

`timescale 1 ns / 1 ps 

module tb_secand();

reg [31:0] x1, x2, x3;
reg [31:0] y1, y2, y3;
reg [31:0] n1, n2, n3;

reg clk, rstn, i_dvld, i_rvld;

wire o_dvld;

wire [95:0] x, y, n;
wire [95:0] z;

assign x = {x1, x2, x3},
		y = {y1, y2, y3},
		n = {n1, n2, n3};
		
initial begin
	clk = 1'b0;
	rstn = 1'b0;
	i_dvld = 1'b0;
	i_rvld = 1'b0;
	x1 = $urandom;
	x2 = $urandom;
	x3 = $urandom;
	y1 = $urandom;
	y2 = $urandom;
	y3 = $urandom;
	n1 = $urandom;
	n2 = $urandom;
	n3 = $urandom;
	
	#10
	rstn = 1'b1;
	i_dvld = 1'b1;
	i_rvld = 1'b1;
end

always #5 clk = ~clk;

SecAnd_PINI1_n3k32_1 SECAND0(
	.clk_i(clk),
    .rst_ni(rstn),
    .i_dvld(i_dvld),
    .i_rvld(i_rvld),
    .i_n(n),
    .i_x(x),
    .i_y(y),
    .o_c(z),
    .o_dvld(o_dvld)
	);

wire [31:0] realx, realy, realz;
wire [31:0] result;

assign realx = x1 ^ x2 ^ x3;
assign realy = y1 ^ y2 ^ y3;
assign realz = realx & realy;
assign result = z[31:0] ^ z[63:32] ^ z[95:64];

reg [7:0] test;
initial begin
	test[0+:8] = 'b11110000;
	#20
	test[7-:8] = 'b11110000;
end
	
endmodule
