
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  x (4 bits)
 - output f

The module should implement the function f shown in the Karnaugh map
below.

             x[0]x[1]
x[2]x[3]  00  01  11  10
  00     | 1 | 0 | 0 | 1 |
  01     | 0 | 0 | 0 | 0 |
  11     | 1 | 1 | 1 | 0 |
  10     | 1 | 1 | 0 | 1 |

