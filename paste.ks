@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").
runOncePath("library_gui").

librarysetup(false).

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
	CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
	print("I'm the Master CPU.").
	global heartGui is createHeartbeatGui().
}


sas off.
rcs on.
abort off.

lock simplePitch TO 90-((90/100)*((SHIP:APOAPSIS/70000)*100)).

lock steering to HEADING(90,max(0,simplePitch)).
lock steering to ship:up:vector.

lock throttle to 1.

function safeStage
{
	unlock steering.
	unlock throttle.
	wait 0.
	UNTIL STAGE:READY { WAIT 0. }
	print("Safe Staging: " + time:seconds).
	stage.
	wait 0.
}


wait 0.

safeStage.
lock steering to ship:up:vector.
lock throttle to 1.


local fuelLabel to heartGui:addLabel("").
when true then
{
	set fuelLabel:text to "fuel: "+GetStageLowestResource("liquidfuel").
	return true. //keep alive
}


local stageProtector to time:seconds + 2.
when GetStageLowestResource("liquidfuel")<=0.1 and time:seconds>stageProtector then
{
	wait 0.
	print("stage").
	stage.
	wait 0.

	set stageProtector to time:seconds + 2.

	return true. //keep alive
}


wait until abort.

abort off.

print("end of file").

