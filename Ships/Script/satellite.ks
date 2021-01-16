@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runoncepath("library").

librarysetup().

beep().

print orbitSpeed().
print orbitSpeed(75000,-450000).

// CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA //
// CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA //


global sat_apo is 5623168. // apoapsis (meters)
global sat_peri is 103500. // periapsis (meters)
global sat_inclin is 63.4. // inclination (degrees)

global sat_LOAN is 67.4. // longitude of ascending node (degrees)
global sat_ArgOfPeri is 270. // argument of periapsis (degrees)

global launchWindow is 238. // seconds to launch before getting to ascending Node.


// CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA //
// CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA // CUSTOM SAT DATA //


print "satellite.ks" at(45,0).
print ship at(45,1).

// length between center of kerbin to width of satellite path
global ascNodeSize is sqrt((600000+sat_apo)*(600000+sat_peri)).

global magicVessel to vessel("ssp radiant light").

// LONGITUDE OF ASCENDING NODE
lock LAN to magicVessel:orbit:LAN.

// ship vector, from center of kerbin
lock shipVec to magicVessel:position - body:position.

// north <cross> ship position
lock crossVec to VCRS( shipVec , V(0,1,0) ).

// center of kerbin to satellite ascending node
lock ascNodeSatVec to BetweenVector(crossVec,shipVec,LAN-sat_LOAN).

// center of kerbin to below (on horizon) satellite apoapsis
lock hrzApoVec to VCRS(ascNodeSatVec,V(0,1,0)).

// center of kerbin to satellite apoapsis
lock apoSatVec to BetweenVector(hrzApoVec,V(0,1,0),sat_inclin).

// slope of satellite apoapsis on plane of ship horizon
lock apoSatMagicHorizonVec to planierize(magicVessel:up:vector,apoSatVec).
lock apoSatHorizonVec to planierize(ship:up:vector,apoSatMagicHorizonVec).

lock ship_facing to vec_fore().
lock ship_prograde to prograde:vector.
lock ship_surface to srfprograde:vector.
lock ship_bottom to vec_bottom().

lock bottom_planeVec to planierize(ship:up:vector,vec_bottom()).

// blue: ship position
global shipDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0,0,1), "", 1.0, true).
set shipDraw:startupdater to { return body:position. }.
set shipDraw:vecupdater to { return 2*shipVec. }.

// green: north pole, north
global northDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0,1,0.5), "", 1, true).
set northDraw:startupdater to { return body:position. }.
set northDraw:vecupdater to { return V(0,2*600000,0). }.

// light blue: north <cross> ship position
global crossDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.5,0.5,1), "", 1, true).
set crossDraw:startupdater to { return body:position. }.
set crossDraw:vecupdater to { return crossVec:normalized*(600000)*2. }.

// pink: angle between ahead of ship position by ship lan - sat lan
global ascNodeSatDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(1,0.5,0.5), "", 1, true).
set ascNodeSatDraw:startupdater to { return body:position. }.
set ascNodeSatDraw:vecupdater to { return ascNodeSatVec:normalized*ascNodeSize. }.

// yellow: vector below (on horizon) sat apo
global hrzApoDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(1,1,0.1), "", 1, true).
set hrzApoDraw:startupdater to { return body:position. }.
set hrzApoDraw:vecupdater to { return hrzApoVec:normalized*sat_apo*cos(sat_inclin). }.

// teal: vector to sat apo
global satApoDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.1,1,1), "", 1, true).
set satApoDraw:startupdater to { return body:position. }.
set satApoDraw:vecupdater to { return apoSatVec:normalized*(sat_apo+600000). }.

// teal: ship vector to satellite apoapsis on ship horizon
global satApoShipHorizonDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.1,1,1), "", 1, true).
set satApoShipHorizonDraw:startupdater to { return ship:position. }.
set satApoShipHorizonDraw:vecupdater to { return apoSatHorizonVec:normalized*600000. }.

// orange: ship facing
global facingDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.75,0.5,0.0), "", 1, true).
set facingDraw:startupdater to { return ship:position. }.
set facingDraw:vecupdater to { return ship_facing:normalized*50. }.

// blue: ship orbit prograde
global progradeDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.0,1.0,0.0), "", 1, true).
set progradeDraw:startupdater to { return ship:position. }.
set progradeDraw:vecupdater to { return ship_prograde:normalized*50. }.

// purple: ship surface prograde
global surfaceProgDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.0,1.0,0.3), "", 1, true).
set surfaceProgDraw:startupdater to { return ship:position. }.
set surfaceProgDraw:vecupdater to { return ship_surface:normalized*50. }.

