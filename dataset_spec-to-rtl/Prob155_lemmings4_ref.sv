
module RefModule (
  input clk,
  input areset,
  input bump_left,
  input bump_right,
  input ground,
  input dig,
  output walk_left,
  output walk_right,
  output aaah,
  output digging
);

  parameter WL=0, WR=1, FALLL=2, FALLR=3, DIGL=4, DIGR=5, DEAD=6;
  reg [2:0] state;
  reg [2:0] next;

  reg [4:0] fall_counter;

  always_comb begin
    case (state)
      WL: if (!ground) next = FALLL;
        else if (dig) next = DIGL;
        else if (bump_left) next = WR;
        else next = WL;
      WR:
        if (!ground) next = FALLR;
        else if (dig) next = DIGR;
        else if (bump_right) next = WL;
        else next = WR;
      FALLL: next = ground ? (fall_counter >= 20 ? DEAD : WL) : FALLL;
      FALLR: next = ground ? (fall_counter >= 20 ? DEAD : WR) : FALLR;
      DIGL: next = ground ? DIGL : FALLL;
      DIGR: next = ground ? DIGR : FALLR;
      DEAD: next = DEAD;
    endcase
  end

  always @(posedge clk, posedge areset) begin
    if (areset) state <= WL;
      else state <= next;
  end

  always @(posedge clk) begin
    if (state == FALLL || state == FALLR) begin
      if (fall_counter < 20)
        fall_counter <= fall_counter + 1'b1;
    end
    else
      fall_counter <= 0;
  end

  assign walk_left = (state==WL);
  assign walk_right = (state==WR);
  assign aaah = (state == FALLL) || (state == FALLR);
  assign digging = (state == DIGL) || (state == DIGR);

endmodule

