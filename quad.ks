@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup().

PARAMETER PARAMETER1 is " ".

if true
{
	set terminal:width to 60.
	set terminal:height to 30.
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

local vddN is VECDRAW_DEL({return ship:position.}, {return qeN:POSITION.}, RGB(1,0,0)).
local vddE is VECDRAW_DEL({return ship:position.}, {return qeE:POSITION.}, RGB(1,1,1)).
local vddS is VECDRAW_DEL({return ship:position.}, {return qeS:POSITION.}, RGB(1,1,1)).
local vddW is VECDRAW_DEL({return ship:position.}, {return qeW:POSITION.}, RGB(1,1,1)).

local vdd1 is VECDRAW_DEL({return ship:position.}, { return 10*upwardMovementVec. }, RGB(1,0,1)).

lock desiredHeight to min(dist2ground+1,50).

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to qeC:THRUST / shipWeight.

global twrPID TO PIDLOOP(500, 0, 0, 0, 100). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set twrPID:SETPOINT to 1.05.


local activateTime to scriptEpoch + 2.
when time:seconds > activateTime then
{
	qec:activate().
}

local gui is GUI(200).

local button1 TO gui:ADDBUTTON("p+").
set button1:ONCLICK to { set twrPID:KP to twrPID:KP + 1. }.

local button2 TO gui:ADDBUTTON("p-").
set button1:ONCLICK to { set twrPID:KP to twrPID:KP - 1. }.

local button3 TO gui:ADDBUTTON("i+").
local button4 TO gui:ADDBUTTON("i-").
local button5 TO gui:ADDBUTTON("d+").
local button6 TO gui:ADDBUTTON("d-").

gui:show().


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
	print "twr "+twr +"               " at(0,15).
	
	print "p "+twrPID:KP +"               " at(0,17).
	print "i "+twrPID:KI +"               " at(0,18).
	print "d "+twrPID:KD +"               " at(0,19).
}

until false
{
	mainLoop().
	wait 0.
}


print "end of file".
