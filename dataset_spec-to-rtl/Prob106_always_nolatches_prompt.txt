
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  scancode (16 bits)
 - output left
 - output down
 - output right
 - output up

The module should process scancodes from a PS/2 keyboard for a game.
Given the last two bytes of scancodes received, you need to indicate
whether one of the arrow keys on the keyboard have been pressed. This
involves a fairly simple mapping, which can be implemented as a case
statement (or if-elseif) with four cases.

  Scancode[15:0] | Arrow key
  16'he06b       | left arrow
  16'he072       | down arrow
  16'he074       | right arrow
  16'he075       | up arrow
  Anything else  | none

Your circuit has one 16-bit input, and four outputs. Build this circuit
that recognizes these four scancodes and asserts the correct output.

