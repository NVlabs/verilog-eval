
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - input  in
 - output disc
 - output flag
 - output err

Synchronous HDLC framing involves decoding a continuous bit stream of
data to look for bit patterns that indicate the beginning and end of
frames (packets). Seeing exactly 6 consecutive 1s (i.e., 01111110) is a
"flag" that indicate frame boundaries. To avoid the data stream from
accidentally containing "flags", the sender inserts a zero after every 5
consecutive 1s which the receiver must detect and discard. We also need
to signal an error if there are 7 or more consecutive 1s. Create a
Moore-type finite state machine to recognize these three sequences:

  (1) 0111110: Signal a bit needs to be discarded (disc).
  (2) 01111110: Flag the beginning/end of a frame (flag).
  (3) 01111111...: Error (7 or more 1s) (err).

When the FSM is reset, it should be in a state that behaves as though the
previous input were 0. The reset signal is active high synchronous. The
output signals should be asserted for a complete cycle beginning on the
clock cycle after the condition occurs. Assume all sequential
logic is triggered on the positive edge of the clock.

