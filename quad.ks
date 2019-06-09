@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").

librarysetup().

PARAMETER PARAMETER1 is " ".

if false
{
	set terminal:width to 45.
	set terminal:height to 20.
}

print "quad.ks 11" at(0,0).
print "quad.ks 11" at(0,21).

global _throttle to 1.0.
lock throttle to _throttle.

global _steering to up.
lock steering to _steering.

rcs off.
sas off.

managePanelsAndAntenna().

manageFuelCells().

global qeN is ship:partsTagged("qe-n")[0].
global qeE is ship:partsTagged("qe-e")[0].
global qeS is ship:partsTagged("qe-s")[0].
global qeW is ship:partsTagged("qe-w")[0].
global qeC is ship:partsTagged("qe-c")[0].

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

local vdd1 is VECDRAW_DEL({return ship:position.}, {return qeN:POSITION.}, RGB(0,0,1)).

local vdd2 is VECDRAW_DEL({return ship:position.}, { return 10*upwardMovementVec. }, RGB(1,0,1)).

lock desiredHeight to min(dist2ground+1,50).

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to qeC:THRUST / shipWeight.

global twrPID TO PIDLOOP(3000, 1/1000, 1/1000, 0, 100). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set twrPID:SETPOINT to 1.05.

qeC:Activate().

function mainLoop
{
	print "mt "+qeC:MAXTHRUST+"               " at(0,5).
	print "dh "+desiredHeight+"               " at(0,6).
	print "um "+upwardMovement+"               " at(0,7).
	
	local twrPIDUpdate to twrPID:update(time:second,twr).
	set qeC:THRUSTLIMIT to twrPIDUpdate. // out of 100
	print "THRUSTLIMIT "+twrPIDUpdate+"               " at(0,9).
	
	print "GRAV "+ship:sensors:GRAV:mag+"               " at(0,12).
	
	print "THRUST "+qeC:THRUST+"               " at(0,14).
	print "SETPOINT "+twrPID:SETPOINT+"               " at(0,15).
	
	print "twr "+twr +"               " at(0,17).
}

until false
{
	mainLoop().
	wait 0.
}


print "end of file".
