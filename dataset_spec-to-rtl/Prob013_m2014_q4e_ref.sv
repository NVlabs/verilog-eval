
module RefModule (
  input in1,
  input in2,
  output logic out
);

  assign out = ~(in1 | in2);

endmodule

