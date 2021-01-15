@LAZYGLOBAL off.

// start of script
global scriptEpoch to time:seconds.

// time since script started
lock scriptElapsedTime to time:seconds - scriptEpoch.

// for logging/printing with time stamps
lock PSET to " @ " + RAP(scriptElapsedTime,2).

// print with @ script Elapsed Time
function pwset
{
	parameter msg.
	local _pset to PSET.
	local padRequired to 42-_pset:length.
	print(msg:toString:padRight(padRequired)+_pset).
}

runOncePath("library").
runOncePath("library_gui").
runOncePath("library_vec").

librarysetup(false).

when time:seconds > scriptEpoch + 10 then
{
	set terminal:width  to 42.
	set terminal:height to 12.
}

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
pwset("guiSas.ks 00").

wait 0.

pwset(CORE:tag).

setLoadDistances(32).

sas off.
rcs off.
abort off.


// traveling vector
local vddTravel is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
// facing vector
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*25. }, RGB(0.1,0.1,0.1)).
// normal vector
local vddNormal is VECDRAW_DEL({return ship:position.}, { return vec_ship_normal()*25. }, RGB(0.7,0.1,0.7)).
// radial vector
local vddRadial is VECDRAW_DEL({return ship:position.}, { return vec_ship_radial()*20. }, RGB(0.5,0.5,0.9)).


if 0
{
	// draw vector to waypoint
	local vddWaypoint is VECDRAW_DEL(
		{ return ship:position. },
		{ return waypoint("Kraken's Awe"):position. },
		RGB(0.9,0.1,0.1)
	).
}


// main gui for lean angle (manual gravity turn)
local sasGui is GUI(1900).
set sasGui:y to 1400.

local sliderLabelWidth to 60.

// slider with range from 0 (horizon) to 90 (straight up)
local boxPitch to sasGui:AddHLayout().
local sliderPitch is boxPitch:AddHSlider.
local labelPitch is boxPitch:AddLabel.
set labelPitch:style:width to sliderLabelWidth.
set sliderPitch:min to 0.
set sliderPitch:max to 90.
set sliderPitch:ONCHANGE to {
	parameter newValue.
	set labelPitch:text to RAP(newValue,3).
}.
set sliderPitch:value to 1.


local boxEquator to sasGui:AddHLayout().
local sliderEquator is boxEquator:AddHSlider.
local labelEquator is boxEquator:AddLabel.
set labelEquator:style:width to sliderLabelWidth.
set sliderEquator:min to 90-180.
set sliderEquator:max to 90+180.
set sliderEquator:ONCHANGE to {
	parameter newValue.
	set labelEquator:text to RAP(newValue,3).
}.
set sliderEquator:value to 90.


local boxRoll to sasGui:AddHLayout().
local sliderRoll is boxRoll:AddHSlider.
local labelRoll is boxRoll:AddLabel.
set labelRoll:style:width to sliderLabelWidth.
set sliderRoll:min to 0-180.
set sliderRoll:max to 0+180.
set sliderRoll:ONCHANGE to {
	parameter newValue.
	set labelRoll:text to RAP(newValue,3).
}.
set sliderRoll:value to 0. // -90 for default VAB; 0 for "Q" rotation in VAB.



// basic SAS options
local boxBasicSas to sasGui:AddHLayout().

local unlock_steering_button to boxBasicSas:addButton("unlock").
set unlock_steering_button:style:hstretch to false.
set unlock_steering_button:ONCLICK to {
	pwset("unlock steering").
	unlock steering.
	sas on.
}.

local prograde_button to boxBasicSas:addButton("prograde").
set prograde_button:style:hstretch to false.
set prograde_button:ONCLICK to {
	pwset("prograde").
	lock steering to ship:prograde:vector.
	sas off.
}.

local retro_orbit_button to boxBasicSas:addButton("retro orbit").
set retro_orbit_button:style:hstretch to false.
set retro_orbit_button:ONCLICK to {
	pwset("retro orbit").
	lock steering to -1*ship:prograde:vector.
	sas off.
}.

local retro_button to boxBasicSas:addButton("retro surface").
set retro_button:style:hstretch to false.
set retro_button:ONCLICK to {
	pwset("retro surface").
	lock steering to -1*ship:srfprograde:vector.
	sas off.
}.

local normal_button to boxBasicSas:addButton("normal").
set normal_button:style:hstretch to false.
set normal_button:ONCLICK to {
	pwset("normal").
	lock steering to vec_ship_normal().
	sas off.
}.

