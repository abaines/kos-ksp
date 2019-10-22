/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

@LAZYGLOBAL off.


GLOBAL voice0 TO GetVoice(0).
SET voice0:VOLUME TO 0.20.

/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !


// kerbal space center launch pad
function kspLaunchPad
{
	return LATLNG(-0.0972077948308072,-74.557676885654786).
}


// ksc kerbal space center Runway start space hanger launch
function kspRunwayStart
{
	return LATLNG(-0.048599996665065981,-74.724473624279071).
}


// ksc kerbal space center Runway end space hanger land
function kspRunwayEnd
{
	return LATLNG(-0.05016922733662988,-74.498071382014942).
}



/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !



function librarysetup
{
	PARAMETER OpenTerminal is true.

	stopwarp().

	CLEARSCREEN.

	if OpenTerminal
		CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

	if terminal:width<42 {set terminal:width to 42.}

	if terminal:height<30 {set terminal:height to 30.}

	CLEARVECDRAWS().

	CLEARGUIS().
}


function beep
{
	parameter hertz is 1000, volume is 0.3, duration is 0.01, keyDownLength is 0.01.

	voice0:PLAY( NOTE( hertz, duration, keyDownLength, volume) ).
}


function stopwarp
{
	KUNIVERSE:TIMEWARP:CANCELWARP().
}


function delayUntilSteady
{
	parameter duration is 10, maxSpeed is 0.009, printat is 4.

	local check is time:seconds.
	lock passed to Time:seconds - check.

	lock shipSpeed to SHIP:VELOCITY:surface:MAG.

	UNTIL (passed>duration or ship:ALTITUDE>1000)
	{
		if shipSpeed>0.009
		{
			set check to time:seconds.
		}

		print "Stable Time         : " + passed at(45,printat).
		print "Speed               : " + shipspeed at(45,printat+1).
		print "Angle From Up       : " + ang_facingFromUp() at(45,printat+2).

		wait 0.
	}

	print "                                            "  at(45,printat).
	print "                                            "  at(45,printat+1).
	print "                                            "  at(45,printat+2).
}


// find part tagged 'cfh' and use it for control from here
function controlFromHerePart
{
	local cfgParts to ship:partstagged("cfh").

	local cfgPartsLength to cfgParts:length.
	if cfgPartsLength<>1
	{
		print "Found "+cfgPartsLength+" parts tagged with 'cfh'.".
	}

	cfgParts[0]:controlfrom().
}


function managePanelsAndAntenna
{
	parameter spaceAlt is 70000.

	lock alt to SHIP:ALTITUDE.
	lock t to time:seconds.

	local areDeployed is true.
	local protector to t + 1.

	when true then
	{
		if t < protector
		{
			// delay
		}
		else if alt>spaceAlt and not areDeployed
		{
			stopwarp().
			HUD("Space!", 15, "1234", 15, BLUE, false).
			panels on.
			setantenna(true).
			set areDeployed to true.
			set protector to t + 10.
		}
		else if alt<spaceAlt and areDeployed
		{
			stopwarp().
			HUD("Air!", 15, "1234", 15, CYAN, false).
			panels off.
			setantenna(false).
			set areDeployed to false.
			set protector to t + 10.
		}
		else
		{
			set protector to t + 1.
		}

		PRESERVE.
	}
}


function manageFuelCells
{
	parameter threshold is 1/3.

	lock electricchargepercent to GetShipResourcePercent("electriccharge").
	lock t to time:seconds.

	local cellsDeployed is false.
	local protector to t + 1.

	when true then
	{
		if t < protector
		{
			// delay
		}
		else if electricchargepercent < threshold and not cellsDeployed
		{
			stopwarp().
			FUELCELLS ON.
			print "fuelcells on.".
			set cellsDeployed to true.
			set protector to t + 2.
		}
		else if electricchargepercent > threshold and cellsDeployed
		{
			FUELCELLS OFF.
			print "fuelcells off.".
			set cellsDeployed to false.
			set protector to t + 2.
		}
		else
		{
			set protector to t + 1.
		}

		PRESERVE.
	}
}


