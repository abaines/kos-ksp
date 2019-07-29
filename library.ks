/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

@LAZYGLOBAL off.

// the following are all vectors, mainly for use in the roll, pitch, and angle of attack calculations
function vec_rightrotation { return ship:facing*r(0,90,0). }

function vec_right { return (ship:facing*r(0,90,0):vector). } //right and left are directly along wings
function vec_left { return (-1)*(ship:facing*r(0,90,0):vector). }

function vec_up { return ship:up:vector. } //up and down are skyward and groundward
function vec_down { return (-1)*(ship:up:vector). }

function vec_fore { return ship:facing:vector. } //fore and aft point to the nose and tail
function vec_aft { return (-1)*(ship:facing:vector). }

function vec_righthor { return vcrs(ship:up:vector,ship:facing:vector). } //right and left horizons
function vec_lefthor { return (-1)*vcrs(ship:up:vector,ship:facing:vector). }

function vec_forehor { return vcrs(vcrs(ship:up:vector,ship:facing:vector),ship:up:vector). } //forward and backward horizons
function vec_afthor { return (-1)*vcrs(vcrs(ship:up:vector,ship:facing:vector),ship:up:vector). }

function vec_top { return vcrs(ship:facing:vector,ship:facing*r(0,90,0):vector). } //above the cockpit, through the floor
function vec_bottom { return (-1)*vcrs(ship:facing:vector,ship:facing*r(0,90,0):vector). }

// the following are all angles, useful for control programs
function ang_absaoa { return vang(ship:facing:vector,srfprograde:vector). } //absolute angle of attack (surface)
function ang_aoa { return vang( vcrs(ship:facing:vector,(ship:facing*r(0,90,0):vector)) ,srfprograde:vector)-90. } //pitch component of angle of attack
function ang_sideslip { return vang((ship:facing*r(0,90,0):vector),srfprograde:vector)-90. } //yaw component of aoa

function ang_rollangle { return vang((ship:facing*r(0,90,0):vector),vcrs(ship:up:vector,ship:facing:vector))*((90-vang(top,vcrs(ship:up:vector,ship:facing:vector)))/abs(90- vang(top,vcrs(ship:up:vector,ship:facing:vector)))). } //roll angle, 0 at level flight
function ang_pitchangle { return vang(ship:facing:vector,vcrs(vcrs(ship:up:vector,ship:facing:vector),ship:up:vector))*((90-vang(ship:facing:vector,up))/abs(90-vang(ship:facing:vector,up))). } //pitch angle, 0 at level flight

function ang_glideslope { return vang(srfprograde:vector,vcrs(vcrs(ship:up:vector,ship:facing:vector),ship:up:vector))*((90-vang(srfprograde:vector,up))/abs(90-vang(srfprograde:vector,up))). }
function ang_ascentangle { return vang(srfprograde:vector, vcrs(vcrs(ship:up:vector,ship:facing:vector),ship:up:vector)). } //angle of surface prograde above horizon

function ang_ascentslope { return 90 - vang(ship:up:vector,srfprograde:vector). } // traveling angle from up.

function ang_orbitaoa { return vang(ship:facing:vector,prograde:vector). } //absolute angle of attack (orbit)

function ang_facingFromUp { return vang(ship:facing:vector,ship:up:vector). }

/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

function VECDRAW_DEL
{
	parameter start_, vec_, color_ is White, label_ is "", scale_ is 1.0, show_ is true, width_ is 0.2.

	local vdd is VECDRAW(start_(),vec_(),color_,label_,scale_,show_,width_).
	set vdd:STARTUPDATER to start_.
	set vdd:VECUPDATER to vec_.

	return vdd.
}

// Vector Projection
function vector_projection
{
	// https://en.wikipedia.org/wiki/Vector_projection
	parameter vecU, vecV.

	local magU is vecU:mag.
	local term1 is vdot(vecV,vecU) / magU.
	local term2 is vecU / magU.
	return term1 * term2.
}

/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

global reallyBigNumber is 2147483646.


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


// get smart position for a latlng|geo such that always above sea level
function smartGeoPosition
{
	parameter givenLatLng.

	if givenLatLng:terrainheight>0
	{
		return givenLatLng:position.
	}
	else
	{
		return givenLatLng:altitudeposition(0).
	}
}


/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !


FUNCTION average
{
	// https://ksp-kos.github.io/KOS/language/variables.html
	PARAMETER items.

	LOCAL sum IS 0.
	FOR val IN items
	{
		SET sum TO sum + val.
	}.

	RETURN sum / items:LENGTH.
}.


function max3
{
	PARAMETER v1,v2,v3.

	return max(max(v1,v2),v3).
}


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

function maxAcceleration
{
	local smass is max(ship:mass,0.0000001).
	local accel is ship:maxthrust/smass.
	return max(accel,0.0000001).
}

