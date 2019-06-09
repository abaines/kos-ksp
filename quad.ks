@LAZYGLOBAL off.

global scriptEpoch to time:seconds.

runOncePath("library").

librarysetup().

PARAMETER PARAMETER1 is " ".

if false
{
	set terminal:width to 45.
	set terminal:height to 20.
}

print "quad.ks 11" at(0,0).
print "quad.ks 11" at(0,21).

global _throttle to 1.0.
lock throttle to _throttle.

global _steering to up.
lock steering to _steering.

rcs off.
sas off.

managePanelsAndAntenna().

manageFuelCells().

global qeN is ship:partsTagged("qe-n")[0].
global qeE is ship:partsTagged("qe-e")[0].
global qeS is ship:partsTagged("qe-s")[0].
global qeW is ship:partsTagged("qe-w")[0].
global qeC is ship:partsTagged("qe-c")[0].

lock dist2ground to min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT).

lock upwardMovementVec to vector_projection(vec_up():normalized,ship:velocity:surface).
lock upwardMovement to vdot(vec_up():normalized,upwardMovementVec).

//print(qeN:POSITION).

local vdd1 is VECDRAW_DEL({return ship:position.}, {return qeN:POSITION.}, RGB(0,0,1)).

local vdd2 is VECDRAW_DEL({return ship:position.}, { return upwardMovementVec. }, RGB(1,0,1)).

//local vdd3 is VECDRAW_DEL({return ship:position.}, { return 10*vector_projection(vec_up()*50,srfprograde:vector:normalized). }, RGB(0,1,1)).


//local v1 is V(50,-120,0).
//local v2 is V(30,40,0).
//print(vector_projection(v1,v2)).
//
//local vdd4 is VECDRAW_DEL({return ship:position.}, {return V(10,100,0).}, RGB(1,0,1)).
//local vdd5 is VECDRAW_DEL({return ship:position.}, {return V(40,30,0).}, RGB(0,1,1)).
//local vdd6 is VECDRAW_DEL({return ship:position.}, {return vector_projection(V(10,100,0):normalized,V(40,30,0)).}, RGB(0,1,0)).


//print(qeN).
//print(qeC).
//print(qeC:allfields).
//print(qeC:MAXTHRUST).

lock desiredHeight to min(dist2ground+1,50).


global thrustPID1 TO PIDLOOP(20, 0, 1/100, -5, 10). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set thrustPID1:SETPOINT to 0.1.

global thrustPID2 TO PIDLOOP(100, 0.5, 0.5, 50, 100). // (KP, KI, KD, MINOUTPUT, MAXOUTPUT)
set thrustPID2:SETPOINT to 50.

qeC:Activate().

function mainLoop
{
	print "mt "+qeC:MAXTHRUST+"               " at(0,5).
	print "dh "+desiredHeight+"               " at(0,6).
	print "um "+upwardMovement+"               " at(0,7).
	
	local tpid2 to thrustPID2:update(time:second,dist2ground).
	print "tpid2 "+tpid2+"               " at(0,9).
	set qeC:THRUSTLIMIT to tpid2.
}

until false
{
	mainLoop().
	wait 0.
}


print "end of file".
