
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  areset
 - input  bump_left
 - input  bump_right
 - input  ground
 - input  dig
 - output walk_left
 - output walk_right
 - output aaah
 - output digging

The game Lemmings involves critters with fairly simple brains. So simple
that we are going to model it using a finite state machine. In the
Lemmings' 2D world, Lemmings can be in one of two states: walking left
(walk_left is 1) or walking right (walk_right is 1). It will switch
directions if it hits an obstacle. In particular, if a Lemming is bumped
on the left (by receiving a 1 on bump_left), it will walk right. If it's
bumped on the right (by receiving a 1 on bump_right), it will walk left.
If it's bumped on both sides at the same time, it will still switch
directions.

In addition to walking left and right and changing direction when bumped,
when ground=0, the Lemming will fall and say ""aaah!"". When the ground
reappears (ground=1), the Lemming will resume walking in the same
direction as before the fall. Being bumped while falling does not affect
the walking direction, and being bumped in the same cycle as ground
disappears (but not yet falling), or when the ground reappears while
still falling, also does not affect the walking direction.

In addition to walking and falling, Lemmings can sometimes be told to do
useful things, like dig (it starts digging when dig=1). A Lemming can dig
if it is currently walking on ground (ground=1 and not falling), and will
continue digging until it reaches the other side (ground=0). At that
point, since there is no ground, it will fall (aaah!), then continue
walking in its original direction once it hits ground again. As with
falling, being bumped while digging has no effect, and being told to dig
when falling or when there is no ground is ignored. (In other words, a
walking Lemming can fall, dig, or switch directions. If more than one of
these conditions are satisfied, fall has higher precedence than dig,
which has higher precedence than switching directions.)

Although Lemmings can walk, fall, and dig, Lemmings aren't invulnerable.
If a Lemming falls for too long then hits the ground, it can splatter. In
particular, if a Lemming falls for more than 20 clock cycles then hits
the ground, it will splatter and cease walking, falling, or digging (all
4 outputs become 0), forever (Or until the FSM gets reset). There is no
upper limit on how far a Lemming can fall before hitting the ground.
Lemmings only splatter when hitting the ground; they do not splatter in
mid-air.

Implement a Moore state machine that models this behaviour. areset is
positive edge triggered asynchronous reseting the Lemming machine to walk
left.

Assume all sequential logic is triggered on the positive edge of the
clock.

