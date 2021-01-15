@LAZYGLOBAL off.

runoncepath("library").

librarysetup().

beep().

print "approach.ks" at(45,0).
print ship at(45,1).

global whenLoop to time:seconds.

global exitScript to false.


// target draw
lock targVec to (target:position - ship:position).
global targDraw to VECDRAWARGS(ship:position, target:position - ship:position, RGB(1,0,0), "", 1, true).
set targDraw:startupdater to { return ship:position. }.
set targDraw:vecupdater to { return targVec. }.

//global targDrawNormalized to VECDRAWARGS(ship:position, target:position - ship:position, RGB(1,0,0), "", 1, true).
//set targDrawNormalized:startupdater to { return ship:position. }.
//set targDrawNormalized:vecupdater to { return targVec:normalized*20. }.

// relative draw
lock relaVec to (ship:velocity:orbit  - target:velocity:orbit )*1.
global relaDraw to VECDRAWARGS(ship:position, ship:position, RGB(0,0,1), "", 1, true).
set relaDraw:startupdater to { return ship:position. }.
set relaDraw:vecupdater to { return relaVec. }.

global relaDrawNormalized to VECDRAWARGS(ship:position, ship:position, RGB(0,0,1), "", 1, true).
set relaDrawNormalized:startupdater to { return ship:position. }.
set relaDrawNormalized:vecupdater to { return relaVec:normalized*20. }.


lock goVec to targVec-relaVec.
global goDraw to VECDRAWARGS(ship:position, ship:position, RGB(1,1,0), "", 1, true).
set goDraw:startupdater to { return ship:position . }.
set goDraw:vecupdater to { return goVec. }.

global goDrawNormalized to VECDRAWARGS(ship:position, ship:position, RGB(1,1,0), "", 1, true).
set goDrawNormalized:startupdater to { return ship:position . }.
set goDrawNormalized:vecupdater to { return goVec:normalized*20. }.

lock steer to goVec.
//lock steering to steer.

global throt to 0.
//lock throttle to throt.

lock max_acc to max(0.0000001,ship:maxthrust/max(0.0000001,ship:mass)).

global prevTargDist is target:distance.

sas off.

when true then
{
	print "TIME : " + TIME:SECONDS at(45,3).
	print time:seconds - whenLoop at (45,4).
	set whenLoop to time:seconds.
	
	print target at (45,6).
	
	local ca to closestapproach(ship,target).
	
	print "cur dist       : " + target:distance at (45,8).
	print "cur dist delta : " + (target:distance-prevTargDist) at (45,9).
	set prevTargDist to target:distance.
	
	print "eta      : " + (ca["minTime"] - time:seconds) at (45,12).
	print "eta orbs : " + ((ca["minTime"] - time:seconds)/ship:orbit:period) at (45,13).
	
	print "minDist  : " + ca["minDist"] at (45,15).
	
	local shipVel is VELOCITYAT(ship,ca["minTime"]):orbit.
	local targVel is VELOCITYAT(target,ca["minTime"]):orbit.
	
	local relaVel is (shipVel-targVel):mag.
	
	print "relative velocity : " + relaVel + " m/s       " at (45,17).
	
	local burn_duration to relaVel / max(0.1,max_acc).
	
	print "burn duration     : " + burn_duration + " s       " at (45,18).
	
	local burn_start is (1.2*(ca["minTime"] - time:seconds)) - (1.2*burn_duration) - 1.
	
	print "burn start        : " + burn_start + " s       " at (45,20).
	
	if burn_start<0
	{
		stopwarp().
	}
	
	if target:distance<100 and panels
	{
		panels off.
	}
	
	if sas
	{
		unlock steering.
	}
	else
	{
		// 0 is retrograde
		// 1 is steering
		local si_distance to slopeintercept(50,0,150,1).
		local si_relaVel to slopeintercept(0,1,3,0).
		
		local factor to slopeInterceptValue(si_distance,target:distance,true) * slopeInterceptValue(si_relaVel,relaVel,true).
		
		print "factor              : " + factor + "        " at (45,22).
		
		local retroTarg is -1*relaVec.
		
		lock steering to factor*steer + (1-factor)*retroTarg.
		
		//if target:distance > 20 and relaVel < 10
		//{
		//	lock steering to steer.
		//}
		//else
		//{
		//	lock steering to -1*relaVec.
		//}
	}
	
	

	wait 0.
	PRESERVE.
}

when target:distance<3000 then
{
	print "stopwarp " + target:distance.
	stopwarp().
}

when target:distance<2000 then
{
	print "stopwarp " + target:distance.
	stopwarp().
}

when target:distance<1000 then
{
	print "stopwarp " + target:distance.
	stopwarp().
}

when target:distance<500 then
{
	print "stopwarp " + target:distance.
	stopwarp().
}

wait until exitScript.

print "end of file".