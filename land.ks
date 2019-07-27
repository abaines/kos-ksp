@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup(false).

print("land.ks 16").
print(CORE:tag).

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


SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
unlock steering.
unlock throttle.


global landGui is gui(200).
landGui:ADDLABEL("Land GUI").

local modeLayout to landGui:ADDHLAYOUT().
local progradeCheckbox to modeLayout:addcheckbox("Prograde",false).
local retrogradeCheckbox to modeLayout:addcheckbox("Retrograde",false).
local modeSlider to landGui:ADDHSLIDER(50,0,100).
local landThrottleCheckbox to landGui:addcheckbox("Land Throttle",false).

addRevertLaunchButton(landGui).
landGui:show().





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