// grey: ship bottom
global shipBottomDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.3,0.3,0.3), "", 1, true).
set shipBottomDraw:startupdater to { return ship:position. }.
set shipBottomDraw:vecupdater to { return ship_bottom:normalized*50. }.

// white: bottom_planeVec
global vec_forehorDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.9,0.9,0.9), "", 1.0, true).
set vec_forehorDraw:startupdater to { return ship:position. }.
set vec_forehorDraw:vecupdater to { return bottom_planeVec:normalized*45. }.

when true then
{
	set progradeDraw:show to ship:altitude > 40000.
	set surfaceProgDraw:show to ship:altitude < 70000.
	wait 0.
	PRESERVE.
}

rcs off.
sas off.

managePanelsAndAntenna().

manageFuelCells().


global whenLoop to time:seconds.
when true then
{
	print "time                : " + TIME:SECONDS at(45,2).
	print "time delta          : " + (time:seconds - whenLoop) at (45,3).
	set whenLoop to time:seconds.
	
	wait 0.
	PRESERVE.
}


// calculate ETA AN // calculate ETA AN // calculate ETA AN // calculate ETA AN //
lock ascNodeAngle to LAN-sat_LOAN-90.
global prevAscNodeAngle to ascNodeAngle.
global timeAscNodeAngle to time:seconds.
global etaAN to 2147483646.

when true then
{
	print "ascNodeAngle        : " + ascNodeAngle    at (45,10).
	
	local dAngle is ascNodeAngle-prevAscNodeAngle.
	local dTime is time:seconds-timeAscNodeAngle.

	print "(dAngle/dTime)      : " + (dAngle/dTime) at (45,11).

	set prevAscNodeAngle to ascNodeAngle.
	set timeAscNodeAngle to time:seconds.
	
	if dTime = 0 or dAngle = 0
	{
		print "Stop Updating ETA AN due to zero".
		return false.
	}
	
	set etaAN to -1*ascNodeAngle/(dAngle/dTime).
	print "eta AN              : " + etaAN at (45,12).
	print "eta launch          : " + (etaAN-launchWindow) at (45,13).
	
	wait 0.
	if etaAN > -15
	{
		PRESERVE.
	}
	else
	{
		print "Stop Updating ETA AN".
	}
}
// calculate ETA AN // calculate ETA AN // calculate ETA AN // calculate ETA AN //

stopWarp().

LOCK STEERING TO Up + R(0,0,-90).
lock throttle to 1.

print "script time : " + (time:seconds - scriptEpoch).

if 1 // TODO: wait for launch Window !
{

	for I IN RANGE(20)
	{
		print i at(45,39).
		wait 0.
	}
	print "    " at(45,39).

	print " ! ! ! Warping ! ! !".

	kuniverse:timewarp:warpto(time:seconds + etaAN - launchWindow - 20).

	wait until etaAN < launchWindow + 20.
	stopWarp().
	
	print " ! ! ! Warp Complete ! ! !".

	delayUntilSteady(5).

	wait until etaAN < launchWindow + 0.
	stopWarp().

}
else // TODO: wait for launch Window !
{
	delayUntilSteady(9).
}

wait 0.
print " ! ! ! Launching ! ! !".
print "oxidizer parts : " + stage:resourceslex["oxidizer"]:parts:length.
global launch_time to time:seconds.
stage.
wait 0.
print "script time : " + (time:seconds - scriptEpoch).


// Manage Staging // Manage Staging // Manage Staging // Manage Staging // Manage Staging //
lock liquidfuel to GetStageLowestResource("liquidfuel").
lock oxidizer to GetStageLowestResource("oxidizer").
global lastMaxThrust is maxthrust*0.9.
global stageProtector to 0.
when true then
{
	if time:seconds < stageProtector
	{
		// wait
	}
	else if maxthrust <= 0.0001 or maxthrust < lastMaxThrust or liquidfuel<=0.0001 or oxidizer<=0.0001
	{
		print "staging booster...".
		print "oxidizer parts : " + stage:resourceslex["oxidizer"]:parts:length.
		//for p in stage:resourceslex["oxidizer"]:parts
		//{
		//	print "part name : " + p:name.
		//}
		print "thrust : " + maxthrust + "   " + lastMaxThrust.
		print "fuel : " + liquidfuel + "   " + oxidizer.
		
		beep(440,0.05,0.001).
		stage.
		print "staged booster".
		set lastMaxThrust to maxthrust*0.9.
		steeringManager:resettodefault().
		set stageProtector to time:seconds + 3.
		wait 0.
	}
	else if maxthrust > lastMaxThrust
	{
		set lastMaxThrust to maxthrust*0.9.
	}

	print "max thrust          : " + maxthrust at (45,15).
	print "last Max Thrust     : " + lastMaxThrust at (45,16).
	
	wait 0.
	PRESERVE.
}
// Manage Staging // Manage Staging // Manage Staging // Manage Staging // Manage Staging //




