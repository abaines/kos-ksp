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
	set terminal:height to 42.
}

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
print("guiSas.ks 00").

wait 0.

print(CORE:tag).

setLoadDistances(32).

sas off.
rcs off.
abort off.


// traveling vector
local vddTravel is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
// facing vector
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*25. }, RGB(0.1,0.1,0.1)).


// draw vector to waypoint
local vddWaypoint is VECDRAW_DEL(
	{ return ship:position. },
	{ return waypoint("Kraken's Awe"):position. },
	RGB(0.9,0.1,0.1)
).

// main gui for lean angle (manual gravity turn)
local sasGui is GUI(1900).
set sasGui:y to 1400.

// slider with range from 0 (horizon) to 90 (straight up)
local slider is sasGui:AddHSlider.
set slider:min to 0.
set slider:max to 90.

// steering heading based on slider value
lock steerHeading to HEADING(90,max(0,90-slider:value)).

// draw vector to slider lean (manual gravity turn)
local vddWaypoint is VECDRAW_DEL(
	{ return ship:position. },
	{ return 35*convertToVector(steerHeading). },
	RGB(0.0,0.9,0.5)
).

sasGui:show().

// lock steering to slider bar
lock steering to steerHeading.



pwset("End of Main Script").
until 0 { wait 0. } // main loop wait forever