// toggle inflatable heat shields
function ToggleHeatShields
{
	parameter heatShields is ship:PARTSDUBBED("Heat Shield (10m)").
	parameter value is true.

	for heatShield in heatShields
	{
		if fireActionOnModuleOnPart(heatShield,"ModuleAnimateGeneric","inflate heat shield",value)
		{
			print("Toggling Heat Shields").
		}
	}
}


function GetStageLowestResource
{
	parameter resourceType.

	local srlrt is stage:resourceslex[resourceType].

	local lowest is reallyBigNumber.

	for p in srlrt:parts
	{
		for r in p:RESOURCES
		{
			if r:name = resourceType
			{
				local perc is r:amount.

				if perc < lowest
				{
					set lowest to perc.
				}
				break.
			}
		}
	}
	return lowest.
}


function GetShipResourcePercent
{
	parameter resourceType.

	local ramount is 0.
	local rcapacity is 0.

	for r in ship:RESOURCES
	{
		if r:name = resourceType
		{
			set ramount to r:amount + ramount.
			set rcapacity to r:capacity + rcapacity.
		}
	}

	if (rcapacity = 0)
	{
		return -1.
	}
	return ramount / rcapacity.
}


// get the amount of a given resource from a given part
function getPartsResource
{
	parameter thePart, resourceType.

	for resource in thePart:resources
	{
		if resource:name = resourceType
		{
			return resource:amount.
		}
	}
	return -1.
}


// get the max vaccume isp of any/all engines
function maxVISP
{
	local m is -1.
	for eng in listEngines()
	{
		set m to max(m,eng:visp).
	}
	return m.
}


// turn on sas to the given mode and unlock steering
function setSasMode
{
	parameter _mode.
	// "PROGRADE", "RETROGRADE",
	// "NORMAL", "ANTINORMAL",
	// "RADIALOUT", "RADIALIN",
	// "TARGET", "ANTITARGET",
	// "MANEUVER",
	// "STABILITYASSIST", and "STABILITY"
	sas on.
	wait 0.
	set sasmode to _mode.
	unlock steering.
}


function setantenna
{
	parameter activate.

	local startTime to time:seconds.

	if activate
	{
		set activate to "extend antenna".
	}
	else
	{
		set activate to "retract antenna".
	}

	local antennaModules is list().

	for part in ship:PARTSDUBBEDPATTERN("(antenna|dish|comm)")
	{
		local partname is part:name.

		for modname in part:modules
		{
			local module is part:getmodule(modname).

			for eventname in module:ALLEVENTNAMES
			{
				if eventname:contains("antenna")
				{
					antennaModules:add(lex(
						"partname", partname,
						"modname", modname,
						"eventname", eventname,
						"module", module
					)).

					if eventname:contains(activate)
					{
						if module:hasevent(activate)
						{
							module:DOEVENT(activate).
						}
					}
				}
			}
		}
	}

	return antennaModules.
}


// auto decouple fuel tanks that have self-contained decouplers
function autoDecoupleFuel
{
	parameter autoTankParts to ship:PARTSDUBBEDPATTERN("IFS Cryogenic Dual Tank ").

	when true then
	{
		local decoupled to 0.

		local nextList to list().

		for tankPart in autoTankParts
		{
			local liquidfuel is getPartsResource(tankPart,"liquidfuel").
			if liquidfuel < 0.1
			{
				set decoupled to 1 + decoupled.
				tankPart:getmodule("ModuleAnchoredDecoupler"):Doevent("Decouple").
			}
			else
			{
				nextList:add(tankPart).
			}
			if liquidfuel < 588
			{
				HIGHLIGHT(tankPart,RGB(1,0.5,0)).
			}
		}

		if decoupled>0
		{
			print("decoupled: "  + decoupled).
			wait 0.
		}

		set autoTankParts to nextList.

		return autoTankParts:length>0.
	}
}


