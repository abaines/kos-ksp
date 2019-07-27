@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup(false).

when time:seconds > scriptEpoch + 10 then
{
	set terminal:width  to 42.
	set terminal:height to 20.
}

print("paste.ks 14").

wait 0.

print(CORE:tag).

if core:tag<>"mastercpu"
{
	print("Switching to booster script").
	run booster.
	print("derpy town").
}
else
{
	CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
	print("I'm the Master CPU.").
	global heartGui is createHeartbeatGui().
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
	// Warning: Calling the Stage function on a vessel other than the active vessel will throw an exception.
	unlock steering.
	unlock throttle.
	wait 0.
	UNTIL STAGE:READY { WAIT 0. }
	print("Safe Staging: " + RAP(time:seconds-scriptEpoch,2,6) + "  " + IsActiveVessel()).
	stage.
	wait 0.
}

global prevStageNumber to reallyBigNumber.
when true then
{
	if stage:number<>prevStageNumber
	{
		print("Stage#: " + stage:number).
		set prevStageNumber to stage:number.
	}
	return true. //keep alive
}

lock simplePitch TO 90-((90/100)*((SHIP:APOAPSIS/70000)*100)).

lock steering to HEADING(90,max(0,89.9)).
lock throttle to 1.

wait 0.

safeStage. // warm up nuclear turbojets
lock steering to HEADING(90,max(0,89.9)).
lock throttle to 1.

wait 0.

global thrustIncreaseTime to time:seconds+1.5.
global prevThrust to 0.
when true then
{
	local tct to totalCurrentThrust().

	if tct>prevThrust+0.1
	{
		set thrustIncreaseTime to time:seconds+1.5.
	}
	//print("$ "+RAP(ship:MAXTHRUST,2,7)+ "  " + RAP(tct,2,6) + "  " + RAP(time:seconds-thrustIncreaseTime,2,6)).
	set prevThrust to tct.

	return true. //keep alive
}
when time:seconds>thrustIncreaseTime then
{
	print("time:seconds>thrustIncreaseTime " + RAP(time:seconds-scriptEpoch,0,3)).
	safeStage. // fire main engine for liftoff
	lock steering to HEADING(90,max(0,89.9)).
	lock throttle to 1.
	wait 0.
}

when dist2ground>50 then
{
	print("dist2ground>50").
	lock steering to HEADING(90,max(0,simplePitch)).
}


local fuelLabel to heartGui:addLabel("").
local MANEUVER_TIMELabel to heartGui:addLabel("").
local eta_apoapsisLabel to heartGui:addLabel("").
lock burnTime to MANEUVER_TIME(2296-orbitalSpeed).
lock eta_burn to eta_apoapsis() - burnTime/2.0.
when true then
{
	local burnTime to MANEUVER_TIME(2296-orbitalSpeed).
	set fuelLabel:text to "fuel: "+RAP(GetStageLowestResource("liquidfuel"),2).
	set MANEUVER_TIMELabel:text to "burnTime: "+RAP(burnTime,2).
	set eta_apoapsisLabel:text to "eta_burn: "+RAP(eta_burn,2).

	return true. //keep alive
}

addRevertLaunchButton(heartGui).


local stageProtector to time:seconds + 2.
when GetStageLowestResource("liquidfuel")<=0.1 and time:seconds>stageProtector and STAGE:READY then
{
	wait 0.
	print("stage").
	stage.
	wait 0.

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
	print("modeEngines: "+modeEngines).
	wait 0.
}

wait until SHIP:APOAPSIS>81000 or SHIP:ALTITUDE>70000.

print("Cutting engines and wait for apo burn").
lock throttle to 0.
lock simplePitch to 0.

wait until eta_burn<=0.

print("apo burning").
lock throttle to 1.
lock simplePitch to 0.

wait until SHIP:PERIAPSIS>=70000.

print("Orbit: " + RAP(SHIP:PERIAPSIS)).
lock throttle to 0.
lock simplePitch to 0.

wait 0.

rcs off.
setSasMode("PROGRADE").
abort off.

unlock throttle.
unlock steering.




print("end of file").

// kerbin Orbital velocity (m/s) 2296
