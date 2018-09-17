@LAZYGLOBAL off.

runoncepath("library").

librarysetup().

beep().

print "waiter.ks" at(0,0).
print ship at(0,1).

local whenLoop to time:seconds.

global future to 200.

until HASTARGET
{
	print " ! Need Target   " at (45,10).
	wait 0.
	print "   Need Target ! " at (45,10).
	wait 0.
}

print    "                 " at (45,10).

print target at(0,3).
print future at(45,3).

global shipDraw to VECDRAWARGS(body:position, ship:position - body:position, RGB(0,0,1), "", 1.1, true).
global targDraw to VECDRAWARGS(body:position, target:position - body:position, RGB(0,1,0), "", 1, true).
global futrDraw to VECDRAWARGS(body:position, target:position - body:position, RGB(1,0,0), "", 1, true).

set shipDraw:startupdater to { return body:position. }.
set targDraw:startupdater to { return body:position. }.
set futrDraw:startupdater to { return body:position. }.

set shipDraw:vecupdater to { return ship:position - body:position. }.
set targDraw:vecupdater to { return target:position - body:position. }.
set futrDraw:vecupdater to { return positionat(target,time:seconds + future) - body:position. }.

global prevFutureAng to 360.
global prevFutureAngDelta to 360.

global exitScript to false.

wait 0.

when true then
{
	print "TIME : " + TIME:SECONDS at(45,0).
	print time:seconds - whenLoop at (45,1).
	set whenLoop to time:seconds.
	
	print vang(ship:position - body:position, target:position - body:position ) at (0,10).
	
	local futureAng is vang(ship:position - body:position, positionat(target,time:seconds + future) - body:position ).
	
	
	print futureAng at (0,15).
	print prevFutureAng at (0,16).
	
	local futureAngDelta is futureAng-prevFutureAng.
	
	print " FAD " + futureAngDelta at (0,18).
	print "pFAD " + prevFutureAngDelta at (0,19).
	
	print futureAngDelta*prevFutureAngDelta at (0,25).
	
	if futureAngDelta>=0 and prevFutureAngDelta<=0
	   and abs(futureAngDelta)<90 and abs(prevFutureAngDelta)<90
	{
		print "GO! " + time:seconds + "                " at (0,30).
		set exitScript to true.
		return.
	}
	
	set prevFutureAng to futureAng.
	set prevFutureAngDelta to futureAngDelta.
	
	if 0
	{
		//CLEARVECDRAWS().
		local ean to EtaAscendingNode().
		print "farTime     : " + (ean["farTime"] - time:seconds) at (0,20).
		print "nearTime    : " + (ean["nearTime"] - time:seconds) at (0,21).
		print "eta         : " + ean["eta"] at (0,22).
		print "errTime     : " + ean["errTime"] at (0,24).
		print "computeTime : " + ean["computeTime"] at (0,25).
	}

	if 0
	{
		print ang_absaoa() at (0,4).
		print ang_aoa() at (0,5).
		
		print vec_fore() at (0,7).
		print srfprograde:vector at (0,8).
		print ship:facing:vector at (0,9).
		
		print vec_fore():typeName() at (0,11).
		
		print vang(vec_up(),vec_fore()) at(0,13).
		print vang(vec_up(),srfprograde:vector) at(0,14).
		
		print eta_apoapsis() at(0,16).
		
		print positionat(ship,time:seconds) at (0,18).
		print positionat(target,time:seconds) at (0,19).
		
		print (positionat(ship, time:seconds) - positionat(target, time:seconds)):mag at (0,21).
		
		print "TIME : " + time:seconds at (0,23).
		print "time + max orbit : " + time:seconds + max(ship:orbit:period, target:orbit:period) at (0,24).
		print "max orbit : " + max(ship:orbit:period, target:orbit:period) at (0,25).
		print "orbit ratio : " + (target:orbit:period / ship:orbit:period) at (0,26).
		
		print "target:distance : " + target:distance at (0,28).
		
		local CA to closestapproach(ship,target).
		
		print "timeStep    : " + CA["timeStep"] at (0,30).
		print "minTime     : " + CA["minTime"] at (0,31).
		print "minDist     : " + CA["minDist"] at (0,32).
		print "computeTime : " + CA["computeTime"] at (0,33).
		
		if prevCA:length>0
		{
			print "timeStep   : " + prevCA["timeStep"] at (0,35).
			print "minTime    : " + prevCA["minTime"] at (0,36).
			print "minDist    : " + prevCA["minDist"] at (0,37).
			
			print "delta dist : " + (prevCA["minDist"]-CA["minDist"]) + "          ~" at (0,40).
		}
		
		
		set prevCA to CA.
	}

	wait 0.
	PRESERVE.
}

wait until exitScript.

run orbiter2.

print "end of file".