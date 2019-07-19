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

print("paste.ks 14").

wait 0.

print(CORE:tag).

if core:tag<>"mastercpu"
{
	print("Switching to booster script").
	run booster.
	print("derpy town").
}
else
{
	print("I'm the Master CPU.").
	local heartGui is createHeartbeatGui().
}


sas off.
rcs on.
abort off.

lock simplePitch TO 90-((90/100)*((SHIP:APOAPSIS/45000)*100)).

lock steering to HEADING(90,max(0,simplePitch)).

lock throttle to 1.


wait 3.


wait 0.
print("stage").
stage.
wait 0.


when GetStageLowestResource("liquidfuel")<=0.01 then
{
	wait 0.
	print("stage").
	stage.
	wait 0.
}


wait until abort.

abort off.

print("end of file").

