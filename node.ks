@LAZYGLOBAL off.

global scriptEpoch to time:seconds.
lock scriptElapsedTime to time:seconds - scriptEpoch.
lock PSET to " @ " + RAP(scriptElapsedTime,2).

// print with @ script Elapsed Time
function pwset
{
	parameter msg.
	local _pset to PSET.
	local padRequired to 42-_pset:length.
	print(msg:toString:padRight(padRequired)+_pset).
}

runOncePath("library").
runOncePath("library_gui").
runOncePath("library_vec").

librarysetup(false).

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
print("node.ks 17").
pwset(CORE:tag).

when time:seconds > scriptEpoch + 10 then
{
	set terminal:width  to 42.
	set terminal:height to 50.
}

wait 0.

sas off.
rcs off.
abort off.

managePanelsAndAntenna().
manageFuelCells().


local vddSrfPrograde is VECDRAW_DEL({return ship:position.}, { return ship:srfprograde:vector*100. }, RGB(0,0,1)).
local vddSrfProgradePlane is VECDRAW_DEL({return ship:position.}, { return VXCL(vec_up(),ship:srfprograde:vector):normalized*100. }, RGB(0,1,0.5)).
local vddFacing is VECDRAW_DEL({return ship:position.}, { return ship:facing:vector:normalized*25. }, RGB(0.1,0.1,0.1)).




global nodeGui is gui(200).
set nodeGui:x to -400.
set nodeGui:y to 100.
local nodeGuiLabel is nodeGui:addlabel("Node GUI").

local nodeEtaLabel is nodeGui:addlabel("nodeEtaLabel").

local nodeProLabel is nodeGui:addlabel("nodeProLabel").
local nodeRadLabel is nodeGui:addlabel("nodeRadLabel").
local nodeNorLabel is nodeGui:addlabel("nodeNorLabel").

local nodeOrbitPeriodLabel is nodeGui:addlabel("nodeOrbitPeriodLabel").

local nodeClosestApproachLabel is nodeGui:addlabel("nodeClosestApproachLabel").
local nodeClosestApproachTLabel is nodeGui:addlabel("nodeClosestApproachTLabel").
local nodeClosestApproachCTLabel is nodeGui:addlabel("nodeClosestApproachCTLabel").



addRebootButton(nodeGui).


when true then
{
	local nodes is ALLNODES.
	if nodes:length>0
	{
		local nodeZero is nodes[0].
		set nodeEtaLabel:text to ""+formatTime(nodeZero:ETA).

		set nodeProLabel:text to ""+RAP(nodeZero:PROGRADE,2).
		set nodeRadLabel:text to ""+RAP(nodeZero:RADIALOUT,2).
		set nodeNorLabel:text to ""+RAP(nodeZero:NORMAL,2).

		set nodeOrbitPeriodLabel:text to ""+formatTime(nodeZero:ORBIT:PERIOD).

		if HASTARGET
		{
			local caLex to closestapproach(ship,target,time:seconds,time:seconds+nodeZero:ORBIT:PERIOD+nodeZero:ETA).

			set nodeClosestApproachLabel:text to ""+RAP(caLex["minDist"],2).
			set nodeClosestApproachTLabel:text to ""+formatTime(caLex["minTime"]-time:seconds).
			set nodeClosestApproachCTLabel:text to ""+RAP(caLex["computeTime"],2).
		}
		else
		{
			set nodeClosestApproachLabel:text to "NO TARGET".
		}

	}

	return true. //keep alive
}

nodeGui:show().





pwset("Script loaded").
until 0 { wait 0. } // main loop wait forever

///////////////////////////////////////////////////////////////////////////////
/// Legacy Code // Legacy Code // Legacy Code // Legacy Code // Legacy Code ///
///////////////////////////////////////////////////////////////////////////////





runoncepath("library").

librarysetup().

beep().

print "node.ks" at(0,0).
print ship at(0,1).

global whenLoop to time:seconds.

global exitScript to false.

global nextN to nextnode.

lock max_acc to max(0.0001,ship:maxthrust/max(1,ship:mass)).
lock burn_duration to nextN:deltav:mag / max(0.1,max_acc).

global burn_vector to nextN:BURNVECTOR.
lock steering to burn_vector.

global throt to 0.
lock throttle to throt.

sas off.

when true then
{
	print "TIME : " + TIME:SECONDS at(45,0).
	print time:seconds - whenLoop at (45,1).
	set whenLoop to time:seconds.

	print "ETA   : " + nextN:eta at (45, 5).
	print "dv    : " + nextN:deltav:mag at (45, 6).

	print "acc   : " + max_acc at (45,10).
	print "burn  : " + burn_duration at (45,11).

	local start to nextN:eta - (burn_duration/2).
	print "start : " + start at (45,15).

	local facingGood to false.
	local timingGood to false.

	local facingError to vang(ship:facing:vector,burn_vector).

	print facingError at(45,19).

	if facingError < 5
	{
		print "facing burn" at (45,20).
		set facingGood to true.
	}
	else
	{
		print "           " at (45,20).
	}

	if start<=0
	{
		print "start burn" at (45,22).
		set timingGood to true.
	}
	else
	{
		print "          " at (45,22).
	}

	local vdotcalc is vdot(burn_vector,nextN:deltaV).
	print vdotcalc at (45,25).

	if timingGood and facingGood and vdotcalc>=0
	{
		set throt to min(nextN:deltav:mag/max_acc, 1).
	}
	else
	{
		set throt to 0.
	}

	if start < 30
	{
		stopwarp().
	}

	if burn_duration < 0.0001
	{
		lock throttle to 0.
		beep().
		set exitScript to true.
		return.
	}

	wait 0.
	PRESERVE.
}

wait until exitScript.

remove nextN.

run measure.

print "end of file".