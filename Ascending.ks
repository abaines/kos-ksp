@LAZYGLOBAL off.

runoncepath("library").

librarysetup().

beep().

print "Ascending.ks" at(0,0).
print ship at(0,1).

// remove all maneuver nodes.
until not HASNODE
{
	REMOVE NEXTNODE.
}

sas off.

global AscendingNode to EtaAscendingNode().

//ADD NODE(time:seconds+AscendingNode["eta"], 0, 0, 0). 

lock steering TO VCRS(SHIP:VELOCITY:ORBIT, BODY:POSITION).

global currentThrottle to 0.
lock throttle to currentThrottle.
global exitScript to false.

when true then
{
	print "seconds : " + TIME:SECONDS at(45,0).
	print "elapsed : " + (time:seconds - whenLoop) at (45,1).
	set whenLoop to time:seconds.

	set AscendingNode to EtaAscendingNode().
	local anETA to AscendingNode["eta"].
	local inclin to AscendingNode["inclination"].
	
	print "eta         : " + anETA at (0,10).
	print "errTime     : " + AscendingNode["errTime"] at (0,11).
	print "computeTime : " + AscendingNode["computeTime"] at (0,12).
	print "inclination : " + inclin at (0,14).
	
	// throttle math !
	set currentThrottle to (30-anETA)/9000.
	
	print "currentThrottle : " + currentThrottle + "                  " at (0,20).
	
	if inclin < 0.00009
	{
		set currentThrottle to 0.
		lock throttle to 0.
		print "done : " + inclin at (0,30).
		set exitScript to true.
		return.
	}

	wait 0.
	PRESERVE.
}

wait until exitScript.

print "end of file".