// search for module callable (field/event/action) with regex search text.
// returns lex<part:title,lex<partModule:name,set<text>>>
function searchForModuleCallablesByName
{
	parameter searchText.
	parameter _parts is getAllParts().

	// partModule:part:title -> partModule:name -> text
	local lex is lexicon().

	function updateLex
	{
		parameter partModule,text.

		//  Regular Expression search
		if text:MATCHESPATTERN(searchText)
		{
			local partTitle is partModule:part:title.
			local moduleName is partModule:name.
			if not lex:haskey(partTitle)
			{
				lex:add(partTitle,lexicon()).
			}
			if not lex[partTitle]:haskey(moduleName)
			{
				lex[partTitle]:add(moduleName,UniqueSet()).
			}
			lex[partTitle][moduleName]:add(text).
		}
	}

	for partModule in getPartModulesForParts(_parts)
	{
		for text in partModule:ALLFIELDS
		{
			updateLex(partModule,text).
		}
		for text in partModule:ALLEVENTS
		{
			updateLex(partModule,text).
		}
		for text in partModule:ALLACTIONS
		{
			updateLex(partModule,text).
		}
	}

	return lex.
}


// given a partModule, return all of the fields/events/actions/names for it
// returns SET<String>
function modHelper
{
	parameter module, includeNames is true.

	local us TO UNIQUESET().

	for f in module:ALLFIELDS
	{
		us:add(f).
	}
	for e in module:ALLEVENTS
	{
		us:add(e).
	}
	for a in module:ALLACTIONS
	{
		us:add(a).
	}

	if includeNames
	{
		for fn in module:ALLFIELDNAMES
		{
			us:add(fn).
		}
		for en in module:ALLEVENTNAMES
		{
			us:add(en).
		}
		for an in module:ALLACTIONNAMES
		{
			us:add(an).
		}
	}

	return us.
}


// get all of the modules for a given part
// returns list<PartModule>
function getPartModulesForPart
{
	parameter _part.
	local partModules is list().

	for module in _part:MODULES
	{
		partModules:add(_part:GETMODULE(module)).
	}

	return partModules.
}


// get all of the modules for a set of parts
// returns list<PartModule>
function getPartModulesForParts
{
	parameter _parts.
	local partModules is list().

	for _part in _parts
	{
		for module in _part:MODULES
		{
			partModules:add(_part:GETMODULE(module)).
		}
	}

	return partModules.
}


// filter a list of PartModules to just those with a given field name
// returns list<PartModule>
function filterPartModulesWithField
{
	parameter partModules, fieldName.
	local _partModules is list().

	for partModule in partModules
	{
		if partModule:HasField(fieldName)
		{
			_partModules:add(partModule).
		}
	}

	return _partModules.
}


// given a list<PartModule> calls SetField on each of them
// return list<part> associated with fields that were set
function setFieldOfPartModules
{
	parameter partModules, fieldName, fieldValue.
	local _parts is list().

	for partModule in partModules
	{
		if partModule:HasField(fieldName)
		{
			partModule:SETFIELD(fieldName,fieldValue).
			_parts:add(partModule:part).
		}
	}
	return _parts.
}


// does the given action exist on the given module on the given part?
// return true if the action exists
function doesPartWithModuleWithAction
{
	parameter _part.
	parameter moduleName.
	parameter actionName.

	if _part:hasmodule(moduleName)
	{
		local module to _part:getmodule(moduleName).
		if module:hasaction(actionName)
		{
			return true.
		}
	}
	return false.
}


// fire an action on a module of a part
// returns true if able to find|do action
function fireActionOnModuleOnPart
{
	parameter _part.
	parameter moduleName.
	parameter actionName.
	parameter actionValue.

	if _part:hasmodule(moduleName)
	{
		local module to _part:getmodule(moduleName).
		if module:hasaction(actionName)
		{
			module:doaction(actionName,actionValue).
			return true.
		}
	}
	return false.
}


