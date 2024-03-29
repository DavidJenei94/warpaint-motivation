import Toybox.WatchUi;
import Toybox.System;
import Toybox.Graphics;

// Extend text to set as drawable text
class Time extends WatchUi.Text {
	
	private var _settings as System.DeviceSettings;
	private var _burnInProtection as Boolean; //true if amoled is in low power mode

	private var _clockTime as ClockTime;
	private var _time as String;
	private var _AmPm as String;
	private var _seconds as String;
	
	//! Constructor
	//! @param params in the layout.xml the drawable object's param tags
	function initialize(params) {
		Text.initialize(params);
	}
	
	//! Gets the bounding box of the seconds to be able to use in 
	//! onPartialUpdate to update only the seconds region every seconds
	//! @param dc Device context
	//! @return Array of x, y, width, height of bounding box 
	(:partial_update)
	function getSecondsBoundingBox(dc as Dc) as Array<Number> {
		refreshTimeData();	
		// get the wider region in pixels of the current or the previous second
		var previousSecond = (_seconds.toNumber() - 1) % 60;
		var maxTextDimensions = dc.getTextDimensions(previousSecond.toString(), smallFont)[0] > dc.getTextDimensions(_seconds, smallFont)[0] ? 
			dc.getTextDimensions(previousSecond.toString(), smallFont) : 
			dc.getTextDimensions(_seconds, smallFont);
		var width = maxTextDimensions[0] + 2;
		var height = maxTextDimensions[1];
		
		var timeWidth = getTimeWidth(dc);
		var x = dc.getWidth() / 2 + timeWidth + 3;
		var y = dc.getHeight() / 2 - (height / 2);

		return [x, y, width, height];
	}

	//! Draw the time, AM/PM and seconds
	//! @param dc Device Content
	function draw(dc as Dc) as Void {
		drawTime(dc);
		drawAmPm(dc);
	}
	
	//! Draw the time according to the settings, eg. 12:34
	//! @param dc Device Content
	function drawTime(dc as Dc) as Void {
		refreshTimeData();
		if (_burnInProtection) {
			self.setColor(Graphics.COLOR_WHITE);
		} else {
			self.setColor(themeColors[:foregroundSecondaryColor]);
		}	
        self.setText(_time);
		Text.draw(dc);
	}
	
	//! Draw AM or PM in front of time if 12 hour format is set
	//! @param dc Device Content
	function drawAmPm(dc as Dc) as Void {
		if (!_settings.is24Hour) {
			_AmPm = _clockTime.hour >= 12 ? "PM" : "AM";
			var x = dc.getWidth() / 2 - getTimeWidth(dc) - (dc.getTextWidthInPixels(_AmPm, smallFont) / 2 + 3); // 3 pixels from time
			var y = dc.getHeight() / 2;
			dc.setColor(themeColors[:foregroundPrimaryColor], themeColors[:backgroundColor]);
			dc.drawText(
				x, 
				y, 
				smallFont, 
				_AmPm, 
				Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
			);
		}
	}
	
	//! Draw the seconds after the time
	//! @param dc Device Content
	function drawSeconds(dc as Dc) as Void {	
		refreshTimeData();
		var x = dc.getWidth() / 2 + getTimeWidth(dc) + (dc.getTextWidthInPixels(_seconds, smallFont) / 2 + 3); // 3 pixels from time
		var y = dc.getHeight() / 2;
		dc.setColor(themeColors[:foregroundPrimaryColor], themeColors[:backgroundColor]);
		dc.drawText(
			x, 
			y, 
			smallFont, 
			_seconds, 
			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
		);
	}
	
	//! Refresh time data
	private function refreshTimeData() as Void {
		_clockTime = System.getClockTime();
		_time = calculateTime();
		_seconds = _clockTime.sec.toString();			
	}
	
	//! Get current time according to settings
	//! @return formatted current time as string 
	private function calculateTime() as String {
        var timeFormat = "$1$:$2$";
        var hours = _clockTime.hour;
        if (!_settings.is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (militaryFormat) {
                timeFormat = "$1$$2$";
            }
        }

        return Lang.format(timeFormat, [hours.format("%02d"), _clockTime.min.format("%02d")]);
	}
	
	//! Gets the half of the width of the time text to postion AM/PM and seconds
	//! @return half of the width of the time in pixels
	private function getTimeWidth(dc as Dc) as Number {
		return dc.getTextWidthInPixels(_time, largeFont) / 2;
	}

	//! Set settings
	//! @param settings DeviceSettings
	function setSettings(settings as DeviceSettings) as Void {
		_settings = settings;
	}

	//! Set Burn In protection
	//! @param settings DeviceSettings
	function setBurnInProtection(burnInProtection as Boolean) as Void {
		_burnInProtection = burnInProtection;
	}
}
