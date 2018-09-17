@LAZYGLOBAL off.

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