
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  areset
 - input  bump_left
 - input  bump_right
 - output walk_left
 - output walk_right

The module should implement a simple game called Lemmings which involves
critters with fairly simple brains. So simple that we are going to model
it using a finite state machine. In the Lemmings' 2D world, Lemmings can
be in one of two states: walking left (walk_left is 1) or walking right
(walk_right is 1). It will switch directions if it hits an obstacle. In
particular, if a Lemming is bumped on the left (by receiving a 1 on
bump_left), it will walk right. If it's bumped on the right (by receiving
a 1 on bump_right), it will walk left. If it's bumped on both sides at
the same time, it will still switch directions.

The module should implement a Moore state machine with two states, two
inputs, and one output (internal to the module) that models this
behaviour. areset is positive edge triggered asynchronous resetting the
Lemming machine to walk left. Assume all sequential logic is triggered on
the positive edge of the clock.

