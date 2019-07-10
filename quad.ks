@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup().

PARAMETER PARAMETER1 is " ".

if true
{
	set terminal:width  to 42.
	set terminal:height to 20.
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


global kspLaunchPadName to "KSC Launch Pad".
global ksplaunchpadgeo to ksplaunchpad().

global currentGoal to ksplaunchpadgeo.

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

local stopInterceptLex to slopeInterceptLex2(0.1,0,20,1,true).

// TODO: smarter stop: include small amount of goal
function stopVector
{
	local sup to ship:up:vector:normalized.

	local destabilizingStr to slopeInterceptCalc2(stopInterceptLex,ship:GROUNDSPEED). // should always be greater than 1

	local retro to -1*ship:velocity:surface:normalized.
	// reverse stabilization
	local retroRatioStabilized to destabilizingStr*retro + sup.
	return retroRatioStabilized:normalized.
}

local vddStopVector is VECDRAW_DEL({return ship:position.}, { return stopVector()*9. }, RGB(1,0.1,0.1)).

global desireStop to true.
global desiredLeanAngle to 7.5.

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


// movable marker for geo location with draw vector
global movableMarkGeo to LATLNG(-00.049,-74.611).
local vddMovableMark is VECDRAW_DEL({
	return smartGeoPosition(movableMarkGeo)-ship:position+100*vec_up().
}, {
	return -10*vec_up().
}, RGB(0.99,0.3,0.6), "", 10, true, 1).


local guiLean is GUI(200).
guiLean:ADDLABEL("Desired Lean Controller").

// placeholder grid Update Delegate
global gridUpdateDelegate to { parameter newX, newY. }.

local latLngUpdateDelegate to {
	parameter xx, yy.
	set movableMarkGeo to LATLNG(xx,yy).
	gridUpdateDelegate(xx,yy).
	set currentGoal to movableMarkGeo.

	// update experiment.json with newest geo mark location
	set experimentstate["movableMarkGeo"] to movableMarkGeo.
	writejson(experimentstate, "experiment.json").
}.

local guiWaypointPopupMenu to createWaypointDropdownMenu(guiLean,latLngUpdateDelegate).

set gridUpdateDelegate to createButtonGridWithTextFields(guiLean, movableMarkGeo:lat, movableMarkGeo:lng, latLngUpdateDelegate).



local guiLeanAngle is guiLean:ADDLABEL("guiLeanAngle").
local guiLeanDesired is guiLean:ADDLABEL("guiLeanDesired").
addButtonDelegate(guiLean,"++",{ set desiredLeanAngle to desiredLeanAngle + 7.5. }).
addButtonDelegate(guiLean,"+", { set desiredLeanAngle to desiredLeanAngle + 1.0. }).
addButtonDelegate(guiLean,"0", { set desiredLeanAngle to 0.0. }).
addButtonDelegate(guiLean,"-", { set desiredLeanAngle to desiredLeanAngle - 1.0. }).
addButtonDelegate(guiLean,"--",{ set desiredLeanAngle to desiredLeanAngle - 7.5. }).
local guiLeanError is guiLean:ADDLABEL("guiLeanError").
local guiLeanStop is guiLean:addcheckbox("Stop",desireStop).
set guiLeanStop:ontoggle to {
	parameter newstate.
	set desireStop to newstate.
	if newstate{
		set guiLeanFullThrottle:pressed to false.
		set desiredLeanAngle to 0.
		set fullthurstcheckbox:pressed to false.
		brakes on.
	}
}.
local guiLeanFullThrottle is guiLean:addcheckbox("Auto Lean Full Throttle",false).
set guiLeanFullThrottle:ontoggle to {
	parameter newstate.
	if newstate {
		set guiLeanStop:pressed to false.
		set fullthurstcheckbox:pressed to true.
		brakes off.
	}
}.
when guiLeanFullThrottle:pressed then
{
	set desiredLeanAngle to 90-leanFullThrottlePID:update(time:second,SHIP:ALTITUDE).
	return true.
}
when true then
{
	set guiLeanAngle:text to "leanAngle: "+round(leanAngle,6).
	if guiLeanStop:pressed
	{
		set guiLeanDesired:text to "stop: "+round(vang(stopVector(),ship:up:vector),6).
	}
	else
	{
		set guiLeanDesired:text to "desiredLeanAngle: "+round(desiredLeanAngle,3).
	}
	set guiLeanError:text to "Lean Error: "+round(vang(desiredLeanBaseVector(),ship:facing:vector),6).
	return true.
}
guiLean:show().



lock steering to desiredLeanBaseVector().

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to quadEnginesRawThrust() / shipWeight.


global twrPID TO PIDLOOP(500, 410, 400, 0, 100). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
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



global deltaAltPID TO PIDLOOP(0.1, 0.005, 0.025, 0.75, 10). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set deltaAltPID:SETPOINT to -0.2.
when true then
{
	// update this to measure rise/fall rate and adjust twrPID.
	set twrPID:SETPOINT to deltaAltPID:update(time:second,upwardMovement). // out of 100
	return true.
}



global leanFullThrottlePID TO PIDLOOP(0.1, 0.01, 2, 1, 89). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set leanFullThrottlePID:SETPOINT to 6777. // kerbin highest mountain is 6767
// TODO: find a way to fly lower for more speed, but not crash into mountains



local guiPID to leanFullThrottlePID.
local pidGUI is GUI(240).
pidGUI:ADDLABEL("PID Controller").

local guiP is addTextFieldDelegate(pidGUI, guiPID:KP, {parameter val. set guiPID:KP to val:tonumber().}).
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
pidGUI:ADDSPACING(12).
local guiPidSetPointError is pidGUI:ADDLABEL("guiPidSetPointError").
when true then
{
	set guiInput:text to "in: "+round(guiPID:INPUT,6).
	set guiOutput:text to "out: "+round(guiPID:OUTPUT,6).

	set guiPterm:text to "pterm: "+guiPID:pterm.
	set guiIterm:text to "iterm: "+guiPID:iterm.
	set guiDterm:text to "dterm: "+guiPID:dterm.
	set guiErrorSum:text to "ErrorSum: "+guiPID:ErrorSum.

	set guiPidSetPointError:text to "Setpoint Err: " + round(guiPID:INPUT-guiPID:SETPOINT,6).
	return true.
}
pidGUI:show().


// landing gear logic
local landingGearSpamProtector to time:seconds.
local landingGearSpamLastSet to true.
when time:seconds>landingGearSpamProtector then
{
	local groundValue to dist2ground + (upwardMovement * 3). // estimated alt in 3 seconds

	if groundValue > 350 and landingGearSpamLastSet
	{
		print "gear off".
		gear off.
		set landingGearSpamLastSet to false.
		set landingGearSpamProtector to time:seconds+2.
	}
	else if groundValue < 250 and not landingGearSpamLastSet
	{
		print "gear on".
		gear on.
		set landingGearSpamLastSet to true.
		set landingGearSpamProtector to time:seconds+2.
	}
	else
	{
		set landingGearSpamProtector to time:seconds+0.5.
	}

	return true.
}


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
set landcontrolcheckbox:ontoggle to {
	parameter newstate.
	if not newstate
	{
		set deltaAltPID:SETPOINT to 0.2.
		set deltaAltTextField:text to ""+deltaAltPID:SETPOINT.
	}
}.
local engineThrashlabel is enginegui:addlabel("engineThrashlabel").
local engineThrashTime is -1.
local engineThrashPrevious is -1.

local deltaAltTextField is addTextFieldDelegate(enginegui, deltaAltPID:SETPOINT,
	{parameter val. set deltaAltPID:SETPOINT to val:tonumber().}
).
addButtonDelegate(enginegui,"setpoint+",
	{ set deltaAltPID:SETPOINT to deltaAltPID:SETPOINT + 0.2. set deltaAltTextField:text to ""+deltaAltPID:SETPOINT. }
).
addButtonDelegate(enginegui,"setpoint-",
	{ set deltaAltPID:SETPOINT to deltaAltPID:SETPOINT - 0.2. set deltaAltTextField:text to ""+deltaAltPID:SETPOINT. }
).

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
		set deltaAltTextField:text to ""+deltaAltPID:SETPOINT.
	}

	local quadEnginesAverageThrustLimitRepresentative to
	{
		if quadEnginesAverageThrustLimit<1
		{
			return 0.
		}
		else if quadEnginesAverageThrustLimit>99
		{
			return 100.
		}
		else
		{
			return 50.
		}
	}.
	if quadEnginesAverageThrustLimitRepresentative()<>engineThrashPrevious
	{
		if engineThrashPrevious<>-1
		{
			print "Thrash: " + (time:seconds - engineThrashTime).
		}
		set engineThrashTime to time:seconds.
	}
	set engineThrashPrevious to quadEnginesAverageThrustLimitRepresentative().
	set engineThrashlabel:text to ""+(time:seconds - engineThrashTime).

	return true.
}
enginegui:show().




until 0 { wait 0. } // main loop wait forever

print "end of file".
