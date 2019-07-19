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


when true then
{
	print(getAllParts:length).
}


until 0 { wait 0. } // main loop wait forever

