@LAZYGLOBAL off.

global scriptEpoch to time:seconds.
lock scriptElapsedTime to time:seconds - scriptEpoch.
lock PSET to " @ " + RAP(scriptElapsedTime,2).

runOncePath("library").
runOncePath("library_gui").

librarysetup(false).

when time:seconds > scriptEpoch + 10 then
{
	set terminal:width  to 42.
	set terminal:height to 20.
}

print "booster.ks 15".



// wait until we are the only cpu core
until getCpuCoreCount()<=1 { wait 0. }



print("I'm in control now!").
local heartGui is gui(200).
addHeartbeatGui(heartGui).
set heartGui:x to 400.
set heartGui:y to 100.
heartGui:show().


///////////////////////////////////////////////////////////////////////////////////////////////////
/// Booster control /// Booster control /// Booster control /// Booster control /// Booster control
///////////////////////////////////////////////////////////////////////////////////////////////////


lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to totalCurrentThrust() / shipWeight.

lock maxTwr to totalMaxThrust() / shipWeight.

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

lock travelDirection to VXCL(vec_up(),ship:srfprograde:vector):normalized.
lock leadDirection to VXCL(vec_up(),ship:facing:vector):normalized.

local vddTravel is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*10. }, RGB(0.1,0.1,0.1)).


local stopInterceptLex to slopeInterceptLex2(3,0,40,1,true).
local antiHeatInterceptLex to slopeInterceptLex2(200,0,400,1,true).
function stopVector
{
	// TODO: smarter stop: include small amount of goal
	local sup to ship:up:vector:normalized.

	local destabilizingStr to slopeInterceptCalc2(stopInterceptLex,ship:GROUNDSPEED).
	local antiHeatStr to slopeInterceptCalc2(antiHeatInterceptLex,ship:GROUNDSPEED).

	local retro to -1*ship:velocity:surface:normalized.
	// reverse stabilization
	local retroRatioStabilized to destabilizingStr*retro + sup.
	set retroRatioStabilized to RatioVector(retroRatioStabilized,retro,antiHeatStr).
	return retroRatioStabilized:normalized.
}
local vddStopVector is VECDRAW_DEL({return ship:position.}, { return stopVector()*15. }, RGB(1,0.1,0.1)).



local initialGeoPosition is SHIP:GEOPOSITION.



lock steering to stopVector().


global twrPID TO PIDLOOP(17, 8, 1, 0, 1). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
global deltaAltPID TO PIDLOOP(0.1, 0.005, 0.025, 0.1, 10). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)

local landRateInterceptLex to slopeInterceptLex2(25,-50,200,-12.5,true).

local thrustSlider is heartGui:ADDHSLIDER(0,0,1).
local maxTwrLabel to heartGui:addLabel("maxTwrLabel").
when true then
{
	lock throttle to twrPID:update(time:second,twr).
	set deltaAltPID:MAXOUTPUT to maxTwr*1.1.
	set twrPID:SETPOINT to deltaAltPID:update(time:second,upwardMovement).
	set deltaAltPID:SETPOINT to dist2ground/slopeInterceptCalc2(landRateInterceptLex,dist2ground).

	set thrustSlider:value to throttle.
	set maxTwrLabel:text to "maxTwr: " + RAP(maxTwr,3).

	return true. //keep alive
}

when ship:status<>"FLYING" then
{
	HUD(ship:status+"! " + RAP(ship:velocity:surface:mag,3) + PSET).
}



until 0 { wait 0. } // main loop wait forever

