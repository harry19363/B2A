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
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] x_reg [0 : N_SHARES-1];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] xy_reg [0 : N_SHARES-1];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] u1 [0 : N_SHARES-1] [0 : N_SHARES-2];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] u2 [0 : N_SHARES-1] [0 : N_SHARES-2];

// wire
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] c [0 : N_SHARES-1] [0 : N_SHARES-2];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] c_t [0 : N_SHARES-1] [0 : N_SHARES-2];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] rnd1 [0 : N_SHARES*(N_SHARES-1)/2 - 1];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] rnd2 [0 : N_SHARES*(N_SHARES-1)/2 - 1];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] x_t [0 : N_SHARES-1];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] y_t [0 : N_SHARES-1];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] xy_t [0 : N_SHARES-1];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] u1_t [0 : N_SHARES-1] [0 : N_SHARES-2];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] u2_t0 [0 : N_SHARES-1] [0 : N_SHARES-2];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] u2_t1 [0 : N_SHARES-1] [0 : N_SHARES-2];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] z_t [0 : N_SHARES-1];
(*DONT_TOUCH="yes"*) wire [K_WIDTH-1 : 0] c_xor [0 : N_SHARES-1] [0 : N_SHARES-3];

genvar i, j;

// rji = rij + n(n-1)/2
generate
	for(i = 0; i < N_SHARES*(N_SHARES-1)/2; i = i + 1) begin
		assign rnd1[i] = rnd[i*K_WIDTH +: K_WIDTH];
		// rnd1[i + N_SHARES*(N_SHARES-1)/2] = rnd[i*K_WIDTH +: K_WIDTH];
		assign rnd2[i] = rnd[(i + N_SHARES*(N_SHARES-1)/2)*K_WIDTH +: K_WIDTH];
		// rnd2[i + N_SHARES*(N_SHARES-1)/2] = rnd[(i + N_SHARES*(N_SHARES-1)/2)*K_WIDTH +: K_WIDTH];
	end
endgenerate

// x_t, y_t
generate
	for(i = 0; i < N_SHARES; i = i + 1) begin
		assign x_t[i] = x[i*K_WIDTH +: K_WIDTH];
		assign y_t[i] = y[i*K_WIDTH +: K_WIDTH];
	end
endgenerate

// x_reg
// always @(posedge clk)
// begin
	// if(ena && dvld) begin
		// for(i = 0; i < N_SHARES; i = i + 1)
			// x_reg[i] <= x_t[i];
	// end
	// else begin
		// for(i = 0; i < N_SHARES; i = i + 1)
			// x_reg[i] <= x_reg[i];
	// end
// end

generate 
	for(i = 0; i < N_SHARES; i = i + 1) begin
		lix_reg #(
			.W(K_WIDTH)
			) u0_reg(
			.clk_i(clk),
			.rst_ni(rst_n),
			.i_vld(dvld),
			.i_en(ena),
			.i_x(x_t[i]),
			.o_z(x_reg[i])
			);
	end
endgenerate

// ovld
lix_reg #(
	.W(1)
	) u1_reg(
	.clk_i(clk),
	.rst_ni(rst_n),
	.i_vld(1'b1),
	.i_en(ena),
	.i_x(dvld),
	.o_z(ovld)
	);

// xi AND yi
// always @(posedge clk)
// begin
	// if(ena && dvld) begin
		// for(i = 0; i < N_SHARES; i = i + 1)
			// xy_reg[i] <= x[i*K_WIDTH +: K_WIDTH] & y[i*K_WIDTH +: K_WIDTH];
	// end
	// else begin
		// for(i = 0; i < N_SHARES; i = i + 1)
			// xy_reg[i] <= xy_reg[i];
	// end
// end
generate 
	for(i = 0; i < N_SHARES; i = i + 1) begin
		lix_and #(
			.W(K_WIDTH)
			) u2_and(
			.i_x(x[i*K_WIDTH +: K_WIDTH]),
			.i_y(y[i*K_WIDTH +: K_WIDTH]),
			.o_z(xy_t[i])
			);
	end
endgenerate

generate 
	for(i = 0; i < N_SHARES; i = i + 1) begin
		lix_reg #(
			.W(K_WIDTH)
			) u3_reg(
			.clk_i(clk),
			.rst_ni(rst_n),
			.i_vld(dvld),
			.i_en(ena),
			.i_x(xy_t[i]),
			.o_z(xy_reg[i])
			);
	end
endgenerate

// u1, u2
// always @(posedge clk)
// begin
	// if(ena && dvld) begin
		// for(i = 0; i < N_SHARES - 1; i = i + 1) begin
			// for(j = i; j < N_SHARES - 1; j = j + 1) begin
				// // u1[i, j] <- rnd1[i, j+1]
				// u1[i][j] <= y_t[j+1] ^ rnd1[N_SHARES*i - i * (i + 1)/2 + j - i];
				// u2[i][j] <= (~x_t[i] & rnd1[N_SHARES*i - i * (i + 1)/2 + j - i]) ^ rnd2[N_SHARES*i - i * (i + 1)/2 + j - i];
			// end
		// end
		// for(i = 1; i < N_SHARES; i = i + 1) begin
			// for(j = 0; j < i; j = j + 1) begin
				// // u1[i, j] <- rnd1[j, i]
				// u1[i][j] <= y_t[j] ^ rnd1[N_SHARES*j - j * (j + 1)/2 + i - j - 1];
				// u2[i][j] <= (~x_t[i] & rnd1[N_SHARES*j - j * (j + 1)/2 + i - j - 1]) ^ rnd2[N_SHARES*j - j * (j + 1)/2 + i - j - 1];
			// end
		// end
	// end
