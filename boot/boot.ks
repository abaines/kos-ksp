@LAZYGLOBAL off.

KUNIVERSE:TIMEWARP:CANCELWARP().

CLEARSCREEN.

print "boot.ks".

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

if terminal:width<42 {set terminal:width to 42.}

set Terminal:CHARHEIGHT to 20.

CLEARVECDRAWS().

CLEARGUIS().

wait 0.


if ship:SHIPNAME:STARTSWITH("CC Command and Control") { run rover. }
else if ship:SHIPNAME:STARTSWITH("Smart Booster") { run multiStageLauncher. }
else if ship:SHIPNAME:STARTSWITH("Multi Vessel Test") { run multiStageLauncher. }
else if ship:SHIPNAME:STARTSWITH("KD White Rainbow") and ship:status="PRELAUNCH" { run multiStageLauncher. }
else if ship:SHIPNAME:STARTSWITH("KD White Rainbow") and ship:status="ORBITING" { run node. }
else if ship:SHIPNAME:STARTSWITH("Airboat ") and ship:status="PRELAUNCH" { run plane. }
else if ship:SHIPNAME:STARTSWITH("For Science") and ship:status="PRELAUNCH" { run guiSas. }
else if ship:SHIPNAME:STARTSWITH("For Contracts") and ship:status="PRELAUNCH" { run guiSas. }
else if ship:SHIPNAME:STARTSWITH("For Rescue") and ship:status="PRELAUNCH" { run guiSas. }
else if ship:SHIPNAME:STARTSWITH("For Awards") and ship:status="PRELAUNCH" { run guiSas. }
else if ship:SHIPNAME:STARTSWITH("Ferryman") and ship:status="PRELAUNCH" { run guiSas. }
else {
	CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
	print("Please select script for this vessel:").
	print(ship:SHIPNAME + "   " + ship:status).
}


print "end of boot file".

