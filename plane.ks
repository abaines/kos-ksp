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

when time:seconds > scriptEpoch + 10 then
{
	set terminal:width  to 42.
	set terminal:height to 42.
}

print("multiStageLauncher.ks 14").

wait 0.

print(CORE:tag).

if core:tag<>"mastercpu"
{
	print("Switching to booster script").
	run booster.
	print("derpy town").
	die. // TODO: something better
}
else
{
	CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
	print("I'm the Master CPU.").
	global heartGui is gui(200).
	addHeartbeatGui(heartGui).
	set heartGui:x to -400.
	set heartGui:y to 100.
	heartGui:show().
}


///////////////////////////////////////////////////////////////////////////////
/// Master control /// Master control /// Master control /// Master control ///
///////////////////////////////////////////////////////////////////////////////

setLoadDistances(32).

sas off.
rcs on.
abort off.

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

lock simplePitch TO 90-((90/100)*((SHIP:APOAPSIS/70000)*100)).

lock steering to HEADING(90,max(0,simplePitch)).
lock throttle to 1.


local vddSteeringVector is VECDRAW_DEL({return ship:position.}, {
	local steeringVec to convertToVector(steering).
	return steeringVec:normalized*17.
}, RGB(1,1,0)).


safeStage(). // warm up nuclear turbojets


global thrustIncreaseTime to time:seconds+1.5.
global prevThrust to 0.
when true then
{
	local tct to totalCurrentThrust().

	if tct>prevThrust+0.1
	{
		set thrustIncreaseTime to time:seconds+1.5.
	}
	set prevThrust to tct.

	return true. //keep alive
}
when time:seconds>thrustIncreaseTime then
{
	safeStage("time:seconds>thrustIncreaseTime"). // fire main engine for liftoff
}



local fuelLabel to heartGui:addLabel("").
local MANEUVER_TIMELabel to heartGui:addLabel("").
local eta_apoapsisLabel to heartGui:addLabel("").
local pitchLabel to heartGui:addLabel("").
lock burnTime to MANEUVER_TIME(2296-orbitalSpeed).
lock eta_burn to eta_apoapsis() - burnTime/1.75.
when true then
{
	local burnTime to MANEUVER_TIME(2296-orbitalSpeed).
	set fuelLabel:text to "fuel: "+RAP(GetStageLowestResource("liquidfuel"),2).
	set MANEUVER_TIMELabel:text to "burnTime: "+RAP(burnTime,2).
	set eta_apoapsisLabel:text to "eta_burn: "+RAP(eta_burn,2).
	set pitchLabel:text to "simplePitch: "+RAP(simplePitch,2).

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

when stage:number=0 then
{
	wait 0.
	local modeEngines to 0.
	FOR eng IN listEngines()
	{
		if eng:MULTIMODE
		{
			eng:TOGGLEMODE.
			set modeEngines to 1 + modeEngines.
		}
	}.
	pwset("modeEngines: "+modeEngines).
	wait 0.
}

pwset("Main script body").

wait until SHIP:APOAPSIS>81000 or SHIP:ALTITUDE>70000.

if stage:ready
{
	safeStage("Stage space booster").
}

pwset("Coasting to Apo Burn").
lock throttle to 0.
lock simplePitch to 0.

wait until eta_burn<=0.

pwset("Apo Burning").
lock throttle to 1.
lock simplePitch to 0.


when SHIP:PERIAPSIS>=70000 or ship:status="ORBITING" then
{
	HUD("ORBIT!" + PSET).
}

wait until SHIP:PERIAPSIS>=70000 or ship:status="ORBITING".

pwset("Orbit: " + RAP(SHIP:PERIAPSIS)).
lock throttle to 0.
lock simplePitch to 0.

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

