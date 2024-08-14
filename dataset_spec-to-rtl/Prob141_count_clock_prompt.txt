
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - input  ena
 - output pm
 - output hh (8 bits)
 - output mm (8 bits)
 - output ss (8 bits)

Create a set of counters suitable for use as a 12-hour clock (with am/pm
indicator). Your counters are clocked by a fast-running clk, with a pulse
on ena whenever your clock should increment (i.e., once per second, while
"clk" is much faster than once per second). The signal "pm" is asserted
if the clock is PM, or is otherwise AM. hh, mm, and ss are two BCD
(Binary- Coded Decimal) digits each for hours (01-12), minutes (00-59),
and seconds (00-59). Reset is the active high synchronous signal that
resets the clock to "12:00 AM." Reset has higher priority than enable and
can occur even when not enabled. Assume all sequential logic is triggered
on the positive edge of the clock.

