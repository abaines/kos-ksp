@LAZYGLOBAL off.

runoncepath("library").

librarysetup().

beep().

print "measure.ks" at(45,0).
print ship at(45,1).

local whenLoop to time:seconds.

global shipDraw to VECDRAWARGS(body:position, ship:position - body:position, RGB(0,0,1), "", 1.1, true).
set shipDraw:startupdater to { return body:position. }.
set shipDraw:vecupdater to { return ship:position - body:position. }.


global exitScript to false.

wait 0.

if 0
{
	print Career():CANDOACTIONS.

	local p is lex().

	for part in ship:parts
	{
		local name is part:name.
		
		if not p:haskey(name)
		{
			p:add(name,list()).
		}
		p[name]:add(part).
	}

	for k in p:keys
	{
		local v is p[k].
		print k + " " + v:length.
	}
	
	local mediumdishantenna is p["mediumdishantenna"][0].
	print mediumdishantenna:name.
	
	//print mediumdishantenna:MODULES.
	
	//local us TO UNIQUESET().
	//
	//for mn in mediumdishantenna:MODULES
	//{
	//	local m is mediumdishantenna:GETMODULE(mn).
	//	
	//	for x in modHelper(m)
	//	{
	//		us:add(x).
	//	}
	//}
	
	print " ".
	
	for mn in mediumdishantenna:MODULES
	{
		local m is mediumdishantenna:GETMODULE(mn).
		
		local ml is modHelper(m).
		
		if ml:length>0
		{
			print mn.
			print modHelper(m).
			print " ".
		}
	}
	
	local moduledeployableantenna is mediumdishantenna:GETMODULE("moduledeployableantenna").
	
	print moduledeployableantenna.
	
	print " ".
	
	print moduledeployableantenna:ALLEVENTS.
	
	print moduledeployableantenna:ALLEVENTNAMES.
	
	if moduledeployableantenna:HASEVENT("extend antenna")
	{
		//moduledeployableantenna:DOEVENT("extend antenna").
	}
	else if moduledeployableantenna:HASEVENT("retract antenna")
	{
		//moduledeployableantenna:DOEVENT("retract antenna").
	}
	
	//print us.
	
	setantenna(true).
}

sas off.


when 1 then
{
	print GetShipResourcePercent("electriccharge") at (45,27).
	
	if GetShipResourcePercent("electriccharge") < 0.3333
	{
		FUELCELLS ON.
	}
	else
	{
		FUELCELLS OFF.
	}
	
	print FUELCELLS at (45,28).

	wait 0.
	PRESERVE.
}

global lastMinDist is 0.

//lock shipNormal to vcrs(ship:obt:velocity:orbit,ship:position - body:position).
//lock steering to shipNormal.

when true then
{
	print "TIME : " + TIME:SECONDS at(45,3).
	print time:seconds - whenLoop at (45,4).
	set whenLoop to time:seconds.
	
	
	
	print ship:orbit:LAN at (45,6).
	print 67.4 at (45,7).
	
	print ship:orbit:inclination at (45,9).
	print 63.4 at (45,10).
	
	
	
	
	if hastarget
	{
		print "-=closestapproach details=-" at (45,10).
		print "orbit ratio : " + (target:orbit:period / ship:orbit:period) at (45,11).
	
		local multiOrbitTime is time:seconds + 5*max(ship:orbit:period, target:orbit:period).
		local ca to closestapproach(ship,target,time:seconds,multiOrbitTime,5*9).
		
		print "cur dist      : " + target:distance at (45,12).
		print "eta           : " + (ca["minTime"] - time:seconds) at (45,13).
		print "eta orbs      : " + ((ca["minTime"] - time:seconds)/ship:orbit:period) at (45,14).
		print "minDist       : " + ca["minDist"] at (45,15).
		print "minDist delta : " + (lastMinDist-ca["minDist"]) at (45,16).
		
		print "target orbit        : " + target:orbit:period at (45,18).
		print "ship orbit          : " + ship:orbit:period at (45,19).
		
		set lastMinDist to ca["minDist"].
	}
	
	
	// OLD CODE // OLD CODE // OLD CODE // OLD CODE // OLD CODE // OLD CODE // OLD CODE // OLD CODE
	
	
	// OLD CODE // OLD CODE // OLD CODE // OLD CODE // OLD CODE // OLD CODE // OLD CODE // OLD CODE
	
	
	if 0
	{
		print vessel("hmd night-spark 1"):orbit:period at (45,20).
		print vessel("hmd night-spark 2"):orbit:period at (45,21).
		print vessel("hmd night-spark 2"):orbit:period at (45,22).
	}
	
	if 0
	{
		lock ns1 to vessel("hmd night-spark 1"):orbit:period.
		lock ns2 to vessel("hmd night-spark 2"):orbit:period.
		lock ns3 to vessel("hmd night-spark 3"):orbit:period.

		print ns1.
		print ns2.
		print ns3.

		lock over to ship:orbit:period-1944000.001.

		until ship:orbit:period <= 1944000.0014
		{
		lock throttle to over*0.0001.
		wait 0.
		}
		lock throttle to 0.00000.

		wait 1.

		print ns1.
		print ns2.
		print ns3.
	}
	
	if 0
	{
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
	}
	
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

print "end of file".