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
	(:sunriseSunset)
	function refreshSunsetSunrise() as Void {
		 _successfulCalculation = calculateSunriseSunset();
	}
    
	//! Get next sunrise/sunset time
	//! @param settings DeviceSettings
	//! @return array of the next sunrise or sunset (according to current time) in string 
	//! and a bool value if it is sunrise or not
	(:sunriseSunset)
    function getNextSunriseSunset(settings as DeviceSettings) as Array<Number or String or Boolean> {
		if (!_successfulCalculation) {
			return [-1, true];
		}

		var clockTime = System.getClockTime();
    	_hour = clockTime.hour;
    	_min = clockTime.min;

    	var currentTime = _hour + _min / 60.0;
    	if (currentTime < _sunrise || currentTime > _sunset) {
    		return [formatHoursToTimeString(_sunrise, settings), true];
    	} else {
    		return [formatHoursToTimeString(_sunset, settings), false];
    	}
    }

	//! Get next sunrise time
	//! @param settings DeviceSettings
	//! @return array of the next sunrise in string and true (as it is sunrise)
	(:sunriseSunset)
    function getNextSunrise(settings as DeviceSettings) as Array<Number or String or Boolean> {
    	return [formatHoursToTimeString(_sunrise, settings), true];
    }

	//! Get next sunset time
	//! @param settings DeviceSettings
	//! @return array of the next sunset in string and false (as it is not sunrise)
	(:sunriseSunset)
    function getNextSunset(settings as DeviceSettings) as Array<Number or String or Boolean> {
    	return [formatHoursToTimeString(_sunset, settings), false];
    }
    
	//! Format sunrise/sunset time
	//! @param time the hour in Float
	//! @param settings DeviceSettings
	//! @return formatted sunrise or sunset in string
	(:sunriseSunset)
    private function formatHoursToTimeString(time as Float, settings as DeviceSettings) as String {
    	var hour = Math.floor(time);
    	var min = (time - hour) * 100 * 0.6;
    	if (!settings.is24Hour) {
            if (hour > 12) {
                hour -= 12;
            }
    	}

        return Lang.format("$1$:$2$", [hour.format("%02d"), min.format("%02d")]);	
    }
    
	//! Draw arcs for day and night and also the sun's current position
	//! only for round screens and only for outer circle
	//! @param dc as Device Content
	//! @param settings DeviceSettings
	(:roundShape)
    function drawSunriseSunsetArc(dc as Dc, settings as DeviceSettings) as Void {
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

		// Split the Sunrise Sunset round drawing to 24 parts
		if (dataBarSplit == DATABAR_SPLIT_ALL || dataBarSplit == DATABAR_SPLIT_OUTER_LEFT_TOP) {
			dc.setPenWidth(width + 1);
			dc.setColor(themeColors[:backgroundColor], themeColors[:backgroundColor]);
			for (var i = 360; i > 0; i -= 15) {
				dc.drawArc(
					arcX, 
					arcY, 
					radius, 
					Graphics.ARC_CLOCKWISE, 
					i+1, 
					i
				);
			}
		}
    	
		// On Bicolor themes the suncolor should change according to the daytime
		if (theme % 5 != 2) {
			color = themeColors[:isColorful] ? Graphics.COLOR_RED : themeColors[:foregroundSecondaryColor]; //sun color
		} else {
			color = getNextSunriseSunset(settings)[1] ? themeColors[:foregroundPrimaryColor] : themeColors[:backgroundColor]; //sun color
		}
    	
    	dc.setColor(color, themeColors[:backgroundColor]);
    	
		var clockTime = System.getClockTime();
    	_hour = clockTime.hour;
    	_min = clockTime.min;
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
	//! https://gml.noaa.gov/grad/solcalc/calcdetails.html
	//! Astronomical Algorithms by Jean Meeus - http://www.agopax.it/Libri_astronomia/pdf/Astronomical%20Algorithms.pdf
	//! @return boolean value if the calculation is successful or not
	(:sunriseSunset)
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
    	var timeZoneOffset = clockTime.timeZoneOffset / 3600; // Timezone offset in hour
    	
		var today = new Time.Moment(Time.today().value());
		var todayFrom1900 = 25571 + today.value() / 86400; // in days: (60 / 60 / 24) = 86400
		var julianDay = 2415018.5 + todayFrom1900 - timeZoneOffset / 24; // in days
		var julianCentury = (julianDay - 2451545) / 36525;
		
		var geomMeanLongSun = (280.46646 + julianCentury * (36000.76983 + julianCentury * 0.0003032));
		var geomMeanLongSunDecimal = geomMeanLongSun - Math.floor(geomMeanLongSun);
		geomMeanLongSun = (geomMeanLongSun.toNumber() % 360) + geomMeanLongSunDecimal; // degree
		var geomMeanAnomSun = 357.52911 + julianCentury * (35999.05029 - 0.0001537 * julianCentury); // degree
		var eccentEarthOrbit = 0.016708634 - julianCentury * (0.000042037 + 0.0000001267 * julianCentury);
		
		var sunEqOfCtr = Math.sin(Math.toRadians(geomMeanAnomSun)) * (1.914602 - julianCentury * (0.004817 + 0.000014 * julianCentury)) +
			Math.sin(Math.toRadians(2 * geomMeanAnomSun)) * (0.019993 - 0.000101 * julianCentury) + 
			Math.sin(Math.toRadians(3 * geomMeanAnomSun)) * 0.000289;
		var sunTrueLong = geomMeanLongSun + sunEqOfCtr; // degree

		var sunAppLong = sunTrueLong - 0.00569 - 0.00478 * Math.sin(Math.toRadians(125.04 - 1934.136 * julianCentury)); // degree
		var meanObliqEcliptic = 23 + (26 + ((21.448 - julianCentury * (46.815 + julianCentury * (0.00059 - julianCentury * 0.001813)))) / 60) / 60; // degree
		var obliqCorr = meanObliqEcliptic + 0.00256 * Math.cos(Math.toRadians(125.04 - 1934.136 * julianCentury)); // degree

		var sunDeclin = Math.toDegrees(Math.asin(Math.sin(Math.toRadians(obliqCorr)) * Math.sin(Math.toRadians(sunAppLong)))); // degree
		var varY = Math.tan(Math.toRadians(obliqCorr / 2)) * Math.tan(Math.toRadians(obliqCorr / 2));
		var eqOfTime = 4 * Math.toDegrees(varY * Math.sin(2 * Math.toRadians(geomMeanLongSun)) - 2 * eccentEarthOrbit * Math.sin(Math.toRadians(geomMeanAnomSun)) +
			4 * eccentEarthOrbit * varY * Math.sin(Math.toRadians(geomMeanAnomSun)) * Math.cos(2 * Math.toRadians(geomMeanLongSun)) -
			0.5 * varY * varY * Math.sin(4 * Math.toRadians(geomMeanLongSun)) - 1.25 * eccentEarthOrbit * eccentEarthOrbit * Math.sin(2 * Math.toRadians(geomMeanAnomSun))); // minutes

		var haSunrise = Math.toDegrees(Math.acos(Math.cos(Math.toRadians(90.833)) / (Math.cos(Math.toRadians(latitude)) * Math.cos(Math.toRadians(sunDeclin))) - 
    		Math.tan(Math.toRadians(latitude)) * Math.tan(Math.toRadians(sunDeclin)))); // degree
		var solarNoon = (720 - 4 * longitude - eqOfTime + timeZoneOffset * 60) / 1440; // LST = Local Sidereal Time
		// The daylight savings time (dst) not needed, timeZoneOffset is correct w/out dst

		_sunrise = (solarNoon - haSunrise * 4 / 1440) * 24; // hour
		_sunset = (solarNoon + haSunrise * 4 / 1440) * 24; // hour

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
	(:sunriseSunset)
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
			if (locationLat == null || locationLng == null) {
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
    
}