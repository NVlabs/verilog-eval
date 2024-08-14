
module RefModule (
  input a,
  input b,
  input sel,
  output out
);

  assign out = sel ? b : a;

endmodule

