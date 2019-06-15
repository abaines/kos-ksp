@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup().

PARAMETER PARAMETER1 is " ".

if true
{
	if terminal:width<42 {set terminal:width to 42.}
	if terminal:height<30 {set terminal:height to 30.}
}

print "quad.ks 12".

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 1.

global _steering to Up + R(0,0,180).
lock steering to _steering.

rcs on.
sas off.

managePanelsAndAntenna().

manageFuelCells().


global qeC is ship:partsTagged("qe-c")[0].


lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

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

function stopVector
{
	local sup to ship:up:vector:normalized.

	local stabilizingStr to ship:velocity:surface:mag+5.
	local stabilizingRatio to 2. // should always be greater than 1

	local retro to -1*ship:velocity:surface + (stabilizingStr*sup).
	local stopDirectionInPlane to VXCL(sup,retro):normalized.
	local retroRatioStabilized to retro:normalized + (stabilizingRatio*sup).
	return retroRatioStabilized:normalized.
}

local vddStopVector is VECDRAW_DEL({return ship:position.}, { return stopVector()*9. }, RGB(1,0.1,0.1)).

global desireStop to false.
global desiredLeanAngle to 0.001.

global desiredLeanBaseVector to
{
	if desireStop
	{
		return stopVector().
	}
	else
	{
		return BetweenVector(vec_up(),goalDirection,desiredLeanAngle):normalized.
	}
}.
local vddDesiredLean is VECDRAW_DEL({return ship:position.}, { return desiredLeanBaseVector()*12. }, RGB(1,0.5,0.0)).

lock leanAngle to vang(ship:facing:vector,vec_up()).

global fullThrottle to false.

local guiLean is GUI(200).
guiLean:ADDLABEL("Desired Lean Controller").
local guiLeanAngle is guiLean:ADDLABEL("guiLeanAngle").
local guiLeanDesired is guiLean:ADDLABEL("guiLeanDesired").
addButtonDelegate(guiLean,"++",{ set desiredLeanAngle to desiredLeanAngle + 7.5. }).
addButtonDelegate(guiLean,"+",{ set desiredLeanAngle to desiredLeanAngle + 1. }).
addButtonDelegate(guiLean,"0",{ set desiredLeanAngle to 0.001. }).
addButtonDelegate(guiLean,"-", { set desiredLeanAngle to desiredLeanAngle - 1.   if desiredLeanAngle<0.001 { set desiredLeanAngle to 0.001. } }).
addButtonDelegate(guiLean,"--",{ set desiredLeanAngle to desiredLeanAngle - 7.5. if desiredLeanAngle<0.001 { set desiredLeanAngle to 0.001. } }).
local guiLeanError is guiLean:ADDLABEL("guiLeanError").
local guiLeanStop is guiLean:addcheckbox("Stop",desireStop).
set guiLeanStop:ontoggle to { parameter newstate. set desireStop to newstate. }.
when true then
{
	set guiLeanDesired:text to ""+desiredLeanAngle.
	set guiLeanError:text to ""+vang(desiredLeanBaseVector(),ship:facing:vector).
	set guiLeanAngle:text to ""+leanAngle.
	return true.
}
guiLean:show().



lock steering to desiredLeanBaseVector().

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to qeC:THRUST / shipWeight.


global twrPID TO PIDLOOP(1300, 70, 25, 0, 100). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
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



global deltaAltPID TO PIDLOOP(0.75, 0.1, 0.03, 0.75, 10). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set deltaAltPID:SETPOINT to 5.
when true then
{
	// update this to measure rise/fall rate and adjust twrPID.
	set twrPID:SETPOINT to deltaAltPID:update(time:second,upwardMovement). // out of 100
	return true.
}







local guiPID to deltaAltPID.
local pidGUI is GUI(240).
pidGUI:ADDLABEL("PID Controller").

local guiP is pidGUI:ADDTEXTFIELD(""+guiPID:KP).
set guiP:ONCONFIRM to {parameter value. set guiPID:KP to value:tonumber().}.
addButtonDelegate(pidGUI,"p+",{ set guiPID:KP to guiPID:KP * 1.2. set guiP:text to ""+guiPID:KP. }).
addButtonDelegate(pidGUI,"p-",{ set guiPID:KP to guiPID:KP / 1.2. set guiP:text to ""+guiPID:KP. }).

