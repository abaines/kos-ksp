@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runoncepath("library").

librarysetup().

print "hello.ks 5".

//global throt to 1.0.
//lock throttle to throt.

global steer to Up + R(0,0,-90).
lock steering to steer.

global sil_steering_angle to slopeInterceptLex2(2000,0,3000,-45,true).

until false
{
	print "speed : " + ship:velocity:surface:mag at(45,0).
	
	//local si_speed to slopeintercept(580,1,680,0).
	//set throt to slopeInterceptValue(si_speed,ship:velocity:surface:mag,true).
	
	local sic_steering_angle to sicslopeInterceptCalc2(sil_steering_angle,ship:altitude)
	set steer  to Up + R( 0,sic_steering_angle ,-90).
	

	wait 0.1.
}

print "hello.ks 5 end".
