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

print ship:geoposition.
global experimentstate to lex().
experimentstate:add("ship:name",ship:name).
experimentstate:add("ship:geoposition",ship:geoposition).
writejson(experimentstate, "experiment.json").

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 1.

global _steering to Up + R(0,0,180).
lock steering to _steering.

rcs on.
sas off.

managePanelsAndAntenna().

manageFuelCells().

global waypointName to "TMA-2".
global kspLaunchPadName to "KSC Launch Pad".
global ksplaunchpadgeo to ksplaunchpad().
global waypointGoal to waypoint(waypointName):GEOPOSITION.
global currentGoal to waypointGoal.

// quadEngine
global quadEngines is ship:partsTagged("qe").
print("quadEngines:length: "+quadEngines:length).
global quadEnginesAverageThrustLimit to 0.
when true then
{
	for qe in quadEngines
	{
		set qe:thrustLimit to quadEnginesAverageThrustLimit.
	}
	return true.
}

function quadEnginesRawThrust
{
	local sum is 0.
	for qe in quadEngines
	{
		set sum to sum + qe:thrust.
	}
	return sum.
}

function quadEnginesMaxMaxThrust
{
	local m is 0.
	for qe in quadEngines
	{
		set m to max(m,qe:maxthrust).
	}
	return m.
}

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

local vddUpwardMovement is VECDRAW_DEL({return ship:position.}, { return 10*upwardMovementVec. }, RGB(1,0,1)).

local vddLaunchPad is VECDRAW_DEL({return ship:position.}, { return ksplaunchpadgeo:position. }, RGB(0,1,0)).

lock travelDirection to VXCL(vec_up(),ship:srfprograde:vector):normalized.
lock leadDirection to VXCL(vec_up(),ship:facing:vector):normalized.
lock goalDirection to VXCL(vec_up(),currentGoal:POSITION).

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

global desireStop to true.
global desiredLeanAngle to 45.

global desiredLeanBaseVector to
{
	if desireStop
	{
		return stopVector().
	}
	else
	{
		return BetweenVector(vec_up(),goalDirection,desiredLeanAngle+0.001):normalized.
	}
}.
local vddDesiredLean is VECDRAW_DEL({return ship:position.}, { return desiredLeanBaseVector()*12. }, RGB(1,0.5,0.0)).

lock leanAngle to vang(ship:facing:vector,vec_up()).

global fullThrottle to false.

local guiLean is GUI(200).
guiLean:ADDLABEL("Desired Lean Controller").
local guiLeanGoalpopup to guiLean:addpopupmenu().
guiLeanGoalpopup:addoption(kspLaunchPadName).
guiLeanGoalpopup:addoption(waypointName).
set guiLeanGoalpopup:ONCHANGE to
{
	parameter choice.
	if choice:TOSTRING = waypointName
	{
		set currentGoal to waypointGoal.
	}
	else
	{
		set currentGoal to ksplaunchpadgeo.
	}
}.
set guiLeanGoalpopup:index to 1.

local guiLeanAngle is guiLean:ADDLABEL("guiLeanAngle").
local guiLeanDesired is guiLean:ADDLABEL("guiLeanDesired").
addButtonDelegate(guiLean,"++",{ set desiredLeanAngle to desiredLeanAngle + 7.5. }).
addButtonDelegate(guiLean,"+", { set desiredLeanAngle to desiredLeanAngle + 1.0. }).
addButtonDelegate(guiLean,"0", { set desiredLeanAngle to 0.0. }).
addButtonDelegate(guiLean,"-", { set desiredLeanAngle to desiredLeanAngle - 1.0. }).
addButtonDelegate(guiLean,"--",{ set desiredLeanAngle to desiredLeanAngle - 7.5. }).
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

lock twr to quadEnginesRawThrust() / shipWeight.


global twrPID TO PIDLOOP(1000, 410, 830, 0, 100). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set twrPID:SETPOINT to 1.01.
when true then
{
	if fullThrottle
	{
		set quadEnginesAverageThrustLimit to 100.
	}
	else
	{
		set quadEnginesAverageThrustLimit to twrPID:update(time:second,twr). // out of 100
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
local thrustSlider is enginegui:ADDHSLIDER(quadEnginesAverageThrustLimit,0,100).
local twrlabel is enginegui:addlabel("twrlabel").
local maxthrustlabel is enginegui:addlabel("maxthrustlabel").
local thrustlabel is enginegui:addlabel("thrustlabel").
local gravlabel is enginegui:addlabel("gravlabel").
local upwardmovementlabel is enginegui:addlabel("upwardmovementlabel").
local dist2groundlabel is enginegui:addlabel("dist2groundlabel").

local fullthurstcheckbox to enginegui:addcheckbox("full throttle", fullthrottle).
set fullthurstcheckbox:ontoggle to { parameter newstate. set fullthrottle to newstate. }.
local landcontrolcheckbox to enginegui:addcheckbox("land", false).
local engineThrashlabel is enginegui:addlabel("engineThrashlabel").
local engineThrashTime is time:seconds.
local engineThrashWasHappening is false.
when true then
{
	set maxthrustlabel:text to "qec:maxthrust: "+round(quadEnginesMaxMaxThrust(),6).
	set upwardmovementlabel:text to "upwardmovement: "+round(upwardmovement,6).
	set dist2groundlabel:text to "dist2ground: "+round(dist2ground,6).
	set thrustlimitlabel:text to "qec:thrustlimit: "+round(quadEnginesAverageThrustLimit,6).
	set gravlabel:text to "ship:sensors:grav:mag: "+round(ship:sensors:grav:mag,6).
	set thrustlabel:text to "qec:thrust: "+round(quadEnginesRawThrust(),6).
	set twrlabel:text to "twr: "+round(twr,6).

	set thrustSlider:value to quadEnginesAverageThrustLimit.

	if landcontrolcheckbox:PRESSED
	{
		set deltaAltPID:SETPOINT to dist2ground/-20.
	}
	
	local engineThrashIsHappening to quadEnginesAverageThrustLimit>99 or quadEnginesAverageThrustLimit<1.
	if engineThrashWasHappening<>engineThrashIsHappening
	{
		set engineThrashTime to time:seconds.
	}
	set engineThrashWasHappening to engineThrashIsHappening.
	set engineThrashlabel:text to ""+(time:seconds - engineThrashTime).

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
