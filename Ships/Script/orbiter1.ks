@LAZYGLOBAL off.

runoncepath("library").

librarysetup().

beep().

print "orbiter1.ks".

local check is time:seconds.
UNTIL (TIME:SECONDS>check+1)
{
	local shipspeed is SHIP:VELOCITY:surface:MAG.
	if shipspeed>0.009
	{
		set check to time:seconds.
	}
	
	print (TIME:SECONDS) at(45,0).
	print (TIME:SECONDS-check) at(45,1).
	print (shipspeed) at(45,2).
	//print vec_left() at(45,3).
	print ang_ascentslope() at(45,4).
}

print "starting...".

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.


local mysteer to 90.

function steeringHelper
{
	

	return HEADING(90, max(mysteer,0) ).
}

LOCK STEERING TO steeringHelper.

local mythrottle to 1.0.
lock throttle to mythrottle.

print "launching...".
stage.

local si to slopeintercept(500,90,42000,0).
print si.

when SHIP:ALTITUDE > 70000 then
{
	beep(840,0.25,0.001).

	print "space!".
	
	panels on.
	
	setantenna(true).
	
	RCS off.
}

local beeplimiter is time:seconds.

local lastMaxThrust is maxthrust.

local thrustPID TO PIDLOOP(1/5, 0, 1/1000, 0, 1).
set thrustPID:SETPOINT to 25.

when ship:ALTITUDE > 500 then
{
	//RCS ON.
	print "RCS : " + RCS + "   " at (0,36).
}

when true then
{
	local tpid to 1.
	
	if SHIP:ALTITUDE > 40000
	{
		set tpid to thrustPID:update(time:second,eta_apoapsis()).
		print tpid at(45,5).
	}
	
	local liquidfuel is GetStageLowestResource("liquidfuel").
	local oxidizer is GetStageLowestResource("oxidizer").

	if SHIP:ALTITUDE < 500
	{
	}
	else if maxthrust = 0 or maxthrust < (lastMaxThrust * 0.9) or liquidfuel<=0.01 or oxidizer<=0.01
	{
		beep(440,0.05,0.001).

		set mysteer to ang_ascentslope().
		print "staging booster...".
		//wait 0.
		stage.
		//wait 0.
		set si to slopeintercept(ship:ALTITUDE,mysteer,42000,0).
		print si.
		print "staged booster".
		//wait 0.
		set lastMaxThrust to maxthrust.
	}
	else if ship:APOAPSIS > 70000+5000 and ship:ALTITUDE+ship:APOAPSIS > 70000+40000+6000
	{
		set mysteer to 0.
		
		print "going to space" at(45,32).
		
		// TODO: Improve this, PID controller?
		if eta_apoapsis() < 10
		{
			set mythrottle to 1.
		}
		else
		{
			set mythrottle to tpid.
		}
	}
	else if SHIP:ALTITUDE < 45000
	{
		set mysteer to si["slope"] * ship:ALTITUDE + si["intercept"].
		if mysteer < 0 { set mysteer to 0. }
	}
	else if SHIP:ALTITUDE > 45000 and ship:APOAPSIS < 70000+1000
	{
		set mythrottle to 1.
		set mysteer to 0.
	}
	else
	{
		set mythrottle to 1.
		set mysteer to 0.

		if time:seconds - beeplimiter > 10
		{
			print "need instructions!" at(45,31).
			beep(2000,0.1,0.00000001).
			set beeplimiter to time:seconds.
		}
	}
	
	print "maxthrust  : " + maxthrust at(45,10).
	print "lastThrust : " + lastMaxThrust at(45,11).
	
	print "mysteer    : " + mysteer at(45,14).
	
	print "asc-slope  : " + (ang_ascentslope()) at(45,15).
	print "abs-aoa    : " + ang_absaoa() at(45,16).
	
	print "facing     : " + ship:facing at(45,18).
	
	print "apo-time   : " + eta_apoapsis()  at(45,20).
	
	print "TIME       : " + TIME:SECONDS at(45,22).
	print "parts      : " + ship:parts:length at(45,23).
	
	print liquidfuel + " " + oxidizer at (45,25).

	wait 0.
	PRESERVE.
}

wait until ship:PERIAPSIS > 70000.

print "Orbit!".

// Play a 'song':
voice0:PLAY(LIST(
	NOTE("A#4", 0.2,  0.25, 0.1),
	NOTE("A4",  0.2,  0.25, 0.1),
	SLIDENOTE("C5", "F5", 0.45, 0.5, 0.1)
)).


stopwarp().

lock throttle to 0.
LOCK STEERING TO HEADING(90,90).

print "end of file".