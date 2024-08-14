
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  a
 - output q

This is a sequential circuit. Read the simulation waveforms to determine
what the circuit does, then implement it.

  time  clk a   q
  0ns   0   x   x
  5ns   1   0   x
  10ns  0   0   x
  15ns  1   0   1
  20ns  0   0   1
  25ns  1   0   1
  30ns  0   0   1
  35ns  1   1   1
  40ns  0   1   1
  45ns  1   1   0
  50ns  0   1   0
  55ns  1   1   0
  60ns  0   1   0
  65ns  1   1   0
  70ns  0   1   0
  75ns  1   1   0
  80ns  0   1   0
  85ns  1   1   0
  90ns  0   1   0

Assume all sequential logic is triggered on the positive edge of the
clock.

