Write a complete Lua script that:

Takes as input:

A chaser's starting position 
(x,y)
(x,y) and constant speed 
vc
v
c
	​

.

A target's starting position 
(x,y)
(x,y) and constant velocity vector 
(vx,vy)
(v
x
	​

,v
y
	​

).

A positive offset distance in meters.

Computes:

The intercept time 
t
t at which the chaser can reach a point offset behind the target along the line from the chaser's start to the target’s position at time 
t
t.

The target’s position at time 
t
t.

The offset point, exactly offset_distance meters behind the target along the same line.

The time it takes for the chaser to reach that offset point (should equal 
t
t).

The heading angle in degrees, where:

0° = North (positive Y-axis)

Angles increase clockwise (East = 90°, South = 180°, West = 270°).

Include:

Vector helper functions for addition, subtraction, scaling, normalization, and magnitude.

A bisection method to solve for 
t
t satisfying the travel-time constraint.

A heading function using atan2 adapted for the specified compass system.

Use this example input inside the script:

Chaser start: (530, 530), speed: 30 m/s

Target start: (500, 500), velocity: (10, 0)

Offset distance: 5 meters

Print:

Intercept time 
t
t

Target position at 
t
t

Offset point coordinates

Chaser's travel time

Heading angle (normalized to [0,360°))

Ensure:

The script is fully self-contained, readable, and well-commented.

Heading calculation is correct for the offset point (not the target’s original position).

Output matches the example:
Intercept time t: 1.029717 seconds
Target position at t: (510.297174, 500.000000)
Offset point: (513.041948, 504.179260)
Chaser's travel time: 1.029717 seconds
Heading angle: 213.295342 degrees
