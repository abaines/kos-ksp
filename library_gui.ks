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

	CLEARGUIS().
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

function addTextFieldDelegate
{
	parameter gui, text, delegate.

	local textField to gui:ADDTEXTFIELD(""+text).
	set textField:ONCONFIRM to delegate.

	return textField.
}

function createButtonGridWithTextFields
{
	parameter gui, startX, startY, delegate.

	local textFieldX to gui:ADDTEXTFIELD(""+startX).
	local textFieldY to gui:ADDTEXTFIELD(""+startY).

	function updateDelegate
	{
		local xText to textFieldX:text.
		local yText to textFieldY:text.
		//print("UD " + xText + " " + yText).
		delegate(xText:tonumber(),yText:tonumber()).
	}

	set textFieldX:ONCONFIRM to {
		parameter value.
		updateDelegate().
	}.

	set textFieldY:ONCONFIRM to {
		parameter value.
		updateDelegate().
	}.



	// TODO: the thing
	local guiGeoRow1 to gui:ADDHLAYOUT().
	local guiRow1a to guiGeoRow1:addbutton("1a").
	local guiRow1b to guiGeoRow1:addbutton("1b").
	local guiRow1c to guiGeoRow1:addbutton("1c").
	local guiGeoRow2 to gui:ADDHLAYOUT().
	local guiRow2a to guiGeoRow2:addbutton("2a").
	local guiRow2b to guiGeoRow2:addbutton("2b").
	local guiRow2c to guiGeoRow2:addbutton("2c").
	local guiGeoRow3 to gui:ADDHLAYOUT().
	local guiRow3a to guiGeoRow3:addbutton("3a").
	local guiRow3b to guiGeoRow3:addbutton("3b").
	local guiRow3c to guiGeoRow3:addbutton("3c").

	updateDelegate().
}


/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !