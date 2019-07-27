@LAZYGLOBAL off.

KUNIVERSE:TIMEWARP:CANCELWARP().

CLEARSCREEN.

print "boot.ks".

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

if terminal:width<42 {set terminal:width to 42.}

set Terminal:CHARHEIGHT to 10.

CLEARVECDRAWS().

CLEARGUIS().

wait 0.


if ship:SHIPNAME:STARTSWITH("CC Command and Control") { run rover. }
else if ship:SHIPNAME:STARTSWITH("Smart Booster") { run paste. }
else if ship:SHIPNAME:STARTSWITH("Multi Vessel Test") { run paste. }
else if ship:SHIPNAME:STARTSWITH("KD White Rainbow") and ship:status="PRELAUNCH" { run paste. }
else if ship:SHIPNAME:STARTSWITH("KD White Rainbow") and ship:status="ORBITING" { run land. }
else {
	CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
	print("Please select script for this vessel:").
	print(ship:SHIPNAME + "   " + ship:status).
}


print "end of boot file".