function setupRemoteTechAntenna
{
	// https://ksp-kos.github.io/KOS/addons/RemoteTech.html?highlight=modulertantenna#antennas
	// "no-target", "active-vessel", a Body, a Vessel, "Mission Control"
	parameter partTagText, satelliteName, shouldActivate.

	local antennae to ship:partsTagged(partTagText).
	for antennaI in antennae
	{
		local gmodule to antennaI:GETMODULE("ModuleRTAntenna").
		gmodule:setField("target",satelliteName).
		if shouldActivate and gmodule:HasEvent("activate")
		{
			gmodule:DOEVENT("activate").
		}
	}
	local text is "" + satelliteName + " #"+antennae:length.
	HUDTEXT(text, 15, 4, 15, white, false).
}



/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !



// display current load distances
function printLoadDistances
{
	local distances TO KUNIVERSE:DEFAULTLOADDISTANCE.

	PRINT "orbit distances:".
	print "    load: " + distances:ORBIT:LOAD:TOSTRING:padLeft(7) + "m".
	print "  unload: " + distances:ORBIT:UNLOAD:TOSTRING:padLeft(7) + "m".
	print "  unpack: " + distances:ORBIT:UNPACK:TOSTRING:padLeft(7) + "m".
	print "    pack: " + distances:ORBIT:PACK:TOSTRING:padLeft(7) + "m".

	PRINT "escaping distances:".
	print "    load: " + distances:ESCAPING:LOAD:TOSTRING:padLeft(7) + "m".
	print "  unload: " + distances:ESCAPING:UNLOAD:TOSTRING:padLeft(7) + "m".
	print "  unpack: " + distances:ESCAPING:UNPACK:TOSTRING:padLeft(7) + "m".
	print "    pack: " + distances:ESCAPING:PACK:TOSTRING:padLeft(7) + "m".

	PRINT "suborbital distances:".
	print "    load: " + distances:SUBORBITAL:LOAD:TOSTRING:padLeft(7) + "m".
	print "  unload: " + distances:SUBORBITAL:UNLOAD:TOSTRING:padLeft(7) + "m".
	print "  unpack: " + distances:SUBORBITAL:UNPACK:TOSTRING:padLeft(7) + "m".
	print "    pack: " + distances:SUBORBITAL:PACK:TOSTRING:padLeft(7) + "m".

	PRINT "flying distances:".
	print "    load: " + distances:FLYING:LOAD:TOSTRING:padLeft(7) + "m".
	print "  unload: " + distances:FLYING:UNLOAD:TOSTRING:padLeft(7) + "m".
	print "  unpack: " + distances:FLYING:UNPACK:TOSTRING:padLeft(7) + "m".
	print "    pack: " + distances:FLYING:PACK:TOSTRING:padLeft(7) + "m".

	PRINT "landed distances:".
	print "    load: " + distances:LANDED:LOAD:TOSTRING:padLeft(7) + "m".
	print "  unload: " + distances:LANDED:UNLOAD:TOSTRING:padLeft(7) + "m".
	print "  unpack: " + distances:LANDED:UNPACK:TOSTRING:padLeft(7) + "m".
	print "    pack: " + distances:LANDED:PACK:TOSTRING:padLeft(7) + "m".

	PRINT "prelaunch distances:".
	print "    load: " + distances:PRELAUNCH:LOAD:TOSTRING:padLeft(7) + "m".
	print "  unload: " + distances:PRELAUNCH:UNLOAD:TOSTRING:padLeft(7) + "m".
	print "  unpack: " + distances:PRELAUNCH:UNPACK:TOSTRING:padLeft(7) + "m".
	print "    pack: " + distances:PRELAUNCH:PACK:TOSTRING:padLeft(7) + "m".

	PRINT "splashed distances:".
	print "    load: " + distances:SPLASHED:LOAD:TOSTRING:padLeft(7) + "m".
	print "  unload: " + distances:SPLASHED:UNLOAD:TOSTRING:padLeft(7) + "m".
	print "  unpack: " + distances:SPLASHED:UNPACK:TOSTRING:padLeft(7) + "m".
	print "    pack: " + distances:SPLASHED:PACK:TOSTRING:padLeft(7) + "m".
}


