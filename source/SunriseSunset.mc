import Toybox.Math;
import Toybox.System;
import Toybox.Time.Gregorian;
import Toybox.Time;
import Toybox.Activity;
import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Position;
import Toybox.Graphics;

class SunriseSunset {

	private var _sunrise as Number; // in hour, eg. 8.23
	private var _sunset as Number;
	private var _hour as Number;
	private var _min as Number;

	private var _successfulCalculation as Boolean;
	
	//! Constructor
    function initialize() {
        _successfulCalculation = calculateSunriseSunset();
    }

	//! Refresh the sunrise and sunset data
	function refreshSunsetSunrise() as Void {
		 _successfulCalculation = calculateSunriseSunset();
	}
    
	//! Get next sunrise/sunset time
	//! @return array of the next sunrise or sunset (according to current time) in string 
	//! and a bool value if it is sunrise or not
    function getNextSunriseSunset() as Array<Number or String or Boolean> {
		if (!_successfulCalculation) {
			return [-1, true];
		}

		var clockTime = System.getClockTime();
    	_hour = clockTime.hour;
    	_min = clockTime.min;

    	var currentTime = _hour + _min / 60.0;
    	if (currentTime < _sunrise || currentTime > _sunset) {
			System.println("sunrise");
    		return [formatHoursToTimeString(_sunrise), true];
    	} else {
			System.println("sunset");
    		return [formatHoursToTimeString(_sunset), false];
    	}
    }
    
	//! Format sunrise/sunset time
	//! @param time the hour in Float
	//! @return formatted sunrise or sunset in string
    private function formatHoursToTimeString(time as Number) as String {
    	var hour = Math.floor(time);
    	var min = (time - hour) * 100 * 0.6;
    	if (!System.getDeviceSettings().is24Hour) {
            if (hour > 12) {
                hour -= 12;
            }
    	}

        return Lang.format("$1$:$2$", [hour.format("%02d"), min.format("%02d")]);	
    }
    
	//! Draw arcs for day and night and also the sun's current position
	//! only for round screens and only for outer circle
	//! @param dc as Device Content
	(:roundShape)
    function drawSunriseSunsetArc(dc as Dc) as Void {
		if (!_successfulCalculation) {
			return;
		}
		
		// center of arcs = center of round screen
    	var arcX = dc.getWidth() / 2;
    	var arcY = dc.getHeight() / 2;
    	var width = dataBarWidth + 4; // the outer circle has to be greater because the center of the circle is not at the center of the screen
    	var radius = arcX - dataBarWidth / 2 + 2;
    	
    	var color = themeColors[:isColorful] ? Graphics.COLOR_YELLOW : themeColors[:foregroundPrimaryColor]; //day color
	    var startAngle = (90.0 - (_sunrise * (360.0 / 24.0)));
	    var endAngle = (90.0 - (_sunset * (360.0 / 24.0)));
	    dc.setPenWidth(width);
		dc.setColor(color, themeColors[:backgroundColor]);
		dc.drawArc(
	    	arcX, 
	    	arcY, 
	    	radius, 
	    	Graphics.ARC_CLOCKWISE, 
	    	startAngle, 
	    	endAngle
	    );
	    
	    color = themeColors[:isColorful] ? Graphics.COLOR_DK_GRAY : themeColors[:backgroundColor]; //night color
	    dc.setColor(color, themeColors[:backgroundColor]);    	
    	dc.drawArc(
    		arcX, 
    		arcY, 
    		radius, 
    		Graphics.ARC_CLOCKWISE, 
    		endAngle, 
    		startAngle
    	);
    	
		// On Bicolor themes the suncolor should change according to the daytime
		if (theme % 5 != 2) {
			color = themeColors[:isColorful] ? Graphics.COLOR_RED : themeColors[:foregroundSecondaryColor]; //sun color
		} else {
			color = getNextSunriseSunset()[1] ? themeColors[:foregroundPrimaryColor] : themeColors[:backgroundColor]; //sun color
		}
    	
    	dc.setColor(color, themeColors[:backgroundColor]);
    	
    	var currentTime = _hour + _min / 60.0;
    	var degree = 180 - (currentTime * (360.0 / 24.0));
    	var radians = Math.toRadians(degree);
    	var distance = arcX - (dataBarWidth / 2) + 1; // distance of the center of the sun from the center of screen
    	var x = distance + distance * Math.sin(radians);
    	var y = distance + distance * Math.cos(radians);
    	
    	var coordinates = xyCorrection(x, y, distance, dc);
    	x = coordinates[0];
    	y = coordinates[1];
    	
    	dc.fillCircle(x, y, (dataBarWidth + 1) / 2);
    }
    
