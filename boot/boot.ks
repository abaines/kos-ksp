@LAZYGLOBAL off.

KUNIVERSE:TIMEWARP:CANCELWARP().

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

// if terminal:width<42 {set terminal:width to 42.}
// if terminal:height<45 {set terminal:height to 45.}

set Terminal:CHARHEIGHT to 10.

print "boot.ks".

wait 0.

run quad.