local guiI is addTextFieldDelegate(pidGUI, guiPID:KI, {parameter val. set guiPID:KI to val:tonumber().}).
addButtonDelegate(pidGUI,"i+",{ set guiPID:KI to guiPID:KI * 1.2. set guiI:text to ""+guiPID:KI. }).
addButtonDelegate(pidGUI,"i-",{ set guiPID:KI to guiPID:KI / 1.2. set guiI:text to ""+guiPID:KI. }).

local guiD is addTextFieldDelegate(pidGUI, guiPID:KD, {parameter val. set guiPID:KD to val:tonumber().}).
addButtonDelegate(pidGUI,"d+",{ set guiPID:KD to guiPID:KD * 1.2. set guiD:text to ""+guiPID:KD. }).
addButtonDelegate(pidGUI,"d-",{ set guiPID:KD to guiPID:KD / 1.2. set guiD:text to ""+guiPID:KD. }).

local guiInputDesired is addTextFieldDelegate(pidGUI, guiPID:SETPOINT,
	{parameter val. set guiPID:SETPOINT to val:tonumber().}
).
addButtonDelegate(pidGUI,"setpoint+",
	{ set guiPID:SETPOINT to guiPID:SETPOINT + 0.2. set guiInputDesired:text to ""+guiPID:SETPOINT. }
).
addButtonDelegate(pidGUI,"setpoint-",
	{ set guiPID:SETPOINT to guiPID:SETPOINT - 0.2. set guiInputDesired:text to ""+guiPID:SETPOINT. }
).

local guiInput is pidGUI:ADDLABEL("guiInput").
local guiOutput is pidGUI:ADDLABEL("guiOutput").
pidGUI:ADDSPACING(12).
local guiPterm is pidGUI:ADDLABEL("guiPterm").
local guiIterm is pidGUI:ADDLABEL("guiIterm").
local guiDterm is pidGUI:ADDLABEL("guiDterm").
local guiErrorSum is pidGUI:ADDLABEL("guiErrorSum").
when true then
{
	set guiInput:text to "in: "+guiPID:INPUT.
	set guiOutput:text to "out: "+guiPID:OUTPUT.

	set guiPterm:text to "pterm: "+guiPID:pterm.
	set guiIterm:text to "iterm: "+guiPID:iterm.
	set guiDterm:text to "dterm: "+guiPID:dterm.
	set guiErrorSum:text to "ErrorSum: "+guiPID:ErrorSum.
	return true.
}
pidGUI:show().



local enginegui is gui(240).

local thrustlimitlabel is enginegui:addlabel("thrustlimitlabel").
local thrustSlider is enginegui:ADDHSLIDER(qec:thrustlimit,0,100).
local twrlabel is enginegui:addlabel("twrlabel").
local maxthrustlabel is enginegui:addlabel("maxthrustlabel").
local thrustlabel is enginegui:addlabel("thrustlabel").
local gravlabel is enginegui:addlabel("gravlabel").
local upwardmovementlabel is enginegui:addlabel("upwardmovementlabel").
local dist2groundlabel is enginegui:addlabel("dist2groundlabel").

local fullthurstcheckbox to enginegui:addcheckbox("full throttle", fullthrottle).
set fullthurstcheckbox:ontoggle to { parameter newstate. set fullthrottle to newstate. }.
when true then
{
	set maxthrustlabel:text to "qec:maxthrust: "+round(qec:maxthrust,6).
	set upwardmovementlabel:text to "upwardmovement: "+round(upwardmovement,6).
	set dist2groundlabel:text to "dist2ground: "+round(dist2ground,6).
	set thrustlimitlabel:text to "qec:thrustlimit: "+round(qec:thrustlimit,6).
	set gravlabel:text to "ship:sensors:grav:mag: "+round(ship:sensors:grav:mag,6).
	set thrustlabel:text to "qec:thrust: "+round(qec:thrust,6).
	set twrlabel:text to "twr: "+round(twr,6).

	set thrustSlider:value to qec:thrustlimit.

	return true.
}
enginegui:show().


function mainLoop
{
}

until false
{
	mainLoop().
	wait 0.
}


print "end of file".
