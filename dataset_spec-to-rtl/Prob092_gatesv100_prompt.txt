
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  in            (100 bits)
 - output out_both      (100 bits)
 - output out_any       (100 bits)
 - output out_different (100 bits)

The module takes as input a 100-bit input vector in[99:0] and should
produce the following three outputs:

  (1) out_both: Each bit of this output vector should indicate whether
  both the corresponding input bit and its neighbour to the left are '1'.
  For example, out_both[98] should indicate if in[98] and in[99] are both
  1. Since in[99] has no neighbour to the left, the answer is obvious so
  simply set out_both[99] to be zero.

  (2) out_any: Each bit of this output vector should indicate whether any
  of the corresponding input bit and its neighbour to the right are '1'.
  For example, out_any[2] should indicate if either in[2] or in[1] are 1.
  Since in[0] has no neighbour to the right, the answer is obvious so
  simply set out_any[0] to be zero.

  (3) out_different: Each bit of this output vector should indicate
  whether the corresponding input bit is different from its neighbour to
  the left. For example, out_different[98] should indicate if in[98] is
  different from in[99]. For this part, treat the vector as wrapping
  around, so in[99]'s neighbour to the left is in[0].

