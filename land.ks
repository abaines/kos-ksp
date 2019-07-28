@LAZYGLOBAL off.

global scriptEpoch to time:seconds.
lock scriptElapsedTime to time:seconds - scriptEpoch.
lock PSET to " @ " + RAP(scriptElapsedTime,2).

// print with @ script Elapsed Time
function pwset
{
	parameter msg.
	local _pset to PSET.
	local padRequired to 42-_pset:length.
	print(msg:toString:padRight(padRequired)+_pset).
}

runOncePath("library").
runOncePath("library_gui").

librarysetup(false).

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
print("land.ks 16").
print(CORE:tag).
print(calculateGravity()).
print(ship:sensors:grav:mag).

when time:seconds > scriptEpoch + 10 then
{
	set terminal:width  to 42.
	set terminal:height to 20.
}

wait 0.

sas off.
rcs on.
abort off.

managePanelsAndAntenna().
manageFuelCells().



// TODO: make library_vec.ks for vector math functions

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to totalCurrentThrust() / shipWeight.
lock maxTwr to totalMaxThrust() / shipWeight.

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

lock travelDirection to VXCL(vec_up(),ship:srfprograde:vector):normalized.
lock leadDirection to VXCL(vec_up(),ship:facing:vector):normalized.

lock orbitalSpeed to ship:velocity:ORBIT:mag.

local vddSrfPrograde is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
local vddSrfProgradePlane is VECDRAW_DEL({return ship:position.}, { return VXCL(vec_up(),ship:srfprograde:vector):normalized*100. }, RGB(0,1,0.5)).
local vddSrfRetroPlane is VECDRAW_DEL({return ship:position.}, { return VXCL(vec_up(),-1*ship:srfprograde:vector):normalized*100. }, RGB(1,0.5,0)).
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*25. }, RGB(0.1,0.1,0.1)).

local initialGeoPosition is SHIP:GEOPOSITION.



local stopInterceptLex to slopeInterceptLex2(3,0,40,1,true).
function stopVector
{
	// TODO: smarter stop: include small amount of goal
	local sup to ship:up:vector:normalized.

	local destabilizingStr to slopeInterceptCalc2(stopInterceptLex,ship:GROUNDSPEED).

	local retro to -1*ship:velocity:surface:normalized.
	// reverse stabilization
	local retroRatioStabilized to destabilizingStr*retro + sup.
	return retroRatioStabilized:normalized.
}
local vddStopVector is VECDRAW_DEL({return ship:position.}, { return stopVector()*15. }, RGB(1,0.1,0.1)).


lock steering to "kill".
local vddSteeringVector is VECDRAW_DEL({return ship:position.}, { return convertToVector(steering):normalized*17. }, RGB(1,1,0)).

lock steeringError to vang(convertToVector(steering),ship:facing:vector).
local prevSteeringError to 180.
global steeringErrorDelta to 0.
when true then
{
	set steeringErrorDelta to steeringError - prevSteeringError.
	set prevSteeringError to steeringError.
	return true. //keep alive
}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
unlock steering.
unlock throttle.


local HX_HPDs to ship:PARTSDUBBEDPATTERN("HX-HPD Heavy Propulsion Device").
// [0] = "ClosedCycle"
// [1] = "HybridPlasma"
// ideal isp mode switch alt 634.278
if HX_HPDs:length=1
{
	print("Detected: '" + "HX-HPD Heavy Propulsion Device" + "'").
	global HX_HPD to HX_HPDs[0].
}
else
{
	print("HX-HPD Heavy Propulsion Device: " + HX_HPDs:length).
	die.
}



global landGui is gui(220).
set landGui:x to -400.
set landGui:y to 100.
landGui:ADDLABEL("Land GUI").

local modeLayout to landGui:ADDHLAYOUT().
local progradeCheckbox to modeLayout:addcheckbox("Prograde",false).
local retrogradeCheckbox to modeLayout:addcheckbox("Retrograde",false).
local modeSlider to landGui:ADDHSLIDER(1,0,1).

set progradeCheckbox:ontoggle to {
	parameter newstate.
	if newstate{
		print("Prograde").
		lock steering to RatioVector(ship:srfprograde:vector,VXCL(vec_up(),ship:srfprograde:vector),modeSlider:value).
		set retrogradeCheckbox:pressed to false.
		set vddSteeringVector:SHOW to true.
	}
	else if not retrogradeCheckbox:pressed
	{
		print("unlocking").
		unlock steering.
		set vddSteeringVector:SHOW to false.
	}
}.
set retrogradeCheckbox:ontoggle to {
	parameter newstate.
	if newstate{
		print("Retrograde").
		lock steering to RatioVector(-1*ship:srfprograde:vector,stopVector(),modeSlider:value).
		set progradeCheckbox:pressed to false.
		set vddSteeringVector:SHOW to true.
	}
	else if not progradeCheckbox:pressed
	{
		print("unlocking").
		unlock steering.
		set vddSteeringVector:SHOW to false.
	}
}.

local landThrottleCheckbox to landGui:addcheckbox("Land Throttle",false).
set landThrottleCheckbox:ontoggle to {
	parameter newstate.
	if newstate
	{
		print("Land Throttle").
	}
	else
	{
		print("unlock throttle").
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
		unlock throttle.
	}
}.

local engineModeButton to landGui:addbutton("engineModeCheckbox").
set engineModeButton:onclick to {
	HX_HPD:TOGGLEMODE.
}.

