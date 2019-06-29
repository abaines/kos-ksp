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
	parameter gui, startX, startY, delegate, rate is 0.002.

	local textFieldX to gui:ADDTEXTFIELD(""+startX).
	local textFieldY to gui:ADDTEXTFIELD(""+startY).

	function updateDelegate
	{
		local xText to textFieldX:text.
		local yText to textFieldY:text.
		//print("UD " + xText + " " + yText).
		delegate(xText:tonumber(),yText:tonumber()).
	}

	updateDelegate().

	set textFieldX:ONCONFIRM to {
		parameter value.
		updateDelegate().
	}.

	set textFieldY:ONCONFIRM to {
		parameter value.
		updateDelegate().
	}.

	function updateText
	{
		parameter xChange, yChange.
		//print("" + xChange + " " + yChange).

		// TODO: add delegate here for flipping and rotating grid against x and y values

		set textFieldX:text to ""+(textFieldX:text:tonumber() + rate*yChange). // TODO: should be +rate*xChange
		set textFieldY:text to ""+(textFieldY:text:tonumber() + rate*xChange). // TODO: should be +rate*yChange

		updateDelegate().
	}

	updateText(0,0).

	FOR row IN RANGE(-2, 2+1)
	{
		local guiRowTemp to gui:ADDHLAYOUT().
		FOR col IN RANGE(-2, 2+1)
		{
			//print("& " + row + " " + col).
			local xx is +1*col.
			local yy is -1*row.
			local buttonText is " ".

			if xx = 0 and yy =0
			{
				set buttonText to "0".
			}
			else if xx = 0
			{
				if yy<0
				{
					set buttonText to "\/".
				}
				if yy>0
				{
					set buttonText to "^".
				}
			}
			else if yy = 0
			{
				if xx<0
				{
					set buttonText to "<".
				}
				if xx>0
				{
					set buttonText to ">".
				}
			}

			addButtonDelegate(guiRowTemp,buttonText, {updateText(xx,yy).}).
		}
	}
}


/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !