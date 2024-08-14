
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  a
 - input  b
 - input  c
 - input  d
 - output out
 - output out_n

The module should implement the following circuit. Create two
intermediate wires (named anything you want) to connect the AND and OR
gates together. Note that the wire that feeds the NOT gate is really wire
`out`, so you do not necessarily need to declare a third wire here.
Notice how wires are driven by exactly one source (output of a gate), but
can feed multiple inputs.

The circuit is composed of two layers. The first layer, counting from the
input, is two AND gates: one whose input is connected to a and b, and the
second is connected to c and d. The second layer there is an OR gate to
OR the two AND outputs, connected the output 'out'. Additionally, there
is an inverted output 'out_n'.