// set vessel load distances for unload/pack by given multiplier
function setLoadDistances
{
	parameter multiplierValue is 10.

	local distances TO KUNIVERSE:DEFAULTLOADDISTANCE.
	WAIT 0.

	SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNLOAD TO multiplierValue*15000.
	//SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:LOAD TO multiplierValue*1.
	WAIT 0.
	SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:PACK TO multiplierValue*10000.
	//SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNPACK TO multiplierValue*1.
	WAIT 0.

	SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNLOAD TO multiplierValue*22500.
	//SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:LOAD TO multiplierValue*1.
	WAIT 0.
	SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:PACK TO multiplierValue*25000.
	//SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNPACK TO multiplierValue*1.
	WAIT 0.

	SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:UNLOAD TO multiplierValue*2500.
	//SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:LOAD TO multiplierValue*1.
	WAIT 0.
	SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:PACK TO multiplierValue*350.
	//SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:UNPACK TO multiplierValue*1.
	WAIT 0.

	SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:UNLOAD TO multiplierValue*2500.
	//SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:LOAD TO multiplierValue*1.
	WAIT 0.
	SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:PACK TO multiplierValue*350.
	//SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:UNPACK TO multiplierValue*1.
	WAIT 0.

	SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:UNLOAD TO multiplierValue*2500.
	//SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:LOAD TO multiplierValue*1.
	WAIT 0.
	SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:PACK TO multiplierValue*350.
	//SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:UNPACK TO multiplierValue*1.
	WAIT 0.

	print("Load distances updated: " + multiplierValue).
}


// get a list of all the vessels in the game
function getAllVessels
{
	local targetList is list().
	LIST TARGETS IN targetList.
	return targetList.
}


// get a count of all vessels and their parts
function VesselAndPartCheck
{
	parameter match is ship:name.

	local partCount is 0.
	local vesselCount is 0.
	local loadedCount is 0.
	local partList is list().

	function u
	{
		parameter ves.
		if (not ves:ISDEAD) and ves:name:contains(match) and ves:type<>"DEBRIS"
		{
			local vesParts to ves:PARTS:length.
			partList:add(vesParts).
			set partCount to vesParts + partCount.
			set vesselCount to 1 + vesselCount.
			if ves:loaded
			{
				set loadedCount to 1 + loadedCount.
			}
		}
	}

	u(ship).
	for ves in getAllVessels()
	{
		u(ves).
	}

	return "Ships: " + loadedCount + " / " + vesselCount + "   Parts: " + partCount + " (" + partList:join("+") + ")".
}



// get a list of all the parts in this vessel
function getAllParts
{
	local partList is list().
	LIST PARTS IN partList.
	return partList.
}


// return the number of cpu cores "kOSProcessor" on this ship|vessel
function getCpuCoreCount
{
	return ship:MODULESNAMED("kOSProcessor"):length.
}


// get the current total thrust of all engines
function totalCurrentThrust
{
	local sum is 0.
	FOR eng IN listEngines()
	{
		set sum to eng:thrust + sum.
	}.
	return sum.
}


// get the max thrust of all engines
function totalMaxThrust
{
	local sum is 0.
	FOR eng IN listEngines()
	{
		set sum to eng:MAXTHRUST + sum.
	}.
	return sum.
}


// get a list of all ENGINES
function listEngines
{
	local engineList is list().
	list ENGINES in engineList.
	return engineList.
}


// alternate to ship:sensors:grav:mag
function calculateGravity
{
	return body:mu / (altitude + body:radius)^2.
}


// attempts to convert input to vector
function convertToVector
{
	parameter _input.

	if _input:ISTYPE("vector")
	{
		return _input.
	}
	else if _input:istype("direction")
	{
		return _input:vector.
	}
	else
	{
		print("!! convertToVector unknown type:").
		print(_input:INHERITANCE).
		print(_input:tostring).
		return V(0,0,0).
	}
}



/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

