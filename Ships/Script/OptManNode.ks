@LAZYGLOBAL off.

runoncepath("library").

librarysetup().

beep().

print "OptManNode.ks" at(0,0).
print ship at(0,1).
print target at(0,2).

local prevCA to lex().

global exitScript to false.

sas off.

local whenLoop to time:seconds.


when true then
{
	print "TIME : " + TIME:SECONDS at(45,0).
	print time:seconds - whenLoop at (45,1).
	set whenLoop to time:seconds.
	
	print eta_apoapsis() at(0,5).
	
	print "targ:distance  : " + target:distance at (0,10).
	print "                  " + (positionat(ship, time:seconds) - positionat(target, time:seconds)):mag at (0,11).
	
	//print "TIME : " + time:seconds at (0,23).
	//print "time + max orbit : " + time:seconds + max(ship:orbit:period, target:orbit:period) at (0,24).
	print "max orbit      : " + max(ship:orbit:period, target:orbit:period) at (0,13).
	print "orbit ratio    : " + (target:orbit:period / ship:orbit:period) at (0,14).
	
	
	local multiOrbitTime is time:seconds + 5*max(ship:orbit:period, target:orbit:period).
	local CA to closestapproach(ship,target,time:seconds,multiOrbitTime,5*11).
	
	print "computeTime    : " + CA["computeTime"] at (45,9).
	print "timeStep       : " + CA["timeStep"] at (45,10).
	
	print "minTime        : " + (CA["minTime"] - time:seconds) at (45,12).
	print "minTime orb    : " + ((CA["minTime"] - time:seconds)/ship:orbit:period) at (45,13).
	
	print "minDist        : " + CA["minDist"] at (45,15).
	
	
	if prevCA:length>0
	{
		print "delta dist     : " + (prevCA["minDist"]-CA["minDist"]) + "           " at (45,17).
		print "delta dist %   : " + (100*(prevCA["minDist"]-CA["minDist"])/CA["minDist"]) + "           " at (45,18).
	}
	
	
	set prevCA to CA.
	
	if ALLNODES:LENGTH>0
	{
		print NEXTNODE + "       " at (0,20).
		print "deltav       : " + NEXTNODE:DELTAV:mag at (0,21).
		
		local multiplier to 1.0000.
		
		if CA["minDist"]>15000
		{
			set multiplier to 5.0000.
		}
		else if CA["minDist"]>1500
		{
			set multiplier to 2.0000.
		}
		else if CA["minDist"]>400
		{
			set multiplier to 0.5000.
		}
		else if CA["minDist"]>100
		{
			set multiplier to 0.1000.
		}
		else if CA["minDist"]>40
		{
			set multiplier to 0.0333.
		}
		else
		{
			set multiplier to 0.0040.
		}
		
		print "multiplier     : " + multiplier at (0,26).
		
		set multiplier to multiplier*max(1,NEXTNODE:DELTAV:mag)/10.
		
		print "multiplier     : " + multiplier at (0,27).
		
		if CA["minDist"] >= 10
		{
			ImproveManeuverNode("pro",multiplier*0.3).
			ImproveManeuverNode("rad",multiplier*0.2).
			ImproveManeuverNode("nor",multiplier*0.1).
		}
		
		print "ETA            : " + NEXTNODE:ETA at (45,27).
		
		if NEXTNODE:ETA < 60*4 and WARP>1
		{
			stopwarp().
		}
		
		if NEXTNODE:ETA < 60*3 and WARP>1
		{
			stopwarp().
		}
		
		if NEXTNODE:ETA < 60*2
		{
			// TODO: stuff
			stopwarp().
			lock throttle to 0.
			print "done           : " + NEXTNODE:ETA at (0,30).
			set exitScript to true.
			return.
		}
		
		lock steering to NEXTNODE:deltav.
	}
	else
	{
		print ALLNODES:LENGTH at (0,26).
	}
	
	wait 0.
	PRESERVE.
}

wait until exitScript.

run node.

print "end of file".