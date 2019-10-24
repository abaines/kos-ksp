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
runOncePath("library_vec").

librarysetup(false).

set terminal:height to 70.

when time:seconds > scriptEpoch + 10 then
{
	set terminal:width  to 42.
	set terminal:height to 42.
}

// find: print.*ks.*\d+
print("plane.ks 18").

wait 0.

print(CORE:tag).


CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
print("I'm the Plane CPU.").
global heartGui is gui(200).
addHeartbeatGui(heartGui).
set heartGui:x to -400.
set heartGui:y to 100.
heartGui:show().


///////////////////////////////////////////////////////////////////////////////
/// Plane control /// Plane control /// Plane control /// Plane control ///
///////////////////////////////////////////////////////////////////////////////


sas off.
rcs off.
abort off.
BRAKES on.

managePanelsAndAntenna().

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to totalCurrentThrust() / shipWeight.

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

lock travelDirection to VXCL(vec_up(),ship:srfprograde:vector):normalized.
lock leadDirection to VXCL(vec_up(),ship:facing:vector):normalized.

lock orbitalSpeed to ship:velocity:ORBIT:mag.

local vddTravel is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*25. }, RGB(0.1,0.1,0.1)).

local initialGeoPosition is SHIP:GEOPOSITION.

lock surfaceSpeed to ship:velocity:SURFACE:mag.


function safeStage
{
	parameter msg is "Safe Staging".
	// Warning: Calling the Stage function on a vessel other than the active vessel will throw an exception.
	wait 0.
	UNTIL STAGE:READY { WAIT 0. }
	pwset(msg).
	stage.
	wait 0.
}


global vesselAndPartCheckChecker to 0.
when true then
{
	local vapc to VesselAndPartCheck().
	if vesselAndPartCheckChecker<>vapc
	{
		print(vapc).
	}
	set vesselAndPartCheckChecker to vapc.
	return true. //keep alive
}


global prevStageNumber to reallyBigNumber.
when true then
{
	if stage:number<>prevStageNumber
	{
		pwset("Stage #: " + stage:number).
		set prevStageNumber to stage:number.
	}
	return true. //keep alive
}

lock simplePitch TO 1.

lock steering to HEADING(90.37,max(0,simplePitch)).
lock throttle to 1.


local vddSteeringVector is VECDRAW_DEL({return ship:position.}, {
	local steeringVec to convertToVector(steering).
	return steeringVec:normalized*77.
}, RGB(1,1,0)).


safeStage(). // warm up nuclear turbojets

when surfaceSpeed>30 then
{
	BRAKES off.
	lock simplePitch TO 4.
	pwset("Brakes off @ " + surfaceSpeed).
}

when dist2ground>15 then
{
	gear off.
	lock simplePitch TO 15.
	lock steering to HEADING(90.0,max(0,simplePitch)).
	pwset("Gear off @ " + dist2ground).
}



local fuelLabel to heartGui:addLabel("").
local pitchLabel to heartGui:addLabel("").
local megajoulesLabel to heartGui:addLabel("").
when true then
{
	set fuelLabel:text to "fuel: "+RAP(GetStageLowestResource("liquidfuel"),2).
	set pitchLabel:text to "simplePitch: "+RAP(simplePitch,2).
	set megajoulesLabel:text to "Megajoules: "+ RAP(GetShipResourcePercent("Megajoules")*100,3) + " %".

	return true. //keep alive
}

addRevertLaunchButton(heartGui).


local stageProtector to time:seconds + 2.
when GetStageLowestResource("liquidfuel")<=0.1 and time:seconds>stageProtector and STAGE:READY then
{
	safeStage("Stage empty booster").

	set stageProtector to time:seconds + 2.

	return true. //keep alive
}


autoDecoupleFuel().


pwset("Main script body").


wait until upwardMovement<5 and SHIP:ALTITUDE>1000 and GetShipResourcePercent("Megajoules")>=0.999.


safeStage("No longer gaining altitude").


wait until SHIP:APOAPSIS>68000 or SHIP:ALTITUDE>68000.

pwset("Level off").
lock simplePitch to 0.


wait until SHIP:APOAPSIS>81000 or SHIP:ALTITUDE>70000.

pwset("Coasting to Apo Burn").
lock throttle to 0.
lock simplePitch to 0.

lock burnTime to MANEUVER_TIME(2296-orbitalSpeed).
lock eta_burn to eta_apoapsis() - burnTime/1.75.

wait until eta_burn<=0.

pwset("Apo Burning").
lock throttle to 1.
lock simplePitch to 0.

wait until SHIP:PERIAPSIS>=70000 or ship:status="ORBITING".

pwset("Orbit: " + RAP(SHIP:PERIAPSIS)).
lock throttle to 0.
lock simplePitch to 0.
HUD("ORBIT!" + PSET).

wait 0.

rcs off.
setSasMode("PROGRADE").
abort off.

unlock throttle.
unlock steering.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
set vddSteeringVector:SHOW to false.




pwset("End of Main Script").
until 0 { wait 0. } // main loop wait forever

// kerbin Orbital velocity (m/s) 2296
// 35705.32

