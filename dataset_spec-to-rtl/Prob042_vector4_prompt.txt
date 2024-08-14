
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  in  (8  bits)
 - output out (32 bits)

One common place to see a replication operator is when sign-extending a
smaller number to a larger one, while preserving its signed value. This
is done by replicating the sign bit (the most significant bit) of the
smaller number to the left. For example, sign-extending 4'b0101 (5) to 8
bits results in 8'b00000101 (5), while sign-extending 4'b1101 (-3) to 8
bits results in 8'b11111101 (-3). Implement a module that sign-extends an
8-bit number to 32 bits. This requires a concatenation of 24 copies of
the sign bit (i.e., replicate bit[7] 24 times) followed by the 8-bit
number itself.

