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

// create interface for x and y values, including two text fields and a 5 by 5 grid of arrow buttons for manipulating the values
function createButtonGridWithTextFields
{
	parameter gui, startX, startY, delegate, baseRate is 0.0001, expo is 10.

	local textFieldX to gui:ADDTEXTFIELD(""+startX).
	local textFieldY to gui:ADDTEXTFIELD(""+startY).

	local currentExpo is 0.

	// grab the text field values and update caller delegate
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

	// take the button arrow grid events and convert them to updates in the text fields, and update caller.
	function updateText
	{
		parameter xChange, yChange.
		//print("" + xChange + " " + yChange).

		local xScale is baseRate*(expo^(currentExpo+abs(xChange))).
		local yScale is baseRate*(expo^(currentExpo+abs(yChange))).

		// TODO: add delegate here for flipping and rotating grid against x and y values

		set textFieldX:text to ""+(textFieldX:text:tonumber() + yScale*numberPositivity(yChange)). // TODO: should be +rate*xChange
		set textFieldY:text to ""+(textFieldY:text:tonumber() + xScale*numberPositivity(xChange)). // TODO: should be +rate*yChange

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

			addButtonDelegate(guiRowTemp, getGridButtonText(xx,yy), {updateText(xx,yy).}).
		}
	}

	local rateLabel to gui:ADDLABEL("rate").

	local guiScaleRow to gui:ADDHLAYOUT().

	// update current currentExpo and update labels with new jump rates
	function updateCurrentExp
	{
		parameter newCurrentExp.

		set currentExpo to newCurrentExp.

		local scaleSmall is baseRate*(expo^(currentExpo+abs(1))).
		local scaleBig   is baseRate*(expo^(currentExpo+abs(2))).

		set rateLabel:text to ""+scaleSmall + "  " + scaleBig.
	}

	updateCurrentExp(currentExpo).

	FOR rateIter IN RANGE(0, 2+1)
	{
		local localRateIter is 0+rateIter.
		addButtonDelegate(guiScaleRow,""+localRateIter, {
			updateCurrentExp(localRateIter).
		}).
	}

	// return a delegate for updating XY text fields
	return {
		parameter newX, newY.

		set textFieldX:text to ""+newX.
		set textFieldY:text to ""+newY.
	}.
}

// determine button text for button grid layout
function getGridButtonText
{
	parameter xx, yy.

	if xx = 0 and yy =0
	{
		return "0".
	}
	else if xx = 0
	{
		if yy<0
		{
			return "\/".
		}
		if yy>0
		{
			return "^".
		}
	}
	else if yy = 0
	{
		if xx<0
		{
			return "<".
		}
		if xx>0
		{
			return ">".
		}
	}

	return " ".
}

// determine sign of input number and return -1, 0, or +1.
function numberPositivity
{
	parameter value.

	if value=0
	{
		return 0.
	}
	else if value>0
	{
		return +1.
	}
	else if value<0
	{
		return -1.
	}
	else
	{
		return 0.
	}
}


/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !