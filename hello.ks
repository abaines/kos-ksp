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

rcs off.
sas off.

managePanelsAndAntenna().

manageFuelCells().

global scriptState to lex().
scriptState:add("behavior","d").
scriptState:add("stageAllow",0).
scriptState:add("questThrottle",false).
scriptState:add("electricThrottle",false).
scriptState:add("vesselName",ship:name).
scriptState:add("engineModeAlt",800).

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
	
	print "newchar : " + newchar + "            " at(0,1).
	
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
	if newchar = "k" // kill
	{
		set scriptState["behavior"] to newchar.
	}
	if newchar = "c" // rescue
	{
		set scriptState["behavior"] to newchar.
	}
	if newchar = "y" // waypoint
	{
		set scriptState["behavior"] to newchar.
		unlock THROTTLE.
	}

	if newchar = "z" // unlock
	{
		set throt to 0.0.
		SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
		unlock THROTTLE.
	}
	if newchar = "e" // electric
	{
		set scriptState["electricThrottle"] to not scriptState["electricThrottle"].
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
global sil_steering_alt to slopeInterceptLex2(1000,90,42500,0,true).
global sil_steering_apo to slopeInterceptLex2(1000,90,78000,0,false).

global sil_quest_throttle to slopeInterceptLex2(1240,1,1260,0,true).
global sil_apo_throttle to slopeInterceptLex2(70000,1,78000,0,true).
global sil_eta_apo_throttle to slopeInterceptLex2(0,1,45,0,true).

global sil_electric_throttle to slopeInterceptLex2(0.10,0,0.90,0.02,true).

global launchPad_North to v(0,1,0).
global launchPad_South to v(0,-1,0).
global launchPad_Up to v(462749.88644960814,-1018.0680322776617,-382064.61318457028).
global launchPad_East to vcrs(launchPad_Up,launchPad_North).

// dark orange: desired vector
global desiredVec to V(0,0,0).
global desiredVecDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.5,0.2,0.0), "", 1.0, false,1).
set desiredVecDraw:startupdater to { return ship:position. }.
set desiredVecDraw:vecupdater to { return desiredVec:normalized*600000. }.
//set desiredVecDraw:vecupdater to { return ship:facing:vector:normalized*150. }.


// wait target
global futureTargetTime to 120.
global shipDraw to VECDRAWARGS(body:position, ship:position - body:position, RGB(0,0,1), "", 1.1, true).
global targDraw to VECDRAWARGS(body:position, body:position, RGB(0,1,0), "", 1, true).
global futrDraw to VECDRAWARGS(body:position, body:position, RGB(1,0,0), "", 1, true).

set shipDraw:startupdater to { return body:position. }.
set targDraw:startupdater to { return body:position. }.
set futrDraw:startupdater to { return body:position. }.

set shipDraw:vecupdater to
{
	if scriptState["behavior"] = "c"
	{
		return ship:position - body:position.
	}
	else
	{
		return v(0,0,0).
	}
}.
set targDraw:vecupdater to 
{
	if HASTARGET and scriptState["behavior"] = "c"
	{
		return target:position - body:position.
	}
	else
	{
		return v(0,0,0).
	}
}.
set futrDraw:vecupdater to
{
	if HASTARGET and scriptState["behavior"] = "c"
	{
		return positionat(target,time:seconds + futureTargetTime) - body:position.
	}
	else
	{
		return v(0,0,0).
	}
}.



// waypoint experiments
if false
{
	global testGeo to LATLNG(0,-74).
	global testGeo to LATLNG(-0.03,-74.7).
	//global testGeo to waypoint("TMA"):GEOPOSITION.
	// dark orange: test vector : VECDRAWARGS(start, vec, color, label, scale, show, width)
	global testGeoVecDrawA to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.5,0.2,0.0), "way", 1.0, true,1).
	set testGeoVecDrawA:startupdater to { return ship:position. }.
	set testGeoVecDrawA:vecupdater to { return testGeo:ALTITUDEPOSITION(SHIP:ALTITUDE+900)-SHIP:POSITION. }.

	// dark orange: test vector : VECDRAWARGS(start, vec, color, label, scale, show, width)
	global testGeo0VecDrawA to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.5,0.2,0.9), "", 1.0, true,1).
	set testGeo0VecDrawA:startupdater to { return ship:position. }.
	set testGeo0VecDrawA:vecupdater to { return testGeo:ALTITUDEPOSITION(SHIP:ALTITUDE)-SHIP:POSITION. }.
}




lock electricchargepercent to GetShipResourcePercent("electriccharge").

