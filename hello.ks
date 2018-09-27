@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runoncepath("library").

librarysetup().

print "hello.ks 9".

global throt to 0.5.
if false
{
	lock throttle to throt.
}

global steer to Up + R(0,0,-90).
lock steering to steer.

global behavior to "d".

when terminal:input:haschar then
{
	local newchar is terminal:input:getchar().
	
	print "newchar : " + newchar at(45,0).
	
	if newchar = "t" // target
	{
		set behavior to newchar.
	}
	if newchar = "r" // retrograde
	{
		set behavior to newchar.
	}
	if newchar = "p" // prograde
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
		unlock THROTTLE.
	}
	if newchar = "f" // forward horizontal (east)
	{
		set behavior to newchar.
	}
	if newchar = "b" // backward horizontal (west)
	{
		set behavior to newchar.
	}
	if newchar = "u" // up (towards sky) (away from planet)
	{
		set behavior to newchar.
	}
	if newchar = "q" // quest
	{
		set behavior to newchar.
		lock THROTTLE to sic_speed.
	}

	wait 0.
	PRESERVE.
}

// this logic matches navball
global sil_steering_alt to slopeInterceptLex2(1000,90,41000,0,true).
global sil_steering_apo to slopeInterceptLex2(1000,90,80000,0,false).

local sil_speed to slopeInterceptLex2(1240,1,1260,0,true).


until false
{
	print "speed : " + ship:velocity:surface:mag at(45,1).
	
	set throt to slopeInterceptCalc2(sil_speed,velocity:surface:mag).
	print throt + "            " at(45,42).
	
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
	else if behavior = "p"
	{
		set steer to 1*ship:srfprograde:vector.
		print "prograde !              " at(45,45).
	}
	else if behavior = "f"
	{
		set steer to Up + R(0,-90,-90).
		print "forward (east) !        " at(45,45).
	}
	else if behavior = "b"
	{
		set steer to Up + R(0,90,90).
		print "backward (west) !       " at(45,45).
	}
	else if behavior = "u"
	{
		set steer to Up + R(0,0,-90).
		print "up (away from planet) ! " at(45,45).
	}
	else if behavior = "t"
	{
		set steer to (target:position - ship:position).
		print "target !                " at(45,45).
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

wait until behavior <> "q".

SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
UNLOCK THROTTLE.

print "hello.ks 9 end".
