
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  a   (16 bits)
 - input  b   (16 bits)
 - input  c   (16 bits)
 - input  d   (16 bits)
 - input  e   (16 bits)
 - input  f   (16 bits)
 - input  g   (16 bits)
 - input  h   (16 bits)
 - input  i   (16 bits)
 - input  sel ( 4 bits)
 - output out (16 bits)

The module should implement a 16-bit wide, 9-to-1 multiplexer. sel=0
chooses a, sel=1 chooses b, etc. For the unused cases (sel=9 to 15), set
all output bits to '1'.