	//! Calculates sunrise and sunset values according to date/time and location
	//! https://gml.noaa.gov/grad/solcalc/solareqns.PDF
	//! @return boolean value if the calculation is successful or not
    private function calculateSunriseSunset() as Boolean {  
		setCoordinates();
		var latitude = 0.0;
	    var longitude = 0.0;
		if (locationLat != null && locationLng != null) {
			latitude = locationLat;
	    	longitude = locationLng;
		} else {
			return false;
		}

    	var clockTime = System.getClockTime();
    	_hour = clockTime.hour;
    	_min = clockTime.min;
    	var dst = clockTime.dst / 3600; // The daylight savings time offset in hour
    	var timeZoneOffset = clockTime.timeZoneOffset / 3600; // Timezone offset in hour
    	
		var today = new Time.Moment(Time.today().value());
		var todayInfo = Gregorian.info(today, Time.FORMAT_SHORT);
		var options = {
		    :year   => todayInfo.year,
		    :month  => 01,
		    :day    => 01,
		    :hour   => 00,
		    :minute => 00
		};
		var firstDayOfYear = Gregorian.moment(options);
    	var dayOfYear = Math.ceil(today.subtract(firstDayOfYear).value() / 60.0 / 60.0 / 24.0) + 1;
    	var totalDaysInYear = todayInfo.year % 4 == 0 ? 366 : 365;
    	var fractionalYear = ((2 * Math.PI) / totalDaysInYear) * (dayOfYear - 1 + ((_hour - 12) / 24));
    	
		// equation of time in minutes
    	var eqtime = 229.18 * (0.000075 + 0.001868 * Math.cos(fractionalYear) - 0.032077 * Math.sin(fractionalYear) - 
    		0.014615 * Math.cos(2 * fractionalYear) - 0.040849 * Math.sin(2 * fractionalYear));
    	// declination angle in radians
		var decl = 0.006918 - 0.399912 * Math.cos(fractionalYear) + 0.070257 * Math.sin(fractionalYear) - 0.006758 * Math.cos(2 * fractionalYear) + 
    		0.000907 * Math.sin(2 * fractionalYear) - 0.002697 * Math.cos(3 * fractionalYear) + 0.00148 * Math.sin(3 * fractionalYear);
	    
		// hour angle in radians
    	var hourAngle = Math.acos(Math.cos(Math.toRadians(90.833)) / (Math.cos(latitude) * Math.cos(decl))) - 
    		(Math.tan(latitude) * Math.tan(decl));
    		
    	_sunrise = ((720 - 4 * (longitude + Math.toDegrees(hourAngle)) - eqtime) / 60) + timeZoneOffset + dst; // in hour
    	_sunset = ((720 - 4 * (longitude - Math.toDegrees(hourAngle)) - eqtime) / 60) + timeZoneOffset + dst; // in hour

		return true;
    }
    
    //! x, y position needs adjustment to be in a good place
    //! simultaniously makes changes to temp x, y and original x, y to be in the correct pos
	//! @param x original x coordinate
	//! @param y original y coordinate
	//! @param distance the distance of the center of the sun from the middle of screen
	//! @param dc Device context
	//! @return array of adjusted original x, y coordinates
    (:roundShape)
	private function xyCorrection(x, y, distance, dc) as Array<Number> {
    	var coordinates = new [2];
    	var xOriginal = x;
    	var yOriginal = y;
		// x and y recalculated as the center of screen is the origin (0, 0: middle of coordinate pane) (not the top left corner (0, 0))
		// calculate the distance this way from the origin to center the sun
    	x = x - dc.getWidth() / 2;
    	y = y - dc.getHeight() / 2;    	
    	var changesDict;
    	
		// Try out change in every dimension and select the one which is closest to the original distance
    	var c = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
    	while (c < distance - 0.1 || c > distance + 0.1) {
    		changesDict = {
    			:noChangeEffect => (distance - c).abs(),
			    :xPlusChangeEffect => (distance - Math.sqrt(Math.pow(x + 1, 2) + Math.pow(y, 2))).abs(),
			    :yPlusChangeEffect => (distance - Math.sqrt(Math.pow(x, 2) + Math.pow(y + 1, 2))).abs(),
			    :xMinusChangeEffect => (distance - Math.sqrt(Math.pow(x - 1, 2) + Math.pow(y, 2))).abs(),
			    :yMinusChangeEffect => (distance - Math.sqrt(Math.pow(x, 2) + Math.pow(y - 1, 2))).abs()
			};
			
			var min = distance;
			var minKey = "";
			for (var i = 0; i < changesDict.size(); i++) {
				var keys = changesDict.keys();
				if (changesDict.get(keys[i]) < min) {
					min = changesDict.get(keys[i]);
					minKey = keys[i];
				}
			}
			
	    	switch (minKey) {
    			case :noChangeEffect:
			    	coordinates[0] = xOriginal;
    				coordinates[1] = yOriginal;
    				return coordinates;
    			case :xPlusChangeEffect:
	    			x++;
    				xOriginal++;
    				break;
    			case :yPlusChangeEffect:
	    			y++;
    				yOriginal++;
    				break;
    			case :xMinusChangeEffect:
	    			x--;
    				xOriginal--;
    				break;    			
    			case :yMinusChangeEffect:
	    			y--;
    				yOriginal--;
    				break;    			
    		}
    		c = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
    	}
    
    	coordinates[0] = xOriginal;
    	coordinates[1] = yOriginal;
    	return coordinates;
    }

    //! Set coordinates for sunrise sunset calculation and store it in Storage or Appbase properties
    private function setCoordinates() as Void {
        var location = Activity.getActivityInfo().currentLocation;
        if (location) {
            locationLat = location.toDegrees()[0].toFloat();
            locationLng = location.toDegrees()[1].toFloat();

            if (Toybox.Application has :Storage) {
                Storage.setValue("LastLocationLat", locationLat);
                Storage.setValue("LastLocationLng", locationLng);
            } else {
                getApp().setProperty("LastLocationLat", locationLat);
                getApp().setProperty("LastLocationLng", locationLng);
            }
        } else {
            if (Toybox.Application has :Storage) {
                var lat = Storage.getValue("LastLocationLat");
                if (lat != null) {
                    locationLat = lat;
                }

                var lng = Storage.getValue("LastLocationLng");
                if (lng != null) {
                    locationLng = lng;
                }
            } else {
                var lat = getApp().getProperty("LastLocationLat");
                if (lat != null) {
                    locationLat = lat;
                }

                var lng = getApp().getProperty("LastLocationLng");
                if (lng != null) {
                    locationLng = lng;
                }
            }
        }
    }
    
}