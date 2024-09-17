
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  load
 - input  data (512 bits)
 - output q    (512 bits)

The module should implement Rule 110, a one-dimensional cellular
automaton with interesting properties (such as being Turing-complete).
There is a one-dimensional array of cells (on or off). At each time step,
the state of each cell changes. In Rule 110, the next state of each cell
depends only on itself and its two neighbours, according to the following
table:

  Left[i+1] | Center[i] | Right[i-1] | Center's next state 
  1         | 1         | 1          | 0
  1         | 1         | 0          | 1
  1         | 0         | 1          | 1
  1         | 0         | 0          | 0
  0         | 1         | 1          | 1
  0         | 1         | 0          | 1
  0         | 0         | 1          | 1
  0         | 0         | 0          | 0

In this circuit, create a 512-cell system (q[511:0]), and advance by one
time step each clock cycle. The synchronous active high load input
indicates the state of the system should be loaded with data[511:0].
Assume the boundaries (q[-1] and q[512], if they existed) are both zero
(off). Assume all sequential logic is triggered on the positive edge of the clock.

