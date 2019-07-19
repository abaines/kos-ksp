@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup().

print("paste.ks 14").

wait 0.

print(CORE:tag).

if core:tag<>"mastercpu"
{
	print("Switching to booster script").
	run booster.
	print("derpy town").
}

sas off.
rcs off.
abort off.

lock simplePitch TO 90-((90/100)*((SHIP:APOAPSIS/45000)*100)).

lock steering to HEADING(90,max(0,simplePitch)).

lock throttle to 1.


wait 3.

print("stage").
stage.


wait until abort.

abort off.

print("end of file").

