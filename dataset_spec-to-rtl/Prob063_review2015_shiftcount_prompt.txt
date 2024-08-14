
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  shift_ena
 - input  count_ena
 - input  data
 - output q (4 bits)

The module should implement a four-bit shift register that also acts as a
down counter. Data is shifted in most-significant-bit first when
shift_ena is 1. The number currently in the shift register is decremented
when count_ena is 1. Since the full system doesn't ever use shift_ena and
count_ena together, it does not matter what your circuit does if both
control inputs are 1 (this mainly means that it doesn't matter which case
gets higher priority). Assume all sequential logic is triggered on the
positive edge of the clock.

