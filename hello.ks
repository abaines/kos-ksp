@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runoncepath("library").

librarysetup().

print "hello.ks 7".


//lock steering to 1*ship:srfprograde:vector.

until true
{
	wait 1.
}


//global throt to 1.0.
//lock throttle to throt.

global steer to Up + R(0,0,-90).
lock steering to steer.

global sil_steering_alt to slopeInterceptLex2(1000,0,41000,-90,true).
global sil_steering_apo to slopeInterceptLex2(1000,0,75000,-90,true).

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
	
	local sic_steering_alt to slopeInterceptCalc2(sil_steering_alt,ship:ALTITUDE).
	local sic_steering_apo to slopeInterceptCalc2(sil_steering_apo,ship:APOAPSIS).
	
	print "sic_steering_alt : " + sic_steering_alt at(45,2).
	print "sic_steering_apo : " + sic_steering_apo at(45,3).
	
	local steering_avg to min(sic_steering_alt , sic_steering_apo) .
	print "steering_math : " + steering_avg at(45,5).
	
	if retrotime
	{
		lock steering to -1*ship:srfprograde:vector.
	}
	else
	{
		// using weird command orientation (east)
		// set steer to Up + R(0,steering_avg,-90).
		
		// using "accepted" command orientation (east)
		//set steer to Up + R(0,steering_avg,180).
		
		// going north
		set steer to Up + R(steering_avg,0,180).
	}
	

	wait 0.1.
}

print "hello.ks 7 end".
