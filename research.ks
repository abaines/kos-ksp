@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup().

set terminal:width  to 42.
set terminal:height to 20.


print "research.ks 13".
print "geo: "+round(ship:geoposition:lat,14) + ", " + round(ship:geoposition:lng,14).

global experimentstate to lex().
experimentstate:add("ship:name",ship:name).
experimentstate:add("ship:geoposition",ship:geoposition).
writejson(experimentstate, "experiment.json").

rcs off.
sas off.

managePanelsAndAntenna().

manageFuelCells().

global waypointName to "TMA-2".

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

global ksplaunchpadgeo to ksplaunchpad().
local vddLaunchPad is VECDRAW_DEL({return ship:position.}, { return ksplaunchpadgeo:position. }, RGB(0,1,0)).

global kspRunwayStartGeo to kspRunwayStart().
local vddRunwayStart is VECDRAW_DEL({return ship:position.}, { return kspRunwayStartGeo:position. }, RGB(0,1,0)).

global kspRunwayEndGeo to kspRunwayEnd().
local vddRunwayEnd is VECDRAW_DEL({return ship:position.}, { return kspRunwayEndGeo:position. }, RGB(0,1,0)).

local vddRunway is VECDRAW_DEL({return kspRunwayStartGeo:position-ship:position+1*vec_up().}, { return kspRunwayEndGeo:position-kspRunwayStartGeo:position. }, RGB(0.8,0.8,0.8)).

lock travelDirection to VXCL(vec_up(),ship:srfprograde:vector):normalized.
lock leadDirection to VXCL(vec_up(),ship:facing:vector):normalized.

local vddTravel is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
local vddTravelFlat is VECDRAW_DEL({return ship:position.}, { return travelDirection*10. }, RGB(0,1,1)).

local vddUp is VECDRAW_DEL({return ship:position.}, { return vec_up():normalized*7. }, RGB(1,1,1)).
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*10. }, RGB(0.1,0.1,0.1)).

lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

controlFromHerePart().



global movableMarkGeo to LATLNG(-00.049,-74.611).
local vddMovableMark is VECDRAW_DEL({return movableMarkGeo:position-ship:position+42*vec_up().}, { return -40*vec_up(). }, RGB(0.9,0.8,0.2), "", 1, true, 0.7).



local guiGeoResearch is GUI(200).
guiGeoResearch:ADDLABEL("Geo Research").
local guiShipGeoPositionLat is guiGeoResearch:ADDLABEL("guiShipGeoPositionLat").
local guiShipGeoPositionLng is guiGeoResearch:ADDLABEL("guiShipGeoPositionLng").

local gridUpdateDelegate to createButtonGridWithTextFields(guiGeoResearch, movableMarkGeo:lat, movableMarkGeo:lng,{
	parameter xx, yy.
	set movableMarkGeo to LATLNG(xx,yy).
}).

addButtonDelegate(guiGeoResearch,"Ship", {
	local shipGeoPosition to ship:geoposition.
	gridUpdateDelegate(shipGeoPosition:lat,shipGeoPosition:lng).
	set movableMarkGeo to shipGeoPosition.
}).

when true then
{
	set guiShipGeoPositionLat:text to "" + round(ship:geoposition:lat,9).
	set guiShipGeoPositionLng:text to "" + round(ship:geoposition:lng,9).

	return true.
}
guiGeoResearch:show().


until 0 { wait 0. } // main loop wait forever

print "end of file".
