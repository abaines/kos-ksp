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

set qeN:THRUSTLIMIT to 0.
set qeE:THRUSTLIMIT to 0.
set qeS:THRUSTLIMIT to 0.
set qeW:THRUSTLIMIT to 0.

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

local vddN is VECDRAW_DEL({return ship:position.}, {return qeN:POSITION.}, RGB(1,0,0)).
local vddE is VECDRAW_DEL({return ship:position.}, {return qeE:POSITION.}, RGB(0.1,0.1,0.1)).
local vddS is VECDRAW_DEL({return ship:position.}, {return qeS:POSITION.}, RGB(1,1,1)).
local vddW is VECDRAW_DEL({return ship:position.}, {return qeW:POSITION.}, RGB(0.1,0.1,0.1)).

local vddUpwardMovement is VECDRAW_DEL({return ship:position.}, { return 10*upwardMovementVec. }, RGB(1,0,1)).

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to qeC:THRUST / shipWeight.

lock leanAngle to vang(ship:facing:vector,vec_up()).

global twrPID TO PIDLOOP(2000, 0.1, 25, 0, 100). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set twrPID:SETPOINT to 1.01.
when true then
{
	//set twrPID:SETPOINT to 1.05/cos(leanAngle).
	set qeC:THRUSTLIMIT to twrPID:update(time:second,twr). // out of 100
	return true.
}


global altPID TO PIDLOOP(0.0001, 0, 0, 0.5, 1.5). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set altPID:SETPOINT to 500.
when true then
{
	set twrPID:SETPOINT to altPID:update(time:second,dist2ground)/cos(leanAngle). // out of 100
	return true.
}


if false
{
	global leanPID TO PIDLOOP(1, 0.0, 0, 0, 100). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
	set leanPID:SETPOINT to 5.
	when true then
	{
		set qeN:THRUSTLIMIT to leanPID:update(time:second,leanAngle). // out of 100
		return true.
	}
}


local activateTime to scriptEpoch + 2.
when time:seconds > activateTime then
{
	qec:activate().
	
	qen:activate().
	qee:activate().
	qes:activate().
	qew:activate().
}


local guiPID to altPID.
local gui is GUI(200).
local guiInput is gui:ADDLABEL("guiInput").
local guiOutput is gui:ADDLABEL("guiOutput").
addButtonDelegate(gui,"p+",{ set guiPID:KP to guiPID:KP * 1.05. }).
addButtonDelegate(gui,"p-",{ set guiPID:KP to guiPID:KP / 1.05. }).
addButtonDelegate(gui,"i+",{ set guiPID:KI to guiPID:KI + 0.1. }).
addButtonDelegate(gui,"i-",{ set guiPID:KI to guiPID:KI - 0.1. }).
addButtonDelegate(gui,"d+",{ set guiPID:KD to guiPID:KD + 0.1. }).
addButtonDelegate(gui,"d-",{ set guiPID:KD to guiPID:KD - 0.1. }).
when true then
{
	set guiInput:text to ""+guiPID:INPUT.
	set guiOutput:text to ""+guiPID:OUTPUT.
	return true.
}
gui:show().


function mainLoop
{
	print "mt "+qeC:MAXTHRUST+"               " at(0,5).
	print "um "+upwardMovement+"               " at(0,7).
	
	print "GRAV "+ship:sensors:GRAV:mag+"               " at(0,12).
	
	print "THRUST "+qeC:THRUST+"               " at(0,14).
	print "twr "+twr +"               " at(0,15).
	
	print "p "+guiPID:KP +"               " at(0,17).
	print "i "+guiPID:KI +"               " at(0,18).
	print "d "+guiPID:KD +"               " at(0,19).
	
	print "leanAngle "+leanAngle +"               " at(0,21).
}

until false
{
	mainLoop().
	wait 0.
}


print "end of file".
