@LAZYGLOBAL off.

runoncepath("library").

librarysetup().

beep().

print "circularize.ks".

stopwarp().

global status to "unknown".

function setStatus
{
	parameter currentStatus.
	
	set status to currentStatus:PADRIGHT(45).
}

// print updates
when 1 then
{
	print "apo-time     : " + eta_apoapsis() at(45,0).
	
	print "orbit-aoa    : " + ang_orbitaoa() at(45,2).
	
	print "throttle     : " + throttle at(45,4).
	print "steering     : " + STEERING at(45,5).
	
	print "orbit-period  : " + ship:orbit:period at(45,7).
	print "orbit-period% : " + (ship:orbit:period / (60*60*6)) at(45,8).
	
	
	print status at(45,20).

	wait 0.
	PRESERVE.
}

print "Setting Heading".
lock STEERING TO HEADING(90,0).

setStatus("facing orbit forward.").

wait until ang_orbitaoa() < 20.

print "Heading good enough".
setStatus("done waiting.").

// 2863330
until ship:APOAPSIS > 2863330*0.99
{
	setStatus("orbit-aoa " + ang_orbitaoa()).
	
	if ang_orbitaoa() < 2
	{
		lock throttle to 1.
	}
	else if ang_orbitaoa() < 45
	{
		lock throttle to 0.5/ang_orbitaoa().
	}
	else
	{
		lock throttle to 0.
	}
	
	wait 0.
}

print "APOAPSIS > 2863330*0.99".

lock throttle to 0.

until ship:PERIAPSIS > 2863330*0.99
{
	setStatus("PERIAPSIS " + eta_apoapsis()).
	
	if eta_apoapsis() > -60
	{
		if eta_apoapsis() < 60
		{
			if ang_orbitaoa() < 2
			{
				lock throttle to 1.
			}
			else if ang_orbitaoa() < 20
			{
				lock throttle to 0.01.
			}
			else
			{
				lock throttle to 0.
			}
		}
		else if eta_apoapsis() < 180
		{
			stopwarp().
			setStatus("stopwarp " + eta_apoapsis()).
			lock throttle to 0.
		}
		else
		{
			lock throttle to 0.
		}
	}
	else
	{
		lock throttle to 0.
	}
	
	wait 0.
}

print "PERIAPSIS > 2863330*0.99".

local happy to false.

until happy
{
	
}

print "circularize!".

stopwarp().
lock throttle to 0.
LOCK STEERING TO HEADING(90,90).

print "end of file".