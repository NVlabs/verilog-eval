
module RefModule (
  input wire clk,
  input wire reset,
  input wire data,
  output wire [3:0] count,
  output reg counting,
  output reg done,
  input wire ack
);

  typedef enum logic[3:0] {
    S, S1, S11, S110, B0, B1, B2, B3, Count, Wait
  } States;

  States state, next;

  reg shift_ena;
  reg [9:0] fcount;
  reg [3:0] scount;
  wire done_counting = (scount == 0) && (fcount == 999);

  always_comb begin
    case (state)
      S: next = States'(data ? S1: S);
      S1: next = States'(data ? S11: S);
      S11: next = States'(data ? S11 : S110);
      S110: next = States'(data ? B0 : S);
      B0: next = B1;
      B1: next = B2;
      B2: next = B3;
      B3: next = Count;
      Count: next = States'(done_counting ? Wait : Count);
      Wait: next = States'(ack ? S : Wait);
      default: next = States'(4'bx);
    endcase
  end

  always @(posedge clk) begin
    if (reset) state <= S;
    else state <= next;
  end

  always_comb begin
    shift_ena = 0; counting = 0; done = 0;
    if (state == B0 || state == B1 || state == B2 || state == B3)
      shift_ena = 1;
    if (state == Count)
      counting = 1;
    if (state == Wait)
      done = 1;

    if (|state === 1'bx) begin
      {shift_ena, counting, done} = 'x;
    end
  end

  // Shift register
  always @(posedge clk) begin
    if (shift_ena)
      scount <= {scount[2:0], data};
    else if (counting && fcount == 999)
      scount <= scount - 1'b1;
  end

  // Fast counter
  always @(posedge clk)
    if (!counting)
      fcount <= 10'h0;
    else if (fcount == 999)
      fcount <= 10'h0;
    else
      fcount <= fcount + 1'b1;

  assign count = counting ? scount : 'x;

endmodule

