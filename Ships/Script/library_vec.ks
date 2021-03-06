/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

@LAZYGLOBAL off.

// this library is for vector, geometry, orbital mechanics, position, and other heavy/pure mathematics

global reallyBigNumber is 2147483646.

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


// normal and anti-normal
function vec_ship_normal { return vcrs(ship:velocity:orbit:normalized,-1*body:position:normalized):normalized. }
// radial in and radial out
function vec_ship_radial { return vcrs(-1*ship:velocity:orbit:normalized,vec_ship_normal):normalized. }


/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !



lock shipWeight to Ship:Mass * ship:sensors:GRAV:mag.

lock twr to totalCurrentThrust() / shipWeight.
lock maxTwr to totalMaxThrust() / shipWeight.
lock gforce to ship:sensors:acc:mag/ship:sensors:grav:mag.

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

lock orbitalSpeed to ship:velocity:ORBIT:mag.
lock surfaceSpeed to ship:velocity:SURFACE:mag.



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



/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !



function orbitSpeed
{
	parameter apo is 70000, peri is 70000, gm is 3.5e12, datum is 600000.

	local simimajor is datum + (apo+peri)/2.

	local r is datum + max(apo,peri).

	local v is sqrt(gm*((2/r)-(1/simimajor))).

	return v.
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



/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !



function ImproveManeuverNode
{
	parameter dim, stepsize.

	local startTime to time:seconds.

	// TODO: needs testing: was refactor from file method to local method
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

	// TODO: needs testing: was refactor from file method to local method
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


// setup configuration lexicon for binary closest approach
function binaryClosestApproachLex
{
	parameter timeEnd.
	parameter timeStart is time:seconds.
	parameter oribital1 is ship.
	parameter oribital2 is target.
	parameter stopConditionDistance is 1.
	parameter stopConditionTime is 1.
	parameter computeTime is time:seconds.

	return lex(
		"timeEnd",timeEnd,
		"timeStart",timeStart,
		"oribital1",oribital1,
		"oribital2", oribital2,
		"stopConditionDistance", stopConditionDistance,
		"stopConditionTime", stopConditionTime,
		"computeTime", computeTime
	).
}


// binary closest approach
// use binary search to find closest approach
function binaryClosestApproach
{
	parameter bcaLex.

	//print("timespan: "+formattime(bcaLex["timeEnd"]-bcaLex["timeStart"])).

	local ves1 is bcaLex["oribital1"].
	local ves2 is bcaLex["oribital2"].

	function calcDistance
	{
		parameter ti.
		//print(""+ti+" "+ves1:name+" " + ves2:name).

		local sub to positionat(ves1, ti) - positionat(ves2, ti).
		//print("calcDistance: "+RAP(sub:mag)).
		return sub:mag.
	}

	function updateLex
	{
		local t0 to 0+bcaLex["timeStart"].
		local t1 to (bcaLex["timeStart"]+bcaLex["timeEnd"])/2.
		local t2 to 0+bcaLex["timeEnd"].

		//print("T0: " + t0).
		//print("T2: " + t2).
		//print("TD: " + (t2-t1)).

		local d0 to calcDistance(t0).
		local d2 to calcDistance(t2).

		//print("d0: " + d0).
		//print("d2: " + d2).
		//print("dd: " + (d2-d0)).

		if d0<d2
		{
			set bcaLex["timeEnd"] to t1.
		}
		else if d0>d2
		{
			set bcaLex["timeStart"] to t1.
		}
		else
		{
			print("GG?").
			wait 0.
		}
	}

	for I IN RANGE(50)
	{
		updateLex().
		local deltaTime is bcaLex["timeEnd"]-bcaLex["timeStart"].
		if deltaTime < bcaLex["stopConditionTime"]
		{
			//print(" ").
			//print("i"+i).
			local t1 to (bcaLex["timeStart"]+bcaLex["timeEnd"])/2.
			local d1 to calcDistance(t1).
			//print("t1: " + formatTime(t1-time:seconds)).
			//print("computeTime: "+ RAP(time:seconds - bcaLex["computeTime"],3)).
			//print("ca: " + RAP(calcDistance(t1)/1000,2)).
			return lex(
				"iterations",i,
				"minTime",t1,
				"minDist",d1,
				"computeTime", (time:seconds-bcaLex["computeTime"])
			).
		}
	}
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



/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

