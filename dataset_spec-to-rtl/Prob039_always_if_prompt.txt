
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  a
 - input  b
 - input  sel_b1
 - input  sel_b2
 - output out_assign
 - output out_always

The module should implement a 2-to-1 mux that chooses between a and b.
Choose b if both sel_b1 and sel_b2 are true. Otherwise, choose a. Do the
same twice, once using assign statements and once using a procedural if
statement.

