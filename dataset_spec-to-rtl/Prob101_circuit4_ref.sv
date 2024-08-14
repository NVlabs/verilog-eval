
module RefModule (
  input a,
  input b,
  input c,
  input d,
  output q
);

  assign q = c | b;

endmodule