local antinormal_button to boxBasicSas:addButton("anti-normal").
set antinormal_button:style:hstretch to false.
set antinormal_button:ONCLICK to {
	pwset("anti-normal").
	lock steering to -1*vec_ship_normal().
	sas off.
}.

local radial_in_button to boxBasicSas:addButton("radial in").
set radial_in_button:style:hstretch to false.
set radial_in_button:ONCLICK to {
	pwset("radial in").
	lock steering to -1*vec_ship_radial().
	sas off.
}.

local radial_out_button to boxBasicSas:addButton("radial out").
set radial_out_button:style:hstretch to false.
set radial_out_button:ONCLICK to {
	pwset("radial out").
	lock steering to vec_ship_radial().
	sas off.
}.

// advanced SAS buttons

// maneuver node
function maneuver_node_vector
{
	if hasnode
	{
		return nextnode:BURNVECTOR.
	}
	unlock steering.
	pwset("lost node").
	return "KILL".
}

local maneuver_button to boxBasicSas:addButton("maneuver").
set maneuver_button:style:hstretch to false.
set maneuver_button:ONCLICK to {
	pwset("maneuver").
	lock steering to maneuver_node_vector().
	sas off.
}.

// advanced target buttons

function target_stop_vector
{
	if HASTARGET
	{
		return target:velocity:orbit - ship:velocity:orbit.
	}
	unlock steering.
	pwset("lost target").
	return "KILL".
}

local target_stop_button to boxBasicSas:addButton("target stop").
set target_stop_button:style:hstretch to false.
set target_stop_button:ONCLICK to {
	pwset("target stop").
	lock steering to target_stop_vector().
	sas off.
}.

function target_facing_vector
{
	if HASTARGET
	{
		return target:position - ship:position.
	}
	unlock steering.
	pwset("lost target").
	return "KILL".
}

local target_facing_button to boxBasicSas:addButton("target facing").
set target_facing_button:style:hstretch to false.
set target_facing_button:ONCLICK to {
	pwset("target facing").
	lock steering to target_facing_vector().
	sas off.
}.

function anti_target_facing_vector
{
	if HASTARGET
	{
		return ship:position - target:position.
	}
	unlock steering.
	pwset("lost target").
	return "KILL".
}

local target_facing_button to boxBasicSas:addButton("anti target facing").
set target_facing_button:style:hstretch to false.
set target_facing_button:ONCLICK to {
	pwset("anti target facing").
	lock steering to anti_target_facing_vector().
	sas off.
}.


function unknown_target_vector
{
	if HASTARGET
	{
		local facing_vector is (target:position - ship:position):normalized.
		local stop_vector is (target:velocity:orbit - ship:velocity:orbit):normalized.
		return planierize(facing_vector,stop_vector):normalized + (facing_vector:normalized)*3.
	}
	unlock steering.
	pwset("lost target").
	return "KILL".
}

local target_unknown_button to boxBasicSas:addButton("target unknown").
set target_unknown_button:style:hstretch to false.
set target_unknown_button:ONCLICK to {
	pwset("target unknown").
	lock steering to unknown_target_vector().
	sas off.
}.


// TODO: rendezvous

// steering heading based on slider values
lock steerHeading to HEADING(sliderEquator:value,90-sliderPitch:value,sliderRoll:value).

// lock steering to slider bar
lock steering to steerHeading.

// draw vector to slider lean (manual gravity turn)
local vddSliderSteerHeading is VECDRAW_DEL(
	{ return ship:position. },
	{ return convertToVector(steering):vec:normalized*35. },
	RGB(0.0,0.9,0.5)
).


sasGui:show().


if 0
{
	// disable automatic quest throttle control if needed
	local manualOverrideButton to boxBasicSas:addButton("Unlock Throttle").
	set manualOverrideButton:style:hstretch to false.
	set manualOverrideButton:ONCLICK to {
		pwset("Manual Override Button").
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
		lock throttle to 0.
		unlock throttle.
		manualOverrideButton:hide().
	}.

	// quest throttle
	local maxQuestSpeed to 1610.
	local minQuestSpeed to 480.

	local questLex to slopeInterceptLex2(maxQuestSpeed,0,minQuestSpeed,1,true).

	lock throttle to slopeInterceptCalc2(questLex,ship:velocity:surface:mag).
}


pwset("End of Main Script").
until 0 { wait 0. } // main loop wait forever

// Steam\steamapps\common\Kerbal Space Program\settings.cfg
// SCREEN_RESOLUTION_WIDTH = 3830
// SCREEN_RESOLUTION_HEIGHT = 2050
// FULLSCREEN = False

