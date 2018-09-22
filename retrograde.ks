@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runoncepath("library").

librarysetup().

print "retrograde.ks".

lock steering to -1*ship:srfprograde:vector.

until false
{
	wait 0.1.
}