@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup().

set terminal:width  to 42.
set terminal:height to 20.


print "research.ks 13".

print ship:geoposition.
global experimentstate to lex().
experimentstate:add("ship:name",ship:name).
experimentstate:add("ship:geoposition",ship:geoposition).
writejson(experimentstate, "experiment.json").

rcs on.
sas off.

managePanelsAndAntenna().

manageFuelCells().

global waypointName to "TMA-2".

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

global ksplaunchpadgeo to ksplaunchpad().
local vddLaunchPad is VECDRAW_DEL({return ship:position.}, { return ksplaunchpadgeo:position. }, RGB(0,1,0)).

lock travelDirection to VXCL(vec_up(),ship:srfprograde:vector):normalized.
lock leadDirection to VXCL(vec_up(),ship:facing:vector):normalized.

local vddTravel is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
local vddTravelFlat is VECDRAW_DEL({return ship:position.}, { return travelDirection*10. }, RGB(0,1,1)).

local vddUp is VECDRAW_DEL({return ship:position.}, { return vec_up():normalized*7. }, RGB(1,1,1)).
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*10. }, RGB(0.1,0.1,0.1)).

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

controlFromHerePart().





until 0 { wait 0. } // main loop wait forever

print "end of file".
