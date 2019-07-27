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
	parameter gui, startX, startY, delegate, baseRate is 0.00001, expo is 10.

	local textFieldX to gui:ADDTEXTFIELD(""+startX).
	local textFieldY to gui:ADDTEXTFIELD(""+startY).

	local currentExpo is 1.

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

	local rateLabelsRow to gui:ADDHLAYOUT().
	local rateSmallLabel to rateLabelsRow:ADDLABEL("rateSmallLabel").
	local rateBigLabel to rateLabelsRow:ADDLABEL("rateBigLabel").

	local guiScaleRow to gui:ADDHLAYOUT().

	// update current currentExpo and update labels with new jump rates
	function updateCurrentExp
	{
		parameter newCurrentExp.

		set currentExpo to newCurrentExp.

		local scaleSmall is baseRate*(expo^(currentExpo+abs(1))).
		local scaleBig   is baseRate*(expo^(currentExpo+abs(2))).

		set rateSmallLabel:text to "" + scaleSmall.
		set rateBigLabel:text   to "" + scaleBig.
	}

	updateCurrentExp(currentExpo).

	FOR rateIter IN RANGE(0, 3+1)
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


// create heartbeat gui for tracking LOADED and UNPACKED
function createHeartbeatGui
{
	local sliderSize is 60*3.

	local heartGui is gui(200).
	local shipNameLabel is heartGui:addlabel("shipNameLabel").

	local heartbeatSlider is heartGui:ADDHSLIDER(sliderSize/2,0,sliderSize).

	local loadPackLabel is heartGui:addlabel("loadPackLabel").
	local statusLabel is heartGui:addlabel("statusLabel").
	local partCountLabel is heartGui:addlabel("partCountLabel").
	local speedLabel is heartGui:addlabel("speedLabel").
	local radarLabel is heartGui:addlabel("radarLabel").

	when true then
	{
		set shipNameLabel:text to ship:name.

		if heartbeatSlider:value=0
		{
			set heartbeatSlider:value to sliderSize.
		}
		else
		{
			set heartbeatSlider:value to heartbeatSlider:value - 1.
		}

		local stringBuilder to "".
		if ship:loaded
		{
			set stringBuilder to stringBuilder + "LOADED ".
		}
		if ship:unpacked
		{
			set stringBuilder to stringBuilder + "UNPACKED ".
		}
		if not ship:loaded and not ship:unpacked
		{
			set stringBuilder to stringBuilder + "not good -- derp ".
		}
		set loadPackLabel:text to stringBuilder.

		set statusLabel:text to "S:" +  ship:status + "  T:" + ship:type.

		set partCountLabel:text to "#parts: "+getAllParts():length.

		set speedLabel:text to "speed: "+RAP(ship:velocity:surface:mag,3).

		set radarLabel:text to "radar: "+RAP(min(SHIP:ALTITUDE , SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT),3).

		return true. //keep alive
	}

	heartGui:show().
	return heartGui.
}


