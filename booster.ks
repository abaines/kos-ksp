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

print "booster.ks 15".



// wait until we are the only cpu core
until getCpuCoreCount()<=1 { wait 0. }



CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
print("I'm in control now!").
local heartGui is createHeartbeatGui().


///////////////////////////////////////////////////////////////////////////////////////////////////
/// Booster control /// Booster control /// Booster control /// Booster control /// Booster control
///////////////////////////////////////////////////////////////////////////////////////////////////


lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to totalCurrentThrust() / shipWeight.

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

lock travelDirection to VXCL(vec_up(),ship:srfprograde:vector):normalized.
lock leadDirection to VXCL(vec_up(),ship:facing:vector):normalized.

local vddTravel is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*10. }, RGB(0.1,0.1,0.1)).

local initialGeoPosition is SHIP:GEOPOSITION.



lock steering to initialGeoPosition:ALTITUDEPOSITION(SHIP:ALTITUDE+900).


global twrPID TO PIDLOOP(17, 8, 1, 0, 1). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
global deltaAltPID TO PIDLOOP(0.1, 0.005, 0.025, 0.1, 10). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
global altPID TO PIDLOOP(0.1, 0.01, 2, -100, 300). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)



local thrustSlider is heartGui:ADDHSLIDER(0,0,1).
when true then
{
	lock throttle to twrPID:update(time:second,twr).
	set twrPID:SETPOINT to deltaAltPID:update(time:second,upwardMovement).
	set deltaAltPID:SETPOINT to altPID:update(time:second,dist2ground).
	set altPID:SETPOINT to 1000.

	set thrustSlider:value to throttle.

	return true. //keep alive
}



until 0 { wait 0. } // main loop wait forever

