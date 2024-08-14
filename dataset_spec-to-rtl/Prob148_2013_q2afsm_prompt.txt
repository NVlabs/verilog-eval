
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  resetn
 - input  r (3 bits)
 - output g (3 bits)

The module should implement the FSM described by the state diagram shown
below:

  A        --r0=0,r1=0,r2=0--> A
  A        -------r0=1-------> B
  A        -----r0=0,r1=1----> C
  A        --r0=0,r1=0,r2=0--> D
  B (g0=1) -------r0=1-------> B
  B (g0=1) -------r0=0-------> A
  C (g1=1) -------r1=1-------> C
  C (g1=1) -------r1=0-------> A

Resetn is an active-low synchronous reset that resets into state A. This
FSM acts as an arbiter circuit, which controls access to some type of
resource by three requesting devices. Each device makes its request for
the resource by setting a signal _r[i]_ = 1, where _r[i]_ is either
_r[0]_, _r[1]_, or _r[2]_. Each r[i] is an input signal to the FSM, and
represents one of the three devices. The FSM stays in state _A_ as long
as there are no requests. When one or more request occurs, then the FSM
decides which device receives a grant to use the resource and changes to
a state that sets that device's _g[i]_ signal to 1. Each _g[i]_ is an
output from the FSM. There is a priority system, in that device 0 has a
higher priority than device 1, and device 2 has the lowest priority.
Hence, for example, device 2 will only receive a grant if it is the only
device making a request when the FSM is in state _A_. Once a device, _i_,
is given a grant by the FSM, that device continues to receive the grant
as long as its request, _r[i]_ = 1.

Implement a module that represents this FSM. Use separate always blocks
for the state table and the state flip-flops, as done in lectures.
Describe the FSM outputs, _g[i]_, using either continuous assignment
statement(s) or an always block (at your discretion). Assign any state
codes that you wish to use. Assume all sequential logic is triggered on
the positive edge of the clock.