// adds a interface to adjust PID to a given GUI.
function addPidInterfaceToGui
{
	parameter pidGUI. // the gui
	parameter guiPID. // the pid

	pidGUI:ADDLABEL("PID Controller").

	local guiP is addTextFieldDelegate(pidGUI, guiPID:KP, {parameter val. set guiPID:KP to val:tonumber().}).
	local pidHlayoutP to pidGUI:ADDHLAYOUT().
	addButtonDelegate(pidHlayoutP,"p-",{ set guiPID:KP to guiPID:KP / 1.2. set guiP:text to ""+guiPID:KP. }).
	addButtonDelegate(pidHlayoutP,"p+",{ set guiPID:KP to guiPID:KP * 1.2. set guiP:text to ""+guiPID:KP. }).

	local guiI is addTextFieldDelegate(pidGUI, guiPID:KI, {parameter val. set guiPID:KI to val:tonumber().}).
	local pidHlayoutI to pidGUI:ADDHLAYOUT().
	addButtonDelegate(pidHlayoutI,"i-",{ set guiPID:KI to guiPID:KI / 1.2. set guiI:text to ""+guiPID:KI. }).
	addButtonDelegate(pidHlayoutI,"i+",{ set guiPID:KI to guiPID:KI * 1.2. set guiI:text to ""+guiPID:KI. }).

	local guiD is addTextFieldDelegate(pidGUI, guiPID:KD, {parameter val. set guiPID:KD to val:tonumber().}).
	local pidHlayoutD to pidGUI:ADDHLAYOUT().
	addButtonDelegate(pidHlayoutD,"d-",{ set guiPID:KD to guiPID:KD / 1.2. set guiD:text to ""+guiPID:KD. }).
	addButtonDelegate(pidHlayoutD,"d+",{ set guiPID:KD to guiPID:KD * 1.2. set guiD:text to ""+guiPID:KD. }).

	local guiInputDesired is addTextFieldDelegate(pidGUI, guiPID:SETPOINT,
		{parameter val. set guiPID:SETPOINT to val:tonumber().}
	).
	local pidHlayoutSP to pidGUI:ADDHLAYOUT().
	addButtonDelegate(pidHlayoutSP,"setpoint-",
		{ set guiPID:SETPOINT to guiPID:SETPOINT - 0.2. set guiInputDesired:text to ""+guiPID:SETPOINT. }
	).
	addButtonDelegate(pidHlayoutSP,"setpoint+",
		{ set guiPID:SETPOINT to guiPID:SETPOINT + 0.2. set guiInputDesired:text to ""+guiPID:SETPOINT. }
	).

	local guiInput is pidGUI:ADDLABEL("guiInput").
	local guiOutput is pidGUI:ADDLABEL("guiOutput").
	pidGUI:ADDSPACING(12).
	local guiPterm is pidGUI:ADDLABEL("guiPterm").
	local guiIterm is pidGUI:ADDLABEL("guiIterm").
	local guiDterm is pidGUI:ADDLABEL("guiDterm").
	local guiErrorSum is pidGUI:ADDLABEL("guiErrorSum").
	pidGUI:ADDSPACING(12).
	local guiPidSetPointError is pidGUI:ADDLABEL("guiPidSetPointError").
	when true then
	{
		set guiInput:text to "in: "+round(guiPID:INPUT,6).
		set guiOutput:text to "out: "+round(guiPID:OUTPUT,6).

		set guiPterm:text to "pterm: "+round(guiPID:pterm,9).
		set guiIterm:text to "iterm: "+round(guiPID:iterm,9).
		set guiDterm:text to "dterm: "+round(guiPID:dterm,9).
		set guiErrorSum:text to "ErrorSum: "+round(guiPID:ErrorSum,9).

		set guiPidSetPointError:text to "Setpoint Err: " + round(guiPID:INPUT-guiPID:SETPOINT,6).
		return true.
	}
}



/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

// add waypoint dropdown menu to a gui
function createWaypointDropdownMenu
{
	parameter gui, latLngUpdateDelegate.

	local guiWaypointPopupMenu to gui:addpopupmenu().

	guiWaypointPopupMenu:addoption("Custom").
	guiWaypointPopupMenu:addoption("Ship").
	guiWaypointPopupMenu:addoption("Launch Pad").
	guiWaypointPopupMenu:addoption("Runway").

	for wayPointIter in ALLWAYPOINTS()
	{
		local wpName is char(34) + wayPointIter:name + char(34).
		// TODO: handle ship switching bodies
		if wayPointIter:body = ship:body
		{
			guiWaypointPopupMenu:addoption(wpName).
		}
	}

	set guiWaypointPopupMenu:onchange to
	{
		parameter choice.

		if choice = "Ship"
		{
			print("Ship").
			local shipGeoPosition to ship:geoposition.
			latLngUpdateDelegate(shipGeoPosition:lat,shipGeoPosition:lng).
			set guiWaypointPopupMenu:index to 0.
		}
		else if choice = "Launch Pad"
		{
			print("Launch Pad").
			latLngUpdateDelegate(ksplaunchpadgeo:lat,ksplaunchpadgeo:lng).
		}
		else if choice = "Runway"
		{
			print("Runway").
			local runwayStartGeo to kspRunwayStart().
			latLngUpdateDelegate(runwayStartGeo:lat,runwayStartGeo:lng).
		}
		else if choice = "Custom"
		{
			// do nothing
		}
		else if choice:startsWith(char(34)) and choice:endsWith(char(34))
		{
			local wp to WayPoint(choice:replace(char(34),"")).
			print(wp).
			latLngUpdateDelegate(wp:geoposition:lat,wp:geoposition:lng).
		}
		else
		{
			print("WTF? " + choice).
		}
	}.

	return guiWaypointPopupMenu.
}


// Round And Pad a number for printing
function RAP
{
	parameter _number, _round is 0, _pad is 0.
	// TODO: deal with decimal point moving so we always pad zeros to right
	// number of digits to right of decimal point should be equal to _round, pad with zeros as needed
	return round(_number,_round):toString:padLeft(_pad).
}


/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !
/// FUNCTIONS AND VARIBLES ONLY !

