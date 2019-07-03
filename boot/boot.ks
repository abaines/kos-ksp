@LAZYGLOBAL off.

KUNIVERSE:TIMEWARP:CANCELWARP().

CLEARSCREEN.

print "boot.ks".

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

if terminal:width<42 {set terminal:width to 42.}

set Terminal:CHARHEIGHT to 10.

CLEARVECDRAWS().

CLEARGUIS().

wait 0.

run quad.
