
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - input  slowena
 - output q (4 bits)

The module should implement a decade counter that counts from 0 through
9, inclusive, with a period of 10. The reset input is active high
synchronous, and should reset the counter to 0. We want to be able to
pause the counter rather than always incrementing every clock cycle, so
the "slowena" input if high indicates when the counter should increment.
Assume all sequential logic is triggered on the positive edge of the
clock.

