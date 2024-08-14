
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - input  in    (32 bits)
 - output out   (32 bits)

The module should examine each bit in the 32-bit input vector, and
capture when the input signal changes from 1 in one clock cycle to 0 the
next. "Capture" means that the output will remain 1 until the register is
reset (active high synchronous reset). Assume all sequential logic is
triggered on the positive edge of the clock.

