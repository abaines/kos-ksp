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
local box1 to sasGui:AddHLayout().

// slider with range from 0 (horizon) to 90 (straight up)
local slider is box1:AddHSlider.
set slider:min to 0.
set slider:max to 90.
set slider:value to 1.

// steering heading based on slider value
lock steerHeading to HEADING(90,max(0,90-slider:value)).

// draw vector to slider lean (manual gravity turn)
local vddSliderSteerHeading is VECDRAW_DEL(
	{ return ship:position. },
	{ return 35*convertToVector(steerHeading). },
	RGB(0.0,0.9,0.5)
).


// basic SAS options
local boxBasicSas to sasGui:AddHLayout().

local unlock_steering_button to boxBasicSas:addButton("unlock").
set unlock_steering_button:style:hstretch to false.
set unlock_steering_button:ONCLICK to {
	pwset("unlock steering").
	unlock steering.
}.

local prograde_button to boxBasicSas:addButton("prograde").
set prograde_button:style:hstretch to false.
set prograde_button:ONCLICK to {
	pwset("prograde").
	lock steering to ship:prograde:vector.
}.

local retro_orbit_button to boxBasicSas:addButton("retro orbit").
set retro_orbit_button:style:hstretch to false.
set retro_orbit_button:ONCLICK to {
	pwset("retro orbit").
	lock steering to -1*ship:prograde:vector.
}.

local retro_button to boxBasicSas:addButton("retro surface").
set retro_button:style:hstretch to false.
set retro_button:ONCLICK to {
	pwset("retro surface").
	lock steering to -1*ship:srfprograde:vector.
}.

local normal_button to boxBasicSas:addButton("normal").
set normal_button:style:hstretch to false.
set normal_button:ONCLICK to {
	pwset("normal").
	lock steering to vec_ship_normal().
}.

local antinormal_button to boxBasicSas:addButton("anti-normal").
set antinormal_button:style:hstretch to false.
set antinormal_button:ONCLICK to {
	pwset("anti-normal").
	lock steering to -1*vec_ship_normal().
}.


sasGui:show().

// lock steering to slider bar
lock steering to steerHeading.


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

