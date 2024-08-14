
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  ring
 - input  vibrate_mode
 - output ringer
 - output motor

The module should implement a circuit to control a cellphone's ringer and
vibration motor. Whenever the phone needs to ring from an incoming call
(input ring), your circuit must either turn on the ringer (output ringer
= 1) or the motor (output motor = 1), but not both. If the phone is in
vibrate mode (input vibrate_mode = 1), turn on the motor. Otherwise, turn
on the ringer.