local gforceLabel to landGui:ADDLABEL("g-force").
local steeringErrorLabel to landGui:ADDLABEL("steeringErrorLabel").

// TODO: engine mode toggle
// TODO: adjust landing math
// TODO: deploy heatshield
// TODO: auto engine mode (detect engine mode?)
// TODO: track acc, if over 2 trigger followed by less then 1 -> flip operation
// 0.005860315 x + 281.05406
// 0.085114108x  + 230.78512
// ideal isp mode switch alt 634.278

addRevertLaunchButton(landGui).
landGui:show().

wait 0.
set retrogradeCheckbox:pressed to true.


global twrPID TO PIDLOOP(17, 8, 1, 0, 1). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
global deltaAltPID TO PIDLOOP(0.1, 0.005, 0.025, 0.1, 10). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
local landRateInterceptLex to slopeInterceptLex2(25,-50,200,-12.5,true).

// GUI updates
when true then
{
	set gforceLabel:text to "acc: " + RAP(ship:sensors:acc:mag/ship:sensors:grav:mag,3).
	set steeringErrorLabel:text to "steering err: " + RAP(steeringError,3,6) + "   " + RAP(steeringErrorDelta,3).
	set engineModeButton:text to ""+HX_HPD:mode.

	return true. //keep alive
}

// throttle PIDs
when landThrottleCheckbox:pressed then
{
	lock throttle to twrPID:update(time:second,twr).
	set deltaAltPID:MAXOUTPUT to maxTwr*1.1.
	set twrPID:SETPOINT to deltaAltPID:update(time:second,upwardMovement).
	set deltaAltPID:SETPOINT to dist2ground/slopeInterceptCalc2(landRateInterceptLex,dist2ground).

	return true. //keep alive
}


// RCS controller
function rcsController
{
	if progradeCheckbox:pressed or retrogradeCheckbox:pressed
	{
		if SHIP:ALTITUDE < 60_000
		{
			if steeringError>1 and steeringErrorDelta>0
			{
				rcs on.
				return.
			}
			else if steeringError>3
			{
				rcs on.
				return.
			}
		}
	}

	// else
	rcs off.
}
// RCS controller
when true then
{
	rcsController().
	return true. //keep alive
}



local prevStatus is "".
when ship:status<>prevStatus then
{
	pwset(ship:status).
	set prevStatus to ship:status.
	return true. //keep alive
}


pwset("Script loaded").
until 0 { wait 0. } // main loop wait forever

///////////////////////////////////////////////////////////////////////////////
//// Wait Forever ///// Wait Forever ///// Wait Forever ///// Wait Forever ////
///////////////////////////////////////////////////////////////////////////////





// target draw
global geo_ksc to LATLNG(0,-74).
lock ksc_vec to (geo_ksc:POSITION - ship:position).
global targDraw to VECDRAWARGS(ship:position, ship:position, RGB(1,0,0), "", 1, true).
set targDraw:startupdater to { return ship:position. }.
set targDraw:vecupdater to { return ksc_vec. }.

lock steering to "kill".

if ship:PERIAPSIS > 40000
{
	lock steering to -1*ship:prograde:vector.
}

until vang(ship:facing:vector,-1*ship:prograde:vector) < 5 or ship:PERIAPSIS < 40000
{
	print vang(ship:facing:vector,-1*ship:prograde:vector) at (45,9).
	wait 0.
}


global prevKscDist is 2147483646.

until (geo_ksc:distance - prevKscDist < 0
		and prevKscDist < 2147483646
		and geo_ksc:distance<1400000
		and geo_ksc:distance>600000)
		or ship:PERIAPSIS < 40000
{
	print geo_ksc:distance at (45,10).
	print geo_ksc:distance - prevKscDist at (45,11).

	set prevKscDist to geo_ksc:distance.
	wait 0.
}

stopwarp().

wait 1.

until vang(ship:facing:vector,-1*ship:prograde:vector) < 5 or ship:PERIAPSIS < 40000
{
	print vang(ship:facing:vector,-1*ship:prograde:vector) at(45,13).
	wait 0.
}

wait 1.

lock throttle to 1.

until ship:PERIAPSIS < 40000
{
	print ship:PERIAPSIS at (45,15).
	wait 0.
}

// path good
lock throttle to 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
unlock throttle.


global landMode is 0.

if landMode = 0
{
	// retrograde
	lock steering to -1*ship:srfprograde:vector.
}
if landMode = 1
{
	// forward horizon
	lock steering to vcrs(vcrs(ship:up:vector,ship:srfprograde:vector),ship:up:vector).
}
if landMode = 2
{
	// backward horizon
	lock steering to vcrs(vcrs(ship:up:vector,-1*ship:srfprograde:vector),ship:up:vector).
}

print landMode.


when ship:ALTITUDE < 70000 then
{
	stopwarp().
	RCS ON.
	panels off.
}

when ship:ALTITUDE < 2000 then
{
	lock steering to up.
}

global prevSpeed is 0.

global happy is 0.
until happy>1000
{
	if ship:velocity:surface:mag < 1
	{
		set happy to 1 + happy.
		print happy at (45,20).
	}
	else
	{
		set happy to 0.
		print "speed   : " + ship:velocity:surface:mag at (45,21).
		print "alt     : " + ship:ALTITUDE  at (45,22).
	}

	print "d-speed : " + (ship:velocity:surface:mag-prevSpeed) at (45,24).
	set prevSpeed to ship:velocity:surface:mag.

	wait 0.
}
