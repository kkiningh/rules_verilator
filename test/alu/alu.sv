`include "assert.svh"

module alu #(parameter int W = 16) (
  input  logic [W-1:0] x,
  input  logic [W-1:0] y,
  output logic [W-1:0] z
);


  wire [15:0] temp;
  alu2 #(.W(16))
  tmod(
    .x(x),
    .y(y),
    .z(temp));


  assign z = x * temp;
endmodule