// Manage Steering // Manage Steering // Manage Steering // Manage Steering // Manage Steering //
wait until ship:altitude>150.

print "Let's Roll!".

set steeringManager:rollTorqueFactor to 0.15.

global steeringDelegate to Up + R(0,0,-90-sat_inclin).
lock steering to steeringDelegate.

until vang(bottom_planeVec,apoSatHorizonVec)<=2
{
	print "satellite orbit ang : " +vang(bottom_planeVec,apoSatHorizonVec) at (45,20).
}
print "                                        "  at (45,20).

print "To Infinity!".

global si_steering_alt to slopeintercept(ship:altitude,90,40100,0).
global si_steering_apo to slopeintercept(60000,1,76000,0).

global desiredVec to ship:up:vector.

when true then
{
	local a to slopeInterceptValue(si_steering_alt,ship:altitude,true).
	local b to slopeInterceptValue(si_steering_apo,ship:apoapsis,true).
	
	print "desired angle       : " + (a*b) + "       " at (45,18).
	
	set desiredVec to BetweenVector(apoSatHorizonVec,ship:up:vector,(a*b)).

	set steeringDelegate to desiredVec.
	
	wait 0.
	PRESERVE.
}.

// dark orange: desired vector
global desiredVecDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.5,0.2,0.0), "", 1.0, true).
set desiredVecDraw:startupdater to { return ship:position. }.
set desiredVecDraw:vecupdater to { return desiredVec:normalized*50. }.

// Manage Steering // Manage Steering // Manage Steering // Manage Steering // Manage Steering //







// Manage Throttle // Manage Throttle // Manage Throttle // Manage Throttle // Manage Throttle //
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

global throttleDelegate to 1.
lock throttle to throttleDelegate.

global si_throttle_apo to slopeintercept(72000,1,76000,0).

when true then
{
	local throttleDelegateAir to slopeInterceptValue(si_throttle_apo,ship:apoapsis,true).
	
	print "throttle (air)      : " + throttleDelegateAir at (45,21).
	
	local osap is orbitSpeed(ship:apoapsis,ship:periapsis).
	local osa7 is orbitSpeed(ship:apoapsis,75000).
	
	print "orbitSpeed          : " + osap at (45,23).
	print "orbitSpeed          : " + osa7 at (45,24).
	
	local osadiff is osa7-osap.
	print "orbitSpeed diff     : " + osadiff at (45,25).
	
	local apo_burn is osadiff / maxAcceleration().
	print "max Acceleration    : " + maxAcceleration() at (45,26).
	print "apo_burn            : " + apo_burn at (45,27).
	
	// ETA:APOAPSIS
	local etaApo is eta_apoapsis().
	print "eta apoapsis    : " + etaApo + "       " at (45,29).
	
	local si_throttle_space to slopeintercept((apo_burn*0.6)+2,0,apo_burn*0.5,1).
	local space_throttle to slopeInterceptValue(si_throttle_space,etaApo,true).
	
	local si_throttle_peri to slopeintercept(70000,1,76000,0).
	local throttle_peri to slopeInterceptValue(si_throttle_peri,ship:periapsis,true).
	
	print "throttle (peri)    : " + throttle_peri + "       " at (45,30).
	print "throttle (space)    : " + space_throttle + "       " at (45,33).
	
	set space_throttle to space_throttle * throttle_peri.
	
	print "throttle (space)    : " + space_throttle + "       " at (45,34).
	
	if ship:PERIAPSIS >= 75000
	{
		set throttleDelegate to 0.
	}
	else if ship:altitude<=70000
	{
		set throttleDelegate to throttleDelegateAir.
	}
	else
	{
		set throttleDelegate to space_throttle.
	}
	
	wait 0.
	PRESERVE.
}.
// Manage Throttle // Manage Throttle // Manage Throttle // Manage Throttle // Manage Throttle //



wait until ship:PERIAPSIS >= 75000.


lock throttle to 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

wait 0.

print "launch time : " + (time:seconds - launch_time).

wait 1.
CLEARVECDRAWS().

print "end of file".
