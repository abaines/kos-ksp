@LAZYGLOBAL off.

runoncepath("library").

librarysetup().

print "lander.ks" at(45,0).

wait 0.

sas off.

lock electricchargepercent to GetShipResourcePercent("electriccharge").

when 1 then
{
	print electricchargepercent at (45,27).
	
	if electricchargepercent < 0.3333
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

// target draw
global geo_ksc to LATLNG(0,-74).
lock ksc_vec to (geo_ksc:POSITION - ship:position).
global targDraw to VECDRAWARGS(ship:position, ship:position, RGB(1,0,0), "", 1, true).
set targDraw:startupdater to { return ship:position. }.
set targDraw:vecupdater to { return ksc_vec. }.

lock steering to "kill".

if ship:PERIAPSIS > 40000
{
	lock steering to -1*ship:prograde:vector.
}

until vang(ship:facing:vector,-1*ship:prograde:vector) < 5 or ship:PERIAPSIS < 40000
{
	print vang(ship:facing:vector,-1*ship:prograde:vector) at (45,9).
	wait 0.
}


global prevKscDist is 2147483646.

until (geo_ksc:distance - prevKscDist < 0 
		and prevKscDist < 2147483646 
		and geo_ksc:distance<1400000
		and geo_ksc:distance>600000)
		or ship:PERIAPSIS < 40000
{
	print geo_ksc:distance at (45,10).
	print geo_ksc:distance - prevKscDist at (45,11).
	
	set prevKscDist to geo_ksc:distance.
	wait 0.
}

stopwarp().

wait 1.

until vang(ship:facing:vector,-1*ship:prograde:vector) < 5 or ship:PERIAPSIS < 40000
{
	print vang(ship:facing:vector,-1*ship:prograde:vector) at(45,13).
	wait 0.
}

wait 1.

lock throttle to 1.

until ship:PERIAPSIS < 40000
{
	print ship:PERIAPSIS at (45,15).
	wait 0.
}

// path good
lock throttle to 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
unlock throttle.


global landMode is 0.

if landMode = 0
{
	// retrograde
	lock steering to -1*ship:srfprograde:vector.
}
if landMode = 1
{
	// forward horizon
	lock steering to vcrs(vcrs(ship:up:vector,ship:srfprograde:vector),ship:up:vector).
}
if landMode = 2
{
	// backward horizon
	lock steering to vcrs(vcrs(ship:up:vector,-1*ship:srfprograde:vector),ship:up:vector).
}

print landMode.


when ship:ALTITUDE < 70000 then
{
	stopwarp().
	RCS ON.
	panels off.
}

when ship:ALTITUDE < 2000 then
{
	lock steering to up.
}

global prevSpeed is 0.

global happy is 0.
until happy>1000
{
	if ship:velocity:surface:mag < 1
	{
		set happy to 1 + happy.
		print happy at (45,20).
	}
	else
	{
		set happy to 0.
		print "speed   : " + ship:velocity:surface:mag at (45,21).
		print "alt     : " + ship:ALTITUDE  at (45,22).
	}
	
	print "d-speed : " + (ship:velocity:surface:mag-prevSpeed) at (45,24).
	set prevSpeed to ship:velocity:surface:mag.
	
	wait 0.
}
