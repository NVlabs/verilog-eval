
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - input  x
 - output z

The module should implement a finite-state machine with the
state-assigned table shown below. Reset should synchronous active high
reset the FSM to state 000. Assume all sequential logic is triggered on
the positive edge of the clock.

  Present state y[2:0] | Next state y[2:0] x=0, Next state y[2:0] x=1 | Output z
  000 | 000, 001 | 0
  001 | 001, 100 | 0
  010 | 010, 001 | 0
  011 | 001, 010 | 1
  100 | 011, 100 | 1

