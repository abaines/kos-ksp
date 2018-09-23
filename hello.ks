@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runoncepath("library").

librarysetup().

print "hello.ks 8".

//global throt to 1.0.
//lock throttle to throt.

global steer to Up + R(0,0,-90).
lock steering to steer.

// this logic matches navball
global sil_steering_alt to slopeInterceptLex2(1000,90,41000,0,true).
global sil_steering_apo to slopeInterceptLex2(1000,90,80000,0,false).

global behavior to "d".

when terminal:input:haschar then
{
	local newchar is terminal:input:getchar().
	
	print "newchar : " + newchar at(45,0).
	
	if newchar = "r" // retrograde
	{
		set behavior to newchar.
	}
	if newchar = "n" // maneuver node
	{
		set behavior to newchar.
	}
	if newchar = "d" // default behavior
	{
		set behavior to newchar.
	}
	if newchar = "f" // forward horizontal (east)
	{
		set behavior to newchar.
	}
	if newchar = "u" // up (towards sky) (away from planet)
	{
		set behavior to newchar.
	}

	wait 0.
	PRESERVE.
}

until false
{
	print "speed : " + ship:velocity:surface:mag at(45,1).
	
	//local si_speed to slopeintercept(580,1,680,0).
	//set throt to slopeInterceptValue(si_speed,ship:velocity:surface:mag,true).
	
	local sic_steering_alt to slopeInterceptCalc2(sil_steering_alt,ship:ALTITUDE).
	local sic_steering_apo to min(slopeInterceptCalc2(sil_steering_apo,ship:APOAPSIS),90).
	
	print "sic_steering_alt : " + sic_steering_alt at(45,3).
	print "sic_steering_apo : " + sic_steering_apo at(45,4).
	
	local steering_math to (sic_steering_alt + sic_steering_apo) / 2.0.
	print "steering_math : " + steering_math at(45,6).
	
	if behavior = "n"
	{
		local nextN to nextnode. 
		local burn_vector to nextN:BURNVECTOR.
		set steer to burn_vector.
		sas off.
		print "node time !             " at(45,45).
	}
	else if behavior = "r"
	{
		set steer to -1*ship:srfprograde:vector.
		print "retrotime !             " at(45,45).
	}
	else if behavior = "f"
	{
		set steer to Up + R(0,-90,-90).
		print "forward (east) !        " at(45,45).
	}
	else if behavior = "u"
	{
		set steer to Up + R(0,0,-90).
		print "up (away from planet) ! " at(45,45).
	}
	else
	{
		// using weird command orientation (east)
		set steer to Up + R(0,(steering_math-90),-90).
		
		// using "accepted" command orientation (east)
		//set steer to Up + R(0,steering_math,180).
		
		// going north/south
		//set steer to Up + R(-1*(steering_math-90),0,180).
		
		print "default !               " at(45,45).
	}
	

	wait 0.1.
}

print "hello.ks 8 end".
