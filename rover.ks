@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup().

when time:seconds > scriptEpoch + 10 then
{
	set terminal:width  to 42.
	set terminal:height to 20.
}

print "rover.ks 13".

print ship:geoposition.
global experimentstate to lex().
if exists("experiment.json")
{
	set experimentstate to READJSON("experiment.json").
}
set experimentstate["ship:name"] to ship:name.
set experimentstate["ship:geoposition"] to geopositionToLex(ship:geoposition).
WRITEJSON(experimentstate, "experiment.json").
READJSON("experiment.json").

rcs off.
sas off.

controlFromHerePart().

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

local vddUpwardMovement is VECDRAW_DEL({return ship:position.}, { return 10*upwardMovementVec. }, RGB(1,0,1)).

lock travelDirection to VXCL(vec_up(),ship:srfprograde:vector):normalized.
lock leadDirection to VXCL(vec_up(),ship:facing:vector):normalized.

local vddTravel is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
local vddTravelFlat is VECDRAW_DEL({return ship:position.}, { return travelDirection*10. }, RGB(0,1,1)).
local vddLean is VECDRAW_DEL({return ship:position.}, { return leadDirection*10. }, RGB(1,1,0)).

local vddUp is VECDRAW_DEL({return ship:position.}, { return vec_up():normalized*7. }, RGB(1,1,1)).
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*10. }, RGB(0.1,0.1,0.1)).


local lastSetBrakes to true.
brakes on.

local goalSpeed to 11.

when true then
{
	if ship:velocity:surface:mag>goalSpeed and not lastSetBrakes
	{
		brakes on.
		set lastSetBrakes to true.
	}
	else if ship:velocity:surface:mag<goalSpeed and lastSetBrakes
	{
		brakes off.
		set lastSetBrakes to false.
	}

	return true.
}

setLoadDistances(10).
printLoadDistances().

for ves in getAllVessels()
{
	if ( ves:LOADED or ves:UNPACKED ) or ( ves:TYPE <> "SpaceObject" and ves:status<>"orbiting" )
	{
		local stringBuilder to "`"+ves:name + "` " + ves:status:TOLOWER + " " + ves:TYPE:TOLOWER.
		if ves:loaded
		{
			set stringBuilder to stringBuilder + " LOADED".
		}
		if ves:unpacked
		{
			set stringBuilder to stringBuilder + " UNPACKED".
		}
		print(stringBuilder).
	}
}

local roverGui is gui(200).
local roverGuiLabel is roverGui:addlabel("Rover Data").
local launchpadLabel is roverGui:addlabel("launchpadLabel").
local runwayStartLabel is roverGui:addlabel("runwayStartLabel").
local runwayEndLabel is roverGui:addlabel("runwayEndLabel").
when true then
{
	set launchpadLabel:text to ""+kspLaunchPad():distance.
	set runwayStartLabel:text to ""+kspRunwayStart():distance.
	set runwayEndLabel:text to ""+kspRunwayEnd():distance.

	return true.
}
roverGui:show().


until 0 { wait 0. } // main loop wait forever
print "end of file".

