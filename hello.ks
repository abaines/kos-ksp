@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runoncepath("library").

librarysetup().

print "hello.ks 6".

//global throt to 1.0.
//lock throttle to throt.

global steer to Up + R(0,0,-90).
lock steering to steer.

global sil_steering_angle to slopeInterceptLex2(1000,0,40000,-60,true).

global retrotime to false.

when terminal:input:haschar then
{
	local newchar is terminal:input:getchar().
	
	print "newchar : " + newchar at(45,2).
	
	if newchar = "r"
	{
		set retrotime to true.
		print "retrotime ! " at(45,3).
	}

	wait 0.
	PRESERVE.
}

until false
{
	print "speed : " + ship:velocity:surface:mag at(45,0).
	
	//local si_speed to slopeintercept(580,1,680,0).
	//set throt to slopeInterceptValue(si_speed,ship:velocity:surface:mag,true).
	
	local sic_steering_angle to slopeInterceptCalc2(sil_steering_angle,ship:ALTITUDE).
	
	print "sic_steering_angle : " + sic_steering_angle at(45,1).
	
	if retrotime
	{
		lock steering to -1*ship:srfprograde:vector.
	}
	else
	{
		set steer to Up + R(0,sic_steering_angle,-90).
	}
	

	wait 0.1.
}

print "hello.ks 6 end".
