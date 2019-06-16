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
	stopwarp().

	CLEARSCREEN.

	CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

	if terminal:width<42 {set terminal:width to 42.}

	if terminal:height<30 {set terminal:height to 30.}

	CLEARVECDRAWS().
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
			HUDTEXT("Space!1", 15, 1, 15, BLUE, false).
			HUDTEXT("Space!2", 15, 2, 15, BLUE, false).
			HUDTEXT("Space!3", 15, 3, 15, BLUE, false).
			HUDTEXT("Space!4", 15, 4, 15, BLUE, false).
			panels on.
			setantenna(true).
			set areDeployed to true.
			set protector to t + 10.
		}
		else if alt<spaceAlt and areDeployed
		{
			stopwarp().
			HUDTEXT("Air!1", 15, 1, 15, CYAN, false).
			HUDTEXT("Air!2", 15, 2, 15, CYAN, false).
			HUDTEXT("Air!3", 15, 3, 15, CYAN, false).
			HUDTEXT("Air!4", 15, 4, 15, CYAN, false).
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
				//local perc is r:amount / r:capacity.
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

FUNCTION MANEUVER_TIME
{
  PARAMETER dV.

  LIST ENGINES IN en.

  LOCAL f IS en[0]:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
  LOCAL m IS SHIP:MASS * 1000.        // Starting mass (kg)
  LOCAL e IS CONSTANT():E.            // Base of natural log
  LOCAL p IS en[0]:ISP.               // Engine ISP (s)
  LOCAL g IS 9.80665.                 // Gravitational acceleration constant (m/s²)

  RETURN g * m * p * (1 - e^(-dV/(g*p))) / f.
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

	//print (time:seconds-startTime).
	return antennaModules.
}

function modHelper
{
	parameter module.

	local us TO UNIQUESET().

	for f in module:ALLFIELDS
	{
		us:add(f).
	}
	for fn in module:ALLFIELDNAMES
	{
		us:add(fn).
	}
	for e in module:ALLEVENTS
	{
		us:add(e).
	}
	for en in module:ALLEVENTNAMES
	{
		us:add(en).
	}
	for a in module:ALLACTIONS
	{
		us:add(a).
	}
	for an in module:ALLACTIONNAMES
	{
		us:add(an).
	}

	return us.
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

	//local i to 0.
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
	//local mark_intersectV to VECDRAWARGS(body:position, intersectV, RGB(1.0,0,0), "intsctV", 1, true).

	local shipVec is ship:position - body:position.
	//local mark_shipVec to VECDRAWARGS(body:position, shipVec, RGB(0,0,1), "", 1, true).

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

			//VECDRAWARGS(body:position, tShipVec, RGB(0,1/(5-i),1/(i+1)), "", 1, true).

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
	hudtext("" + satelliteName + " #"+antennae:length, 15, 4, 15, white, false).
}



/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !