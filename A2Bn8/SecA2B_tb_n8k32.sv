//////////////////////////////////////////////////////////////////////////////////
// Company       : TSU
// Engineer      : 
// 
// Create Date   : 2025-03-06
// File Name     : SecA2B_tb_n8k32.v
// Project Name  : 
// Design Name   : 
// Description   : 
//                
// 
// Dependencies  : 
// 
// Revision      : 
//                 - V1.0 File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// 
// WARNING: THIS FILE IS AUTOGENERATED
// ANY MANUAL CHANGES WILL BE LOST

`timescale 1ns/1ps
module SecA2B_tb_n8k32;

logic            clk_i;
logic            rst_ni;
logic            i_dvld;
logic            i_rvld;
logic  [11615:0] i_n;
logic    [255:0] i_a;
logic    [255:0] o_z;
logic            o_dvld;
logic    [255:0] a;
logic            dvld;
logic     [31:0] A;
logic     [31:0] B;
logic     [31:0] A_d;
logic            pass;
logic            rvld;

initial
begin
  clk_i = 1'd0;
  forever #(10/2) clk_i = ~clk_i;
end


initial
begin
 rst_ni = 1'd0;
 #100;
 rst_ni = 1'd1;
end


initial
begin
  i_n = 11616'd0;
  repeat (15) @(posedge clk_i);
  forever begin
    @(posedge clk_i);
    for(int i = 0 ; i < 363 ; i++)begin
      i_n[i*32+:32] = $random;
    end
  end
end


initial
begin
  a = 256'd0;
  repeat (15) @(posedge clk_i);
  forever begin
    @(posedge clk_i);
    for(int i = 0 ; i < 8 ; i++)begin
      a[i*32+:32] = $random;
    end
  end
end


initial
begin
  dvld = 1'd0;
  repeat (16) @(posedge clk_i);
    dvld = 1'd1;
  repeat (500) @(posedge clk_i);
    dvld = 1'd0;
end


initial
begin
  rvld = 1'd0;
  repeat (16) @(posedge clk_i);
    rvld = 1'd1;
  repeat (524) @(posedge clk_i);
    rvld = 1'd0;
end

assign i_a[0+:32] = a[0+:32] - a[32+:32] - a[64+:32] - a[96+:32] - a[128+:32] - a[160+:32] - a[192+:32] - a[224+:32] ;
assign i_a[32+:32] = a[32+:32];
assign i_a[64+:32] = a[64+:32];
assign i_a[96+:32] = a[96+:32];
assign i_a[128+:32] = a[128+:32];
assign i_a[160+:32] = a[160+:32];
assign i_a[192+:32] = a[192+:32];
assign i_a[224+:32] = a[224+:32];
assign i_dvld = dvld;
assign i_rvld = rvld;
SecA2B_n8k32_1
  dut_SecA2B_n8k32_1
   (.clk_i  (clk_i),
    .rst_ni (rst_ni),
    .i_dvld (i_dvld),
    .i_rvld (i_rvld),
    .i_n    (i_n),
    .i_a    (i_a),
    .o_z    (o_z),
    .o_dvld (o_dvld));



assign A[0+:32] = i_a[0+:32] + i_a[32+:32] + i_a[64+:32] + i_a[96+:32] + i_a[128+:32] + i_a[160+:32] + i_a[192+:32] + i_a[224+:32] ;

assign B[0+:32] = o_z[0+:32] ^ o_z[32+:32] ^ o_z[64+:32] ^ o_z[96+:32] ^ o_z[128+:32] ^ o_z[160+:32] ^ o_z[192+:32] ^ o_z[224+:32] ;

reg  [31:0] shd_A_d [23:0];
always@(negedge rst_ni or posedge clk_i) begin
  if (~rst_ni)begin
    shd_A_d[0] <= 32'd0;
    shd_A_d[1] <= 32'd0;
    shd_A_d[2] <= 32'd0;
    shd_A_d[3] <= 32'd0;
    shd_A_d[4] <= 32'd0;
    shd_A_d[5] <= 32'd0;
    shd_A_d[6] <= 32'd0;
    shd_A_d[7] <= 32'd0;
    shd_A_d[8] <= 32'd0;
    shd_A_d[9] <= 32'd0;
    shd_A_d[10] <= 32'd0;
    shd_A_d[11] <= 32'd0;
    shd_A_d[12] <= 32'd0;
    shd_A_d[13] <= 32'd0;
    shd_A_d[14] <= 32'd0;
    shd_A_d[15] <= 32'd0;
    shd_A_d[16] <= 32'd0;
    shd_A_d[17] <= 32'd0;
    shd_A_d[18] <= 32'd0;
    shd_A_d[19] <= 32'd0;
    shd_A_d[20] <= 32'd0;
    shd_A_d[21] <= 32'd0;
    shd_A_d[22] <= 32'd0;
    shd_A_d[23] <= 32'd0;
  end else begin
    shd_A_d[0] <= A[0+:32];
    shd_A_d[1] <= shd_A_d[0];
    shd_A_d[2] <= shd_A_d[1];
    shd_A_d[3] <= shd_A_d[2];
    shd_A_d[4] <= shd_A_d[3];
    shd_A_d[5] <= shd_A_d[4];
    shd_A_d[6] <= shd_A_d[5];
    shd_A_d[7] <= shd_A_d[6];
    shd_A_d[8] <= shd_A_d[7];
    shd_A_d[9] <= shd_A_d[8];
    shd_A_d[10] <= shd_A_d[9];
    shd_A_d[11] <= shd_A_d[10];
    shd_A_d[12] <= shd_A_d[11];
    shd_A_d[13] <= shd_A_d[12];
    shd_A_d[14] <= shd_A_d[13];
    shd_A_d[15] <= shd_A_d[14];
    shd_A_d[16] <= shd_A_d[15];
    shd_A_d[17] <= shd_A_d[16];
    shd_A_d[18] <= shd_A_d[17];
    shd_A_d[19] <= shd_A_d[18];
    shd_A_d[20] <= shd_A_d[19];
    shd_A_d[21] <= shd_A_d[20];
    shd_A_d[22] <= shd_A_d[21];
    shd_A_d[23] <= shd_A_d[22];
  end
end
assign A_d[31:0] = shd_A_d[23];


assign pass = B[ 0+:32]  ==  A_d[ 0+:32];


logic fail;
initial
begin
  fail = 1'd0;
  forever begin
    @(posedge clk_i);
    if (pass != 1'd1 && o_dvld == 1'd1)begin
       $display("Test_Failed");
       fail = 1'd1;
    end
  end
end

initial
begin
  #7000;
  @(posedge clk_i);
  if (fail == 1'b0)begin
    $display("Test_Passed");
  end
end


initial
begin
  #8000;
  $finish;
end

endmodule
