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

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 1.

global _steering to Up + R(0,0,180).
lock steering to _steering.

rcs on.
sas off.

managePanelsAndAntenna().

manageFuelCells().


//global qeN is ship:partsTagged("qe-n")[0].
//global qeE is ship:partsTagged("qe-e")[0].
//global qeS is ship:partsTagged("qe-s")[0].
//global qeW is ship:partsTagged("qe-w")[0].
global qeC is ship:partsTagged("qe-c")[0].

//set qeN:THRUSTLIMIT to 0.
//set qeE:THRUSTLIMIT to 0.
//set qeS:THRUSTLIMIT to 0.
//set qeW:THRUSTLIMIT to 0.

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

//local vddN is VECDRAW_DEL({return ship:position.}, {return qeN:POSITION.}, RGB(1,0,0)).
//local vddE is VECDRAW_DEL({return ship:position.}, {return qeE:POSITION.}, RGB(0.1,0.1,0.1)).
//local vddS is VECDRAW_DEL({return ship:position.}, {return qeS:POSITION.}, RGB(1,1,1)).
//local vddW is VECDRAW_DEL({return ship:position.}, {return qeW:POSITION.}, RGB(0.1,0.1,0.1)).

local vddUpwardMovement is VECDRAW_DEL({return ship:position.}, { return 10*upwardMovementVec. }, RGB(1,0,1)).

global waypointGoal to waypoint("TMA-1"):GEOPOSITION.

lock travelDirection to VXCL(vec_up(),ship:srfprograde:vector):normalized.
lock leadDirection to VXCL(vec_up(),ship:facing:vector):normalized.
lock goalDirection to VXCL(vec_up(),waypointGoal:POSITION).

local vddTravel is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
local vddTravelFlat is VECDRAW_DEL({return ship:position.}, { return travelDirection*10. }, RGB(0,1,1)).
local vddLean is VECDRAW_DEL({return ship:position.}, { return leadDirection*10. }, RGB(1,1,0)).
local vddGoal is VECDRAW_DEL({return ship:position.}, { return goalDirection. }, RGB(0,1,0)).

local vddUp is VECDRAW_DEL({return ship:position.}, { return vec_up():normalized*7. }, RGB(1,1,1)).
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*10. }, RGB(0.1,0.1,0.1)).

global desiredLeanAngle to 0.001.

local desiredLeanBaseVector to
{
	local angle to 0.
	if dist2ground<0 //or qeC:THRUSTLIMIT>90
	{
		set angle to 0.001.
	}
	else
	{
		set angle to desiredLeanAngle.
	}
	return BetweenVector(vec_up(),goalDirection,angle):normalized.
}.
local vddDesiredLean is VECDRAW_DEL({return ship:position.}, { return desiredLeanBaseVector()*12. }, RGB(1,0.5,0.0)).

global fullThrottle to true.

local guiLean is GUI(200).
local guiValue is guiLean:ADDLABEL("guiValue").
addButtonDelegate(guiLean,"++",{ set desiredLeanAngle to desiredLeanAngle + 7.5. }).
addButtonDelegate(guiLean,"+",{ set desiredLeanAngle to desiredLeanAngle + 1. }).
addButtonDelegate(guiLean,"0",{ set desiredLeanAngle to 0.001. }).
addButtonDelegate(guiLean,"-", { set desiredLeanAngle to desiredLeanAngle - 1.   if desiredLeanAngle<0.001 { set desiredLeanAngle to 0.001. } }).
addButtonDelegate(guiLean,"--",{ set desiredLeanAngle to desiredLeanAngle - 7.5. if desiredLeanAngle<0.001 { set desiredLeanAngle to 0.001. } }).
when true then
{
	set guiValue:text to ""+desiredLeanAngle.
	return true.
}
guiLean:show().

local fullThurstCheckbox to guiLean:ADDCHECKBOX("full throttle", true).
set fullThurstCheckbox:ONTOGGLE to { parameter newState. set fullThrottle to newState. }.



//lock _steering to Up + R(0,0,180).
lock steering to desiredLeanBaseVector().

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to qeC:THRUST / shipWeight.

lock leanAngle to vang(ship:facing:vector,vec_up()).

global twrPID TO PIDLOOP(2000, 0.1, 25, 0, 100). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set twrPID:SETPOINT to 1.01.
when true then
{
	if fullThrottle
	{
		set qeC:THRUSTLIMIT to 100.
	}
	else
	{
		set qeC:THRUSTLIMIT to twrPID:update(time:second,twr). // out of 100
	}
	return true.
}


global altPID TO PIDLOOP(0.013, 0.003, 1.5, 0.75, 1.5). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set altPID:SETPOINT to 1500.
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


local activateTime to scriptEpoch + 1.
when time:seconds > activateTime then
{
	//qec:activate().
	
	//qen:activate().
	//qee:activate().
	//qes:activate().
	//qew:activate().
}


local guiPID to altPID.
local gui is GUI(200).
local guiInput is gui:ADDLABEL("guiInput").
local guiOutput is gui:ADDLABEL("guiOutput").
addButtonDelegate(gui,"p+",{ set guiPID:KP to guiPID:KP * 1.2. }).
addButtonDelegate(gui,"p-",{ set guiPID:KP to guiPID:KP / 1.2. }).
addButtonDelegate(gui,"i+",{ set guiPID:KI to guiPID:KI * 1.2. }).
addButtonDelegate(gui,"i-",{ set guiPID:KI to guiPID:KI / 1.2. }).
addButtonDelegate(gui,"d+",{ set guiPID:KD to guiPID:KD * 1.2. }).
addButtonDelegate(gui,"d-",{ set guiPID:KD to guiPID:KD / 1.2. }).
when true then
{
	set guiInput:text to ""+guiPID:INPUT.
	set guiOutput:text to ""+guiPID:OUTPUT.
	return true.
}
//gui:show().


function mainLoop
{
	print "MAXTHRUST "+qeC:MAXTHRUST+"               " at(0,5).
	print "upwardMovement "+upwardMovement+"               " at(0,6).
	print "dist2ground "+dist2ground+"               " at(0,7).
	
	print "THRUSTLIMIT "+qeC:THRUSTLIMIT+"               " at(0,9).
	
	print "GRAV "+ship:sensors:GRAV:mag+"               " at(0,12).
	
	print "THRUST "+qeC:THRUST+"               " at(0,14).
	print "twr "+twr +"               " at(0,15).
	
	print "p "+guiPID:KP +"               " at(0,17).
	print "i "+guiPID:KI +"               " at(0,18).
	print "d "+guiPID:KD +"               " at(0,19).
	
	print "leanAngle "+leanAngle +"               " at(0,21).
	
	print "fullThrottle "+fullThrottle +"               " at(0,23).
}

until false
{
	mainLoop().
	wait 0.
}


print "end of file".
