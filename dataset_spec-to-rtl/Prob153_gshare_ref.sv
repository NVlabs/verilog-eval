
module RefModule (
  input clk,
  input areset,

  input predict_valid,
  input [6:0] predict_pc,
  output predict_taken,
  output [6:0] predict_history,

  input train_valid,
  input train_taken,
  input train_mispredicted,
  input [6:0] train_history,
  input [6:0] train_pc
);

  parameter n = 7;
  logic [1:0] pht [2**n-1:0];

  parameter [1:0] SNT = 0, LNT = 1, LT = 2, ST = 3;

  logic [n-1:0] predict_history_r;
  wire [n-1:0] predict_index = predict_history_r ^ predict_pc;
  wire [n-1:0] train_index = train_history ^ train_pc;

  always@(posedge clk, posedge areset)
    if (areset) begin
      for (integer i=0; i<2**n; i=i+1)
        pht[i] = LNT;
      predict_history_r = 0;
        end  else begin
      if (predict_valid)
        predict_history_r <= {predict_history_r, predict_taken};
      if(train_valid) begin
        if(pht[train_index] < 3 && train_taken)
          pht[train_index] <= pht[train_index] + 1;
        else if(pht[train_index] > 0 && !train_taken)
          pht[train_index] <= pht[train_index] - 1;
        if (train_mispredicted)
          predict_history_r <= {train_history, train_taken};
      end
    end

  assign predict_taken = predict_valid ? pht[predict_index][1] : 1'bx;
  assign predict_history = predict_valid ? predict_history_r : {n{1'bx}};

endmodule

