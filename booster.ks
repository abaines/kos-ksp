@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup().

when time:seconds > scriptEpoch + 10 then
{
	set terminal:width  to 42.
	set terminal:height to 20.
}

print "booster.ks 15".



// wait until we are the only cpu core
until getCpuCoreCount()<=1 { wait 0. }


print("I'm in control now!").
local heartGui is createHeartbeatGui().



lock steering to ship:up:vector.

lock throttle to 0.5.


until 0 { wait 0. } // main loop wait forever