function eta_apoapsis
{
	if ETA:APOAPSIS < ETA:PERIAPSIS
	{
		return ETA:APOAPSIS.
	}
	else
	{
		return ETA:APOAPSIS - ship:orbit:period.
	}
}

function eta_periapsis
{
	if ETA:PERIAPSIS < ETA:APOAPSIS
	{
		return ETA:PERIAPSIS.
	}
	else
	{
		return ETA:PERIAPSIS - ship:orbit:period.
	}
}

function slopeIntercept
{
	parameter x, y, a, b.

	// slope
	local s is (b-y)/(a-x).

	// intercept
	local i is  b - s * a.

	return lex(
		"slope",s,
		"intercept",i,
		"x", x,
		"y", y,
		"a", a,
		"b", b
	).
}

function slopeInterceptValue
{
	parameter si, val, clam.

	local r is si["slope"] * val + si["intercept"].

	if clam
	{
		return clamp(r,si["y"],si["b"]).
	}
	else
	{
		return r.
	}
}

function slopeInterceptLex2
{
	parameter input1, output1, input2, output2, doClamp.

	// slope
	local slope is (output2-output1)/(input2-input1).

	// intercept
	local intercept is output2 - slope * input2.

	return lex(
		"slope",slope,
		"intercept",intercept,
		"input1", input1,
		"output1", output1,
		"input2", input2,
		"output2", output2,
		"clamp", doClamp
	).
}

function slopeInterceptCalc2
{
	parameter sil, val.

	local result is sil["slope"] * val + sil["intercept"].

	if sil["clamp"]
	{
		return clamp(result,sil["output1"],sil["output2"]).
	}
	else
	{
		return result.
	}
}

function clamp
{
	parameter val, c1, c2.

	local mi is min(c1,c2).
	local ma is max(c1,c2).

	if val < mi
	{
		return mi.
	}
	else if val > ma
	{
		return ma.
	}
	else
	{
		return val.
	}
}

function stopwarp
{
	KUNIVERSE:TIMEWARP:CANCELWARP().
}

function BetweenVector
{
	// assume vec1 and vec2 are 90degrees apart.
	parameter vec1, vec2, angle.

	local vec1n is vec1:normalized.
	local vec2n is vec2:normalized.

	local vec1nm is vec1n * cos(angle).

	local r is (vec1n*cos(angle))+(vec2n*sin(angle)).

	return r:normalized.
}


// calculate the vector between two others by a ratio
function RatioVector
{
	parameter vec0. // vector 0
	parameter vec1. // vector 1
	parameter ratio. // a value between 0 and 1

	local vec0n is vec0:normalized.
	local vec1n is vec1:normalized.

	local ratioC to clamp(ratio,0,1).

	return (vec0*(1-ratioC) + vec1*(ratioC)):normalized.
}


function planierize
{
	// vec1 is planer vector
	// vec2 is to be placed in vec1 plane
	parameter vec1, vec2.

	return VCRS(VCRS(vec1,vec2),vec1).
}


