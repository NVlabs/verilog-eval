
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  a
 - input  b
 - input  c
 - input  d
 - output out

The module should implement the Karnaugh map below.

             ab
  cd   00  01  11  10
  00 | 0 | 1 | 0 | 1 |
  01 | 1 | 0 | 1 | 0 |
  11 | 0 | 1 | 0 | 1 |
  10 | 1 | 0 | 1 | 0 |

