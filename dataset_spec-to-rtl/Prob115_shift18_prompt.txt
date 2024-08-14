
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  load
 - input  ena
 - input  amount (2 bits)
 - input  data (64 bits)
 - output q (64 bits)

The module should implement a 64-bit arithmetic shift register, with
synchronous load. The shifter can shift both left and right, and by 1 or
8 bit positions, selected by "amount." Assume the right shit is an
arithmetic right shift.

Signals are defined as below:

  (1) load: Loads shift register with data[63:0] instead of shifting.
       Active high.
  (2) ena: Chooses whether to shift. Active high.
  (3) amount: Chooses which direction and how much to shift.
      (a) 2'b00: shift left by 1 bit.
      (b) 2'b01: shift left by 8 bits.
      (c) 2'b10: shift right by 1 bit.
      (d) 2'b11: shift right by 8 bits.
  (4) q: The contents of the shifter.