function orbitSpeed
{
	parameter apo is 70000, peri is 70000, gm is 3.5e12, datum is 600000.

	local simimajor is datum + (apo+peri)/2.

	local r is datum + max(apo,peri).

	local v is sqrt(gm*((2/r)-(1/simimajor))).

	return v.
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


FUNCTION MANEUVER_TIME
{
	PARAMETER dV.

	LOCAL f IS ship:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
	LOCAL m IS SHIP:MASS * 1000.        // Starting mass (kg)
	LOCAL e IS CONSTANT():E.            // Base of natural log
	LOCAL p IS maxVISP().               // Engine ISP (s)
	LOCAL g IS 9.80665.                 // Gravitational acceleration constant (m/s²)

	RETURN g * m * p * (1 - e^(-dV/(g*p))) / f.
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


function IMNG
{
	parameter dim.

	set dim to dim:tolower.

	if dim:contains("pro")
	{
		return nextnode:prograde.
	}
	else if dim:contains("rad")
	{
		return nextnode:radialout.
	}
	else if dim:contains("nor")
	{
		return nextnode:normal.
	}
	else if dim:contains("eta")
	{
		return nextnode:eta.
	}
	else
	{
		print "invalid dimension : " + dim.
		wait 0.
	}
}

function IMNS
{
	parameter dim, value.

	set dim to dim:tolower.

	if dim:contains("pro")
	{
		set nextnode:prograde to value.
	}
	else if dim:contains("rad")
	{
		set  nextnode:radialout to value.
	}
	else if dim:contains("nor")
	{
		set  nextnode:normal to value.
	}
	else if dim:contains("eta")
	{
		set  nextnode:eta to value.
	}
	else
	{
		print "invalid dimension : " + dim.
		wait 0.
	}
}

function ImproveManeuverNode
{
	parameter dim, stepsize.

	local startTime to time:seconds.

	local initNode to IMNG(dim).
	local initCA to closestapproach(ship,target).

	IMNS(dim, initNode + stepsize).
	local CAplus to closestapproach(ship,target).

	IMNS(dim, initNode - stepsize).
	local CAminus to closestapproach(ship,target).

	if CAplus["minDist"]<initCA["minDist"] and CAplus["minDist"]<CAminus["minDist"]
	{
		IMNS(dim, initNode + stepsize).
	}
	else if CAminus["minDist"]<initCA["minDist"] and CAminus["minDist"]<CAplus["minDist"]
	{
		IMNS(dim, initNode - stepsize).
	}
	else
	{
		IMNS(dim, initNode).
	}

	return lex(
		"CAminus",CAminus,
		"initCA",initCA,
		"CAplus",CAplus,
		"computeTime", (time:seconds-startTime)
	).
}


function closestapproach
{
	parameter ves1, ves2, t1 is -1, t2 is -2, step1 is 30.

	local startTime to time:seconds.

	if t1 < 0
	{
		set t1 to time:seconds.
	}
	if t2 < 0
	{
		set t2 to time:seconds + 2*max(ves1:orbit:period, ves2:orbit:period).
	}

	local bestTime1 to t1.
	local bestTime2 to t2.

	local minTime to 0.
	local minDist to 0.
	local timeStep to 0.

	for I IN RANGE(7)
	{
		local step to 7.
		if i <= 0
		{
			set step to step1.
		}
		local cah is closestapproachHelper(ves1,ves2,bestTime1,bestTime2,step).

		set timeStep to cah["timeStep"].

		set bestTime1 to cah["minTime"] - timeStep.
		set bestTime2 to cah["minTime"] + timeStep.

		set minTime to cah["minTime"].
		set minDist to cah["minDist"].
	}

	return lex(
		"bestTime1",bestTime1,
		"bestTime2",bestTime2,
		"minTime",minTime,
		"minDist",minDist,
		"timeStep",timeStep,
		"computeTime", (time:seconds-startTime)
	).
}

function closestapproachHelper
{
	parameter ves1, ves2, t1, t2, steps is 12.

	local timeStep is abs(t1 - t2)/steps.

	local minDist to 2147483646.
	local minTime to -1.

	for i in range(steps)
	{
		local tr is t1 + i*timeStep.
		local distanc is (positionat(ves1, tr) - positionat(ves2, tr)):mag.

		if distanc < minDist
		{
			set minDist to distanc.
			set minTime to tr.
		}
	}

	return lex(
		"minDist",minDist,
		"minTime",minTime,
		"timeStep",timeStep
	).
}



function EtaAscendingNode
{
	local startTime to time:seconds.

	// https://www.reddit.com/r/Kos/comments/38qa23/ascending_or_descending_node_eta/crx3l91/
	local shipV is ship:obt:velocity:orbit:normalized.
	local tarV is target:obt:velocity:orbit:normalized.

	//plane normals
	local shipN is vcrs(shipV,ship:position - body:position):normalized.
	local tarN is vcrs(tarV,target:position - body:position):normalized.
	if target:name = body:name { set tarN to ship:north:vector. }

	local intersectV to vcrs(shipN,tarN):normalized * (target:position - body:position):mag.

	local shipVec is ship:position - body:position.

	local farTime is time:seconds + ship:orbit:period.
	local nearTime is time:seconds.

	local minAngl to 2147483646.
	local minTime to -1.

	for I IN RANGE(5)
	{
		local stepSize to max(1,(farTime-nearTime) / 7).

		local timerange to range(nearTime,farTime,stepSize).

		set minAngl to 2147483646.
		set minTime to -1.

		for t in timerange
		{
			local tShipVec to positionat(ship, t) - body:position.

			local tAngl to vang(tShipVec,intersectV).

			if tAngl < minAngl
			{
				set minAngl to tAngl.
				set minTime to t.
			}
		}

		set farTime to minTime + stepSize.
		set nearTime to minTime - stepSize.
	}

	return lex(
		"farTime", farTime,
		"nearTime", nearTime,
		"errTime", farTime-nearTime,
		"eta",(minTime - time:seconds),
		"intersectV",intersectV,
		"inclination", vang(shipN,tarN),
		"computeTime", (time:seconds-startTime)
	).
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


// transform a geoposition into a lexicon for serialization
function geopositionToLex
{
	parameter someGeoPosition.
	return lexicon(
		"lat", someGeoPosition:lat,
		"lng", someGeoPosition:lng,
		"body", someGeoPosition:body:name
	).
}


// transform a lexicon into a geoposition from serialization
function geopositionFromLex
{
	parameter someLex.
	return body(someLex["body"]):GEOPOSITIONLATLNG(someLex["lat"],someLex["lng"]).
}


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
		if ves:name:contains(match)
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

