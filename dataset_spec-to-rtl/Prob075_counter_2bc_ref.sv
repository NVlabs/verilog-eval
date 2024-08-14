
module RefModule (
  input clk,
  input areset,
  input train_valid,
  input train_taken,
  output logic [1:0] state
);

  always @(posedge clk, posedge areset) begin
    if (areset)
      state <= 1;
    else if (train_valid) begin
      if(state < 3 && train_taken)
        state <= state + 1;
      else if(state > 0 && !train_taken)
        state <= state - 1;
    end
  end

endmodule