global experimentState to lex().
experimentState:add("ship:position - body:position",ship:position - body:position).
experimentState:add("ship:name",ship:name).
experimentState:add("SHIP:GEOPOSITION",SHIP:GEOPOSITION).
//experimentState:add("waypoint(TMA):GEOPOSITION",waypoint("TMA"):GEOPOSITION).

global ispData to lex().
global pressureData to lex().

global myEngines to list().
LIST ENGINES IN myEngines.
global engine0 to myEngines[0].

for alti IN RANGE(-1000,10000,100)
{
	local pressure is body:atm:ALTITUDEPRESSURE(alti).
	pressureData:add(alti, pressure).
	ispData:add(alti, engine0:ISPAT(pressure)).
}

if false
{
	experimentState:add("ispData",ispData).
	experimentState:add("pressureData",pressureData).
}

global antennae to ship:partsTagged("a").
// experimentState:add("antennae",antennae).
local a1 to antennae[0].
local m1 to a1:GETMODULE("ModuleRTAntenna").
m1:setField("target","ID Happiness-Sunshine-I Relay").

WRITEJSON(experimentState, "experiment.json").

when false then
{
	experimentState:add("ship:position - body:position",ship:position - body:position).
	WRITEJSON(experimentState, "experiment.json").
	wait 3.
	PRESERVE.
}

print "experimentState written                  " at(0,1).


global hoverEngines to ship:partsTagged("hover").

function hoverThrust
{
	parameter t.
	
	for he in hoverEngines
	{
		set he:thrustlimit to t.
	}
}



when scriptState:HASKEY("engineModeAlt") and scriptState["engineModeAlt"]>0 and SHIP:ALTITUDE>scriptState["engineModeAlt"] then
{
	local modeEngines to 0.
	FOR eng IN myEngines
	{
		if eng:MULTIMODE
		{
			eng:TOGGLEMODE.
			set modeEngines to 1 + modeEngines.
		}
	}.

	local modeEnginesText to "modeEngines#" + modeEngines + "  " + SHIP:ALTITUDE.
	HUDTEXT("" +modeEnginesText+"" , 15, 1, 15, YELLOW, false).
	HUDTEXT("" +modeEnginesText+" ", 15, 2, 15, YELLOW, false).
	HUDTEXT(" "+modeEnginesText+"" , 15, 3, 15, YELLOW, false).
	HUDTEXT(" "+modeEnginesText+" ", 15, 4, 15, YELLOW, false).

	set scriptState["engineModeAlt"] to -1.
	WRITEJSON(scriptState, "1:scriptState.json").

	wait 0.
	PRESERVE.
}


global thrustPID TO PIDLOOP(20, 0, 1/100, 0, 100). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set thrustPID:SETPOINT to -2.

