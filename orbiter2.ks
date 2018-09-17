@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runoncepath("library").

librarysetup().

beep().

print "orbiter2.ks" at(45,0).
print ship at(45,1).



lock ship_facing to vec_fore().
lock ship_prograde to prograde:vector.
lock ship_surface to srfprograde:vector.
lock ship_bottom to vec_bottom().

lock bottom_planeVec to planierize(ship:up:vector,vec_bottom()).

// ship vector, from center of kerbin
lock shipVec to ship:position - body:position.

// blue: ship position
global shipDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0,0,1), "", 1.0, true).
set shipDraw:startupdater to { return body:position. }.
set shipDraw:vecupdater to { return 2*shipVec. }.

// green: north pole, north
global northDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0,1,0.5), "", 1, true).
set northDraw:startupdater to { return body:position. }.
set northDraw:vecupdater to { return V(0,2*600000,0). }.


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

stopWarp().

LOCK STEERING TO Up + R(0,0,-90).
lock throttle to 1.

print "script time : " + (time:seconds - scriptEpoch).

waitUntilSteady(6).

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
global stageProtector to time:seconds+30.
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

global steeringDelegate to Up + R(0,0,-90).
lock steering to steeringDelegate.

print "To Infinity!".

global si_steering_alt to slopeintercept(ship:altitude,90,40100,0).
global si_steering_apo to slopeintercept(60000,1,76000,0).

global desiredVec to ship:up:vector.

when true then
{
	local a to slopeInterceptValue(si_steering_alt,ship:altitude,true).
	local b to slopeInterceptValue(si_steering_apo,ship:apoapsis,true).
	
	print "desired angle       : " + (a*b) + "       " at (45,18).
	
	//set desiredVec to BetweenVector(apoSatHorizonVec,ship:up:vector,(a*b)).
	set desiredVec to Up + R( 0,(a*b)-90 ,-90).

	set steeringDelegate to desiredVec.
	
	wait 0.
	PRESERVE.
}.

// dark orange: desired vector
global desiredVecDraw to VECDRAWARGS(V(0,0,0), V(0,0,0), RGB(0.5,0.2,0.0), "", 1.0, true).
set desiredVecDraw:startupdater to { return ship:position. }.
set desiredVecDraw:vecupdater to { return desiredVec:vector:normalized*50. }.

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
