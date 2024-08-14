
module RefModule (
  input mode,
  input too_cold,
  input too_hot,
  input fan_on,
  output heater,
  output aircon,
  output fan
);

  assign fan = (mode ? too_cold : too_hot) | fan_on;
  assign heater = (mode & too_cold);
  assign aircon = (~mode & too_hot);

endmodule

