
module RefModule (
  input clk,
  input load,
  input [9:0] data,
  output tc
);

  logic [9:0] count_value;

  always @(posedge clk)
    if(load) count_value <= data;
    else if(count_value != 0) count_value <= count_value - 1;

  assign tc = count_value == 0;

endmodule

