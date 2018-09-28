@LAZYGLOBAL off.

KUNIVERSE:TIMEWARP:CANCELWARP().

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

if terminal:width<90 {set terminal:width to 90.}
if terminal:height<45 {set terminal:height to 45.}

set Terminal:CHARHEIGHT to 10.

print "boot.ks".

wait 0.

run hello.
