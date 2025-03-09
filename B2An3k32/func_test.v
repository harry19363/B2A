`timescale 1ns / 1ns

module func_test();
reg [4:0] a;
reg [4:0] res;

always @(*)
begin
	res = $clog2(a+1) - 1;
end

initial begin
	a = 0;
	repeat(20) begin
		#10
		a = a + 1;
	end
end

endmodule
