
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  load
 - input  ena  (  2 bits)
 - input  data (100 bits)
 - output q    (100 bits)

The module should implement a 100-bit left/right rotator, with
synchronous load and left/right enable. A rotator shifts-in the
shifted-out bit from the other end of the register, unlike a shifter that
discards the shifted-out bit and shifts in a zero. If enabled, a rotator
rotates the bits around and does not modify/discard them.

  (1) load: Loads shift register with data[99:0] instead of rotating.
      Synchronous active high.

  (2) ena[1:0]: Synchronous. Chooses whether and which direction to
      rotate:
      (a) 2'b01 rotates right by one bit,
      (b) 2'b10 rotates left by one bit,
      (c) 2'b00 and 2'b11 do not rotate.

  (3) q: The contents of the rotator.

