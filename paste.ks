@LAZYGLOBAL off.

runoncepath("library").

librarysetup().

print "paste.ks" at(0,0).

wait 0.

sas off.

rcs off.

abort off.

// retrograde
lock steering to -1*ship:srfprograde:vector.

global prevAlt is ship:ALTITUDE.

when ship:ALTITUDE <= 10000 then
{
	lock steering to up.
}

when 1 then
{

	if ship:ALTITUDE <= 70000 and prevAlt >=70000
	{
		stopwarp().
		RCS ON.
		panels off.
		setantenna(false).
		print "entering air".
	}
	else if ship:ALTITUDE >= 70000 and prevAlt <=70000
	{
		stopwarp().
		panels on.
		setantenna(true).
		print "leaving air".
	}
	else if ship:ALTITUDE <= 72000 and prevAlt >=72000
	{
		stopwarp().
		print "nearing air".
	}

	set prevAlt to ship:ALTITUDE.
	wait 0.
	PRESERVE.
}


//lock steering TO VCRS(SHIP:VELOCITY:ORBIT, BODY:POSITION).

wait until abort.

abort off.

print "end of file".