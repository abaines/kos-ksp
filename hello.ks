@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runoncepath("library").

librarysetup().

set terminal:width to 45.
set terminal:height to 20.

print "hello.ks 10" at(0,0).
print "hello.ks 10" at(0,21).

global throt to 0.0.
lock throttle to throt.

global steer to "kill".
lock steering to steer.


global scriptState to lex().
scriptState:add("behavior","d").
scriptState:add("stageAllow",2).
scriptState:add("questThrottle",false).

if exists("1:scriptState.json")
{
	local jsonRead TO READJSON("1:scriptState.json").
	FOR key IN jsonRead:KEYS
	{
		set scriptState[key] to jsonRead[key].
	}
}


when terminal:input:haschar then
{
	local newchar is terminal:input:getchar().
	
	print "newchar : " + newchar at(0,1).
	
	if newchar = "t" // target
	{
		set scriptState["behavior"] to newchar.
	}
	if newchar = "r" // retrograde
	{
		set scriptState["behavior"] to newchar.
	}
	if newchar = "p" // prograde
	{
		set scriptState["behavior"] to newchar.
	}
	if newchar = "n" // maneuver node
	{
		set scriptState["behavior"] to newchar.
	}
	if newchar = "d" // default behavior
	{
		set scriptState["behavior"] to newchar.
		unlock THROTTLE.
	}
	if newchar = "f" // forward horizontal (east)
	{
		set scriptState["behavior"] to newchar.
	}
	if newchar = "b" // backward horizontal (west)
	{
		set scriptState["behavior"] to newchar.
	}
	if newchar = "u" // up (towards sky) (away from planet)
	{
		set scriptState["behavior"] to newchar.
	}

	if newchar = "s" // stage
	{
		set scriptState["stageAllow"] to scriptState["stageAllow"] + 1.
	}
	if newchar = "q" // quest
	{
		set scriptState["questThrottle"] to not scriptState["questThrottle"].
	}
	
	WRITEJSON(scriptState, "1:scriptState.json").

	wait 0.
	PRESERVE.
}

// this logic matches navball
global sil_steering_alt to slopeInterceptLex2(1000,90,40000,0,true).
global sil_steering_apo to slopeInterceptLex2(1000,90,76000,0,false).

global sil_quest_throttle to slopeInterceptLex2(1240,1,1260,0,true).
global sil_apo_throttle to slopeInterceptLex2(70000,1,76000,0,true).
global sil_eta_apo_throttle to slopeInterceptLex2(0,1,45,0,true).

until false
{
	local behavior is scriptState["behavior"].
	local stageAllow is scriptState["stageAllow"].
	local questThrottle is scriptState["questThrottle"].
	
	print "speed : " + ship:velocity:surface:mag at(0,3).
	
	if questThrottle
	{
		set throt to slopeInterceptCalc2(sil_quest_throttle,velocity:surface:mag).
	}
	else if behavior = "r" or behavior = "b"  or behavior = "u" 
	{
		
	}
	else if behavior <> "d"
	{
		// bad state
	}
	else if ship:ALTITUDE < 70000
	{
		set throt to slopeInterceptCalc2(sil_apo_throttle,ship:APOAPSIS).
	}
	else if ship:PERIAPSIS < 75000
	{
		set throt to slopeInterceptCalc2(sil_eta_apo_throttle,eta_apoapsis()).
	}
	else
	{
		set throt to 0.
	}
	print throt + "            " at(0,4).
	
	local sic_steering_alt to slopeInterceptCalc2(sil_steering_alt,ship:ALTITUDE).
	local sic_steering_apo to min(slopeInterceptCalc2(sil_steering_apo,ship:APOAPSIS),90).
	
	print "sic_steering_alt : " + sic_steering_alt at(0,10).
	print "sic_steering_apo : " + sic_steering_apo at(0,11).
	
	local steering_math to max(min(sic_steering_alt, sic_steering_apo),-45).
	print "steering_math : " + steering_math at(0,12).
	
	
	if behavior = "n"
	{
		local nextN to nextnode. 
		local burn_vector to nextN:BURNVECTOR.
		set steer to burn_vector.
		sas off.
		print "node time !                   " at(0,20).
	}
	else if behavior = "r"
	{
		set steer to -1*ship:srfprograde:vector.
		print "retrotime !                   " at(0,20).
	}
	else if behavior = "p"
	{
		set steer to 1*ship:srfprograde:vector.
		print "prograde !                    " at(0,20).
	}
	else if behavior = "f"
	{
		set steer to Up + R(0,-90,-90).
		print "forward (east) !              " at(0,20).
	}
	else if behavior = "b"
	{
		set steer to Up + R(0,90,90).
		print "backward (west) !             " at(0,20).
	}
	else if behavior = "u"
	{
		set steer to Up + R(0,0,-90).
		print "up (away from planet) !       " at(0,20).
	}
	else if behavior = "t"
	{
		if hastarget
		{
			set steer to (target:position - ship:position).
			print "target !                      " at(0,20).
		}
	}
	else
	{
		// using weird command orientation (east)
		//set steer to Up + R(0,(steering_math-90),-90).
		
		// using "accepted" command orientation (east)
		//set steer to Up + R(0,steering_math,180).
		
		// going north/south
		//set steer to Up + R(-1*(steering_math-90),0,180).
		
		//set steer to Up + R(1*(steering_math-90),0,180).
		
		// south east
		set steer to Up + R(-1*(steering_math-90),1*(steering_math-90),180).
		
		print "default !                     " at(0,20).
	}
	
	local retroError to vang(ship:facing:vector,-1*ship:srfprograde:vector).
	print retroError + "               " at(0,8).
	
	
	if stageAllow > 0
	{
		print "stage allowed "+ stageAllow + "            " at(0,16).
		local liquidfuel is GetStageLowestResource("liquidfuel").
		local oxidizer is GetStageLowestResource("oxidizer").
		local solidfuel is GetStageLowestResource("solidfuel").
		print "" + ROUND(liquidfuel,4) + " " +  ROUND(oxidizer,4) + " " +  ROUND(solidfuel,4) + "          " at(0,17).
		
		if liquidfuel<=0.01 or oxidizer<=0.01 or solidfuel<=0.01
		{
			beep(440,0.05,0.001).
			wait 0.1.
			set scriptState["stageAllow"] to scriptState["stageAllow"] - 1.
			stage.
			WRITEJSON(scriptState, "1:scriptState.json").
			print "staged !                      " at(0,18).
		}
	}
	

	wait 0.1.
}

wait until behavior <> "q".

SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
UNLOCK THROTTLE.

print "hello.ks 10 end".
