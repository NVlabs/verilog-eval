
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  areset
 - input  load
 - input  ena
 - input  data (4 bits)
 - output q (4 bits)

The module should implement a 4-bit shift register (right shift), with
asynchronous positive edge triggered areset, synchronous active high
signals load, and enable.

  (1) areset: Resets shift register to zero.

  (2) load: Loads shift register with data[3:0] instead of shifting.

  (3) ena: Shift right (q[3] becomes zero, q[0] is shifted out and
       disappears).

  (4) q: The contents of the shift register. If both the load and ena
       inputs are asserted (1), the load input has higher priority.

Assume all sequential logic is triggered on the positive edge of the
clock.

