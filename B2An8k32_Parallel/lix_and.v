//////////////////////////////////////////////////////////////////////////////////
// Company       : TSU
// Engineer      : 
// 
// Create Date   : 2023-09-01
// File Name     : lix_and.v
// Project Name  : 
// Design Name   : 
// Description   : 
// 
// Dependencies  : 
// 
// Revision      : 
//                 - V1.0 File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// 
`ifndef FPGA
`define FPGA
`endif

`default_nettype none
`timescale 1ns/1ps
module lix_and  #(
    parameter  W = 32
  )(
    input  wire [W-1:0] i_x,
    input  wire [W-1:0] i_y,
    output wire [W-1:0] o_z);

`ifdef SIM
  
  genvar i;
  generate
  for (i = 0 ; i < W ; i = i + 1)begin: GAND

    assign o_z[i] = i_x[i] & i_y[i];
    
  end
  endgenerate


`elsif FPGA

  genvar i;
  generate    
    for (i = 0 ; i < W ; i = i +1) begin: GAND
  
      LUT6 #(.INIT(64'h0000000000000008))
       lut6_and_inst(
        .O (o_z[i]),
        .I0(i_x[i]),
        .I1(i_y[i]),
        .I2(1'd0),
        .I3(1'd0),
        .I4(1'd0),
        .I5(1'd0)
        );

    end
  endgenerate

`elsif TSMC_28N

  genvar i;
  generate    
    for (i = 0 ; i < W ; i = i +1) begin: GAND
      AN2D4BWP12T30P140LVT u_and
      (.A1(i_x[i]),.A2(i_y[i]),.Z(o_z[i]));
    end
  endgenerate


`elsif LIB_45NM

  genvar i;
  generate    
    for (i = 0 ; i < W ; i = i +1) begin: GAND
      AND2_X4 u_and
      (.A1(i_x[i]), .A2(i_y[i]), .ZN(o_z[i]));
    end
  endgenerate


`else


`endif

endmodule
