
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  in            (4 bits)
 - output out_both      (4 bits)
 - output out_any       (4 bits)
 - output out_different (4 bits)

You are given a four-bit input vector. We want to know some relationships
between each bit and its neighbour:

  (1) out_both: Each bit of this output vector should indicate whether
  both the corresponding input bit and its neighbour to the left (higher
  index) are '1'. For example, out_both[2] should indicate if in[2] and
  in[3] are both 1. Since in[3] has no neighbour to the left, the answer
  is obvious so we don't need to know out_both[3].

  (2) out_any: Each bit of this output vector should indicate whether any
  of the corresponding input bit and its neighbour to the right are '1'.
  For example, out_any[2] should indicate if either in[2] or in[1] are 1.
  Since in[0] has no neighbour to the right, the answer is obvious so we
  don't need to know out_any[0].

  (3) out_different: Each bit of this output vector should indicate
  whether the corresponding input bit is different from its neighbour to
  the left. For example, out_different[2] should indicate if in[2] is
  different from in[3]. For this part, treat the vector as wrapping
  around, so in[3]'s neighbour to the left is in[0].

