
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - input  in (8 bits)
 - output done

The PS/2 mouse protocol sends messages that are three bytes long.
However, within a continuous byte stream, it's not obvious where messages
start and end. The only indication is that the first byte of each three
byte message always has in[3]=1 (but in[3] of the other two bytes may be
1 or 0 depending on data).

The module should implement a finite state machine that will search for
message boundaries when given an input byte stream. The algorithm we'll
use is to discard bytes until we see one with in[3]=1. We then assume
that this is byte 1 of a message, and signal the receipt of a message
once all 3 bytes have been received (done). The FSM should signal done in
the cycle immediately after the third byte of each message was
successfully received. Reset should be active high synchronous. Assume
all sequential logic is triggered on the positive edge of the clock.

