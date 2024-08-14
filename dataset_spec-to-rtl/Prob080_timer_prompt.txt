
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk,
 - input  load,
 - input  data (10 bits)
 - output tc

The module should implement a timer that counts down for a given number
of clock cycles, then asserts a signal to indicate that the given
duration has elapsed. A good way to implement this is with a down-counter
that asserts an output signal when the count becomes 0. At each clock
cycle:

  (1) If load = 1, load the internal counter with the 10-bit data, the
  number of clock cycles the timer should count before timing out. The
  counter can be loaded at any time, including when it is still counting
  and has not yet reached 0.

  (2) If load = 0, the internal counter should decrement by 1. The output
  signal tc ("terminal count") indicates whether the internal counter has
  reached 0. Once the internal counter has reached 0, it should stay 0
  (stop counting) until the counter is loaded again.

The module should implement a single D flip-flop. Assume all sequential
logic is triggered on the positive edge of the clock.