// end

generate 
	for(i = 0; i < N_SHARES - 1; i = i + 1) begin
		for(j = i; j < N_SHARES - 1; j = j + 1) begin
			lix_xor #(
				.W(K_WIDTH)
				) u4_xor(
				.i_x(y_t[j+1]),
				.i_y(rnd1[N_SHARES*i - i * (i + 1)/2 + j - i]),
				.o_z(u1_t[i][j])
				);
			lix_and #(
				.W(K_WIDTH)
				) u5_and(
				.i_x(~x_t[i]),
				.i_y(rnd1[N_SHARES*i - i * (i + 1)/2 + j - i]),
				.o_z(u2_t0[i][j])
				);
			lix_xor #(
				.W(K_WIDTH)
				) u6_xor(
				.i_x(u2_t0[i][j]),
				.i_y(rnd2[N_SHARES*i - i * (i + 1)/2 + j - i]),
				.o_z(u2_t1[i][j])
				);
		end
	end
endgenerate

generate
	for(i = 1; i < N_SHARES; i = i + 1) begin
		for(j = 0; j < i; j = j + 1) begin
			lix_xor #(
				.W(K_WIDTH)
				) u7_xor(
				.i_x(y_t[j]),
				.i_y(rnd1[N_SHARES*j - j * (j + 1)/2 + i - j - 1]),
				.o_z(u1_t[i][j])
				);
			lix_and #(
				.W(K_WIDTH)
				) u8_and(
				.i_x(~x_t[i]),
				.i_y(rnd1[N_SHARES*j - j * (j + 1)/2 + i - j - 1]),
				.o_z(u2_t0[i][j])
				);
			lix_xor #(
				.W(K_WIDTH)
				) u9_xor(
				.i_x(u2_t0[i][j]),
				.i_y(rnd2[N_SHARES*j - j * (j + 1)/2 + i - j - 1]),
				.o_z(u2_t1[i][j])
				);
		end
	end
endgenerate

generate
	for(i = 0; i < N_SHARES; i = i + 1) begin
		for(j = 0; j < N_SHARES - 1; j = j + 1) begin
			lix_reg #(
				.W(K_WIDTH)
				) u10_reg(
				.clk_i(clk),
				.rst_ni(rst_n),
				.i_vld(dvld),
				.i_en(ena),
				.i_x(u1_t[i][j]),
				.o_z(u1[i][j])
				);
			lix_reg #(
				.W(K_WIDTH)
				) u11_reg(
				.clk_i(clk),
				.rst_ni(rst_n),
				.i_vld(dvld),
				.i_en(ena),
				.i_x(u2_t1[i][j]),
				.o_z(u2[i][j])
				);
		end
	end
endgenerate

// c
generate
	for(i = 0; i < N_SHARES; i = i + 1) begin
		for(j = 0; j < N_SHARES - 1; j = j + 1) begin
			lix_and #(
				.W(K_WIDTH)
				) u12_and(
				.i_x(x_reg[i]),
				.i_y(u1[i][j]),
				.o_z(c_t[i][j])
				);
			lix_xor #(
				.W(K_WIDTH)
				) u13_xor(
				.i_x(c_t[i][j]),
				.i_y(u2[i][j]),
				.o_z(c[i][j])
				);
		end
	end
endgenerate

// z
// always @(*)
// begin
	// for(i = 0; i < N_SHARES; i = i + 1) begin
		// c_xor[i] = 'b0;
		// for(j = 0; j < N_SHARES-1; j = j + 1) begin
			// c_xor[i] = c_xor[i] ^ c[i][j];
		// end
	// end
// end

generate
	for(i = 0; i < N_SHARES; i = i + 1) begin
		lix_xor #(
			.W(K_WIDTH)
			) u14_xor(
			.i_x(c[i][0]),
			.i_y(c[i][1]),
			.o_z(c_xor[i][0])
			);
	end
endgenerate

generate 
	for(i = 0; i < N_SHARES; i = i + 1) begin
		for(j = 0; j < N_SHARES-3; j = j + 1) begin
			lix_xor #(
				.W(K_WIDTH)
				) u15_xor(
				.i_x(c_xor[i][j]),
				.i_y(c[i][j+2]),
				.o_z(c_xor[i][j+1])
				);
		end
	end
endgenerate

generate 
	for(i = 0; i < N_SHARES; i = i + 1) begin
		lix_xor #(
			.W(K_WIDTH)
			) u16_xor(
			.i_x(xy_reg[i]),
			.i_y(c_xor[i][N_SHARES-3]),
			.o_z(z_t[i])
			);
	end
endgenerate

generate
	for(i = 0; i < N_SHARES; i = i + 1) begin
		assign z[i * K_WIDTH +: K_WIDTH] = z_t[i];
	end
endgenerate


endmodule