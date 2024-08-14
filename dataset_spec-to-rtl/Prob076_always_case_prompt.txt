
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  sel   (3 bits)
 - input  data0 (4 bits)
 - input  data1 (4 bits)
 - input  data2 (4 bits)
 - input  data3 (4 bits)
 - input  data4 (4 bits)
 - input  data5 (4 bits)
 - output out   (4 bits)
);

The module should implement a 6-to-1 multiplexer. When sel is between 0
and 5, choose the corresponding data input. Otherwise, output 0. The data
inputs and outputs are all 4 bits wide.

