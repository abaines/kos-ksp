/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

@LAZYGLOBAL off.


/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

global reallyBigNumber is 2147483646.


GLOBAL voice0 TO GetVoice(0).
SET voice0:VOLUME TO 0.20.

/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !


function librarysetup
{
	stopwarp().

	CLEARSCREEN.

	CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

	CLEARVECDRAWS().
}

function beep
{
	parameter hertz is 1000, volume is 0.3, duration is 0.01, keyDownLength is 0.01.

	voice0:PLAY( NOTE( hertz, duration, keyDownLength, volume) ).
}


function addButtonDelegate
{
	parameter gui, text, delegate.
	
	local button to gui:addbutton(text).
	set button:onclick to delegate.
	
	return button.
}


/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !