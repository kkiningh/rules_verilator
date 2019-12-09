`include "assert.svh"

module alu #(parameter int W = 16) (
  input  logic [W-1:0] x,
  input  logic [W-1:0] y,
  output logic [W-1:0] z
);
  assign z = x * y;
endmodule
