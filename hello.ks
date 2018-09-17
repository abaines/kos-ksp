@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runoncepath("library").

librarysetup().

print "hello.ks 4".

global throt to 1.0.
lock throttle to throt.

global steer to Up + R(0,0,-90).
lock steering to steer.

// lock steering to Up + R(0,0,-90).

global desiredSpeed to (580+680)/2.

until ship:altitude>=68000
{

	print "speed   : " + ship:velocity:surface:mag at(45,0).
	
	local si_speed to slopeintercept(580,1,680,0).
	set throt to slopeInterceptValue(si_speed,ship:velocity:surface:mag,true).
	

	wait 0.1.
}

print "hello.ks 4 end".
