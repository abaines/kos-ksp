@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup().

print "paste.ks".

wait 0.

sas off.
rcs off.
abort off.


lock steering to ship:up:vector.

lock throttle to 1.


wait 1.

stage.


wait until abort.

abort off.

print "end of file".