function mainLoop
{
	local behavior is scriptState["behavior"].
	local stageAllow is scriptState["stageAllow"].
	local questThrottle is scriptState["questThrottle"].
	
	print "speed : " + round(ship:velocity:surface:mag,2) + "                 " at(0,3).
	
	if behavior = "y"
	{
		local terrainheight to SHIP:GEOPOSITION:TERRAINHEIGHT.
		local dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - terrainheight).
		set thrustPID:SETPOINT to min(-2,dist2ground / -50).
		local tpid to 1.
		set steer to testGeo:ALTITUDEPOSITION(SHIP:ALTITUDE+900).
		set tpid to thrustPID:update(time:second,ship:VERTICALSPEED).
		hoverThrust(tpid).
		print "tpid: " + round(tpid,4) + "                 " at(0,5).
		print "thrustPID:setpoint: " + round(thrustPID:setpoint,4) + "                 " at(0,6).
		print "hover !                   " at(0,20).
		return.
	}
	
	if questThrottle
	{
		set throt to slopeInterceptCalc2(sil_quest_throttle,velocity:surface:mag).
	}
	else if scriptState["electricThrottle"]
	{
		print "electric charge%: " + round(electricchargepercent*100,3) + "                 " at(0,5).
		print "ship:orbit:period: " + round((ship:orbit:period/(60*60*6))*100,3) + "  " at(0,6).
		
		print "p:" + round(abs(eta_periapsis())) + " a:" + round(abs(eta_apoapsis())) + "  " at(0,2).
		
		if ship:orbit:period >= 60*60*6
		{
			set throt to 0.
		}
		else if abs(eta_periapsis()) > abs(eta_apoapsis()) or ship:APOAPSIS < ship:PERIAPSIS*1.02
		{
			set throt to slopeInterceptCalc2(sil_electric_throttle,electricchargepercent).
		}
		else
		{
			set throt to 0.
		}
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
	print "throt: " + round(throt*100,3) + "                 " at(0,4).
	
	local sic_steering_alt to slopeInterceptCalc2(sil_steering_alt,ship:ALTITUDE).
	local sic_steering_apo to min(slopeInterceptCalc2(sil_steering_apo,ship:APOAPSIS),90).
	
	print "sic_steering_alt : " + sic_steering_alt + "                 " at(0,10).
	print "sic_steering_apo : " + sic_steering_apo + "                 " at(0,11).
	
	local steering_math to max(min(sic_steering_alt, sic_steering_apo),-45).
	print "steering_math : " + steering_math + "                 " at(0,12).
	
	if behavior = "c" and HASTARGET
	{
		local targetFutureDistanceB is (positionat(target,time:seconds + futureTargetTime - 2) - ship:position):mag.
		local targetFutureDistance0 is (positionat(target,time:seconds + futureTargetTime + 0) - ship:position):mag.
		local targetFutureDistanceA is (positionat(target,time:seconds + futureTargetTime + 2) - ship:position):mag.
		print "targetFutureDistance: " + round(targetFutureDistance0,3) + "                 " at(0,5).
		if (targetFutureDistance0 < targetFutureDistanceB and targetFutureDistance0 < targetFutureDistanceA)
		{
			stopwarp().
			stage.
			set scriptState["behavior"] to "d".
		}
	}
	else if behavior = "c"
	{
		// wait for target
		print "waiting for target               " at(0,5).
	}
	else if behavior = "n"
	{
		if ALLNODES:LENGTH>0
		{
			local nextN to nextnode. 
			local burn_vector to nextN:BURNVECTOR.
			set steer to burn_vector.
			sas off.
			print "node time !                   " at(0,20).
		}
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
	else if behavior = "k"
	{
		set steer to "kill".
		print "kill                          " at(0,20).
	}
	else if behavior = "d"
	{
		// using weird command orientation (east)
		//set steer to Up + R(0,(steering_math-90),-90).
		
		// using "accepted" command orientation (east)
		//set steer to Up + R(0,steering_math,180).
		
		// going north/south
		//set steer to Up + R(-1*(steering_math-90),0,180).
		
		//set steer to Up + R(1*(steering_math-90),0,180).
		
		
		// navball angle
		local angle to 90.
		// 45 is north east
		// 90 is east*
		// -90 or 270 is west
		// 0 is north*
		// 180 is south*

		local ns_angle to cos(angle) * (steering_math-90).
		local ew_angle to sin(angle) * (steering_math-90).

		set desiredVec to BetweenVector(v(0,1,0),ship:up:vector,steering_math-90).
		set desiredVec to v(-1,0,-1).
		set desiredVec to v(0,1,0).
		set desiredVec to launchPad_Up.
		
		set desiredVec to BetweenVector(launchPad_north,launchPad_east,angle).
		
		
		// at launch pad
		// v(0,1,0) is north
		// v(-1,0,-1) is up'ish and little west
		
		
		
		if (ship:ALTITUDE<1000)
		{
			//set steer to Up + R(0,0,180). // (default rotation)
			set steer to Up + R(0,0,-90). // (q-rotation)
			print "default ! low                 " at(0,20).
		}
		else
		{
			//set steer to desiredVec.
			//set steer to Up + R(0,steering_math-90,180). // east (probe)
			set steer to Up + R(0,(steering_math-90),-90). // east (q-rotation)
			print "default ! high                " at(0,20).
		}
	}
	else
	{
		print "unknown behavior: " + behavior + "            " at(0,20).
	}
	
	local retroError to vang(ship:facing:vector,-1*ship:srfprograde:vector).
	print "ret err:" + round(retroError,3) + "                 " at(0,8).
	
	
	print "stage allowed "+ stageAllow + "            " at(0,16).
	if stageAllow > 0
	{
		local liquidfuel is GetStageLowestResource("liquidfuel").
		local oxidizer is GetStageLowestResource("oxidizer").
		local solidfuel is GetStageLowestResource("solidfuel").
		local lowestResource is min(solidfuel,min(liquidfuel,oxidizer)).
		print "lowest fuel: " + ROUND(lowestResource,4) + "          " at(0,17).
		
		if liquidfuel<=0.01 or oxidizer<=0.01 or solidfuel<=0.01
		{
			beep(440,0.05,0.001).
			wait 0.1.
			set scriptState["stageAllow"] to scriptState["stageAllow"] - 1.
			stage.
			print "staged                        " at(0,18).
			WRITEJSON(scriptState, "1:scriptState.json").
			print "staged !                      " at(0,18).
		}
	}
}

ag9 on. // on launch pad activate action group 9.

until false
{
	mainLoop().
	wait 0.1.
}

print "default ! derp                " at(0,20).

wait until behavior <> "q".

wait until false.

SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
UNLOCK THROTTLE.

print "hello.ks 10 end".
