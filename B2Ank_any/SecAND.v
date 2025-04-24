`timescale 1ns / 100ps

module SecAND #(
	parameter K_WIDTH = 32,
	parameter N_SHARES = 3,
	parameter MASKWIDTH = K_WIDTH * N_SHARES,
	parameter RANDNUM = N_SHARES * (N_SHARES-1)
)(
	input wire clk,  // clock
	input wire rst_n,  // areset on negative edge
	input wire dvld,  // data valid
	input wire ena,  // enable
	input wire [K_WIDTH * RANDNUM - 1:0] rnd,  // fresh randomness
	input wire [MASKWIDTH-1:0] x,  // input x
	input wire [MASKWIDTH-1:0] y,  // input y
	output wire [MASKWIDTH-1:0] z,  // output z
	output wire ovld  // output valid
);

// reg
reg [K_WIDTH-1 : 0] x_reg [0 : N_SHARES-1];
reg [K_WIDTH-1 : 0] xy_reg [0 : N_SHARES-1];
reg [K_WIDTH-1 : 0] u1 [0 : N_SHARES-1] [0 : N_SHARES-2];
reg [K_WIDTH-1 : 0] u2 [0 : N_SHARES-1] [0 : N_SHARES-2];
reg vld_reg;

// wire
(*keep="true"*) reg [K_WIDTH-1 : 0] c [0 : N_SHARES-1] [0 : N_SHARES-2];
(*keep="true"*) reg [K_WIDTH-1 : 0] rnd1 [0 : N_SHARES*(N_SHARES-1)/2 - 1];
(*keep="true"*) reg [K_WIDTH-1 : 0] rnd2 [0 : N_SHARES*(N_SHARES-1)/2 - 1];
(*keep="true"*) reg [K_WIDTH-1 : 0] x_t [0 : N_SHARES-1];
(*keep="true"*) reg [K_WIDTH-1 : 0] y_t [0 : N_SHARES-1];
(*keep="true"*) reg [K_WIDTH-1 : 0] z_t [0 : N_SHARES-1];
(*keep="true"*) reg [K_WIDTH-1 : 0] c_xor [0 : N_SHARES-1];

integer i, j;

// rji = rij + n(n-1)/2
always @(*)
begin
	for(i = 0; i < N_SHARES*(N_SHARES-1)/2; i = i + 1) begin
		rnd1[i] = rnd[i*K_WIDTH +: K_WIDTH];
		// rnd1[i + N_SHARES*(N_SHARES-1)/2] = rnd[i*K_WIDTH +: K_WIDTH];
		rnd2[i] = rnd[(i + N_SHARES*(N_SHARES-1)/2)*K_WIDTH +: K_WIDTH];
		// rnd2[i + N_SHARES*(N_SHARES-1)/2] = rnd[(i + N_SHARES*(N_SHARES-1)/2)*K_WIDTH +: K_WIDTH];
	end
end

// x_t, y_t
always @(*)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		x_t[i] = x[i*K_WIDTH +: K_WIDTH];
		y_t[i] = y[i*K_WIDTH +: K_WIDTH];
	end
end

// x_reg
always @(posedge clk)
begin
	if(ena && dvld) begin
		for(i = 0; i < N_SHARES; i = i + 1)
			x_reg[i] <= x_t[i];
	end
	else begin
		for(i = 0; i < N_SHARES; i = i + 1)
			x_reg[i] <= x_reg[i];
	end
end

// xi AND yi
always @(posedge clk)
begin
	if(ena && dvld) begin
		for(i = 0; i < N_SHARES; i = i + 1)
			xy_reg[i] <= x[i*K_WIDTH +: K_WIDTH] & y[i*K_WIDTH +: K_WIDTH];
	end
	else begin
		for(i = 0; i < N_SHARES; i = i + 1)
			xy_reg[i] <= xy_reg[i];
	end
end

// u1, u2
always @(posedge clk)
begin
	if(ena && dvld) begin
		for(i = 0; i < N_SHARES - 1; i = i + 1) begin
			for(j = i; j < N_SHARES - 1; j = j + 1) begin
				// u1[i, j] <- rnd1[i, j+1]
				u1[i][j] <= y_t[j+1] ^ rnd1[N_SHARES*i - i * (i + 1)/2 + j - i];
				u2[i][j] <= (~x_t[i] & rnd1[N_SHARES*i - i * (i + 1)/2 + j - i]) ^ rnd2[N_SHARES*i - i * (i + 1)/2 + j - i];
			end
		end
		for(i = 1; i < N_SHARES; i = i + 1) begin
			for(j = 0; j < i; j = j + 1) begin
				// u1[i, j] <- rnd1[j, i]
				u1[i][j] <= y_t[j] ^ rnd1[N_SHARES*j - j * (j + 1)/2 + i - j - 1];
				u2[i][j] <= (~x_t[i] & rnd1[N_SHARES*j - j * (j + 1)/2 + i - j - 1]) ^ rnd2[N_SHARES*j - j * (j + 1)/2 + i - j - 1];
			end
		end
	end
end

// c
always @(*)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		for(j = 0; j < N_SHARES - 1; j = j + 1) begin
			c[i][j] = x_reg[i] & u1[i][j] ^ u2[i][j];
		end
	end
end

// z
always @(*)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		c_xor[i] = 'b0;
		for(j = 0; j < N_SHARES-1; j = j + 1) begin
			c_xor[i] = c_xor[i] ^ c[i][j];
		end
	end
end

always @(*)
begin
	for(i = 0; i < N_SHARES; i = i + 1) begin
		z_t[i] = xy_reg[i] ^ c_xor[i];
	end
end

genvar k;
generate
	for(k = 0; k < N_SHARES; k = k + 1) begin
		assign z[k * K_WIDTH +: K_WIDTH] = z_t[k];
	end
endgenerate

// ovld
always @(posedge clk, negedge rst_n)
begin
	if(~rst_n)
		vld_reg <= 1'b0;
	else if(ena && dvld)
		vld_reg <= 1'b1;
	else 
		vld_reg <= 1'b0;
end
assign ovld = vld_reg;

endmodule