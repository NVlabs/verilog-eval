
module RefModule (
  input d,
  input done_counting,
  input ack,
  input [9:0] state, // 10-bit one-hot current state
  output B3_next,
  output S_next,
  output S1_next,
  output Count_next,
  output Wait_next,
  output done,
  output counting,
  output shift_ena
);

  parameter S=0, S1=1, S11=2, S110=3, B0=4, B1=5, B2=6, B3=7, Count=8, Wait=9;

  assign B3_next = state[B2];
  assign S_next = state[S]&~d | state[S1]&~d | state[S110]&~d | state[Wait]&ack;
  assign S1_next = state[S]&d;
  assign Count_next = state[B3] | state[Count]&~done_counting;
  assign Wait_next = state[Count]&done_counting | state[Wait]&~ack;

  assign done = state[Wait];
  assign counting = state[Count];
  assign shift_ena = |state[B3:B0];

endmodule

