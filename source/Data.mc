import Toybox.System;
import Toybox.ActivityMonitor;
import Toybox.UserProfile;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;
import Toybox.Graphics;

class Data {

	private var _info as ActivityMonitor.Info;
	private var _userProfile as UserProfile.Profile;
	private var _deviceSettings as System.DeviceSettings;
	
	private var _errorDisplay = "--";
	
	//! Constructor
	//! @param settings DeviceSettings
    function initialize(settings as DeviceSettings) {
		refreshData(settings);
    }

	// Refresh the actual data
	//! @param settings DeviceSettings
	function refreshData(settings as DeviceSettings) as Void {
        _info = ActivityMonitor.getInfo();
        _userProfile = UserProfile.getProfile();
        _deviceSettings = settings;
	}
    
	//! Get the selected data in dataField or dataBar
	//! @param selectedType selected data type
	//! @return values dictionary with the data values and settings
    function getDataForDataField(selectedType as Integer) {
		var values = {
			:currentData => 0,
			:displayData => _errorDisplay,
			:dataMaxValue => 0,
			:iconText => " ",
			:iconColor => themeColors[:foregroundPrimaryColor],
			:barColor => themeColors[:foregroundPrimaryColor],
			:valid => true
		};

		if (selectedType != null) {
			switch(selectedType) {
				case DATA_STEPS:
					var steps = getSteps();
					values[:currentData] = steps[0];
					values[:displayData] = values[:currentData] == -1 ? _errorDisplay : values[:currentData].toString();
					values[:dataMaxValue] = steps[1];
					values[:iconText] = "B";
					values[:iconColor] = Graphics.COLOR_BLUE;
					values[:barColor] = Graphics.COLOR_BLUE;
					break;
				case DATA_BATTERY:
					var battery = getBatteryStat();
					values[:currentData] = battery[0];
					values[:displayData] = values[:currentData] == -1 ? _errorDisplay : values[:currentData].toNumber().toString() + "%";
					values[:dataMaxValue] = battery[1];
					values[:iconText] = "D";
					values[:iconColor] = Graphics.COLOR_YELLOW;
					values[:barColor] = values[:currentData] > 20.0 ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
					break;
				case DATA_HEARTRATE:
					var heartRate = getCurrentHeartRate();
					values[:displayData] = heartRate == -1 ? _errorDisplay : heartRate.toString();				
					values[:iconText] = "A";
					values[:iconColor] = Graphics.COLOR_RED;
					break;
				case DATA_CALORIES:
					var calories = getCalories();
					values[:currentData] = calories[0];
					values[:displayData] = values[:currentData] == -1 ? _errorDisplay : values[:currentData].toString();
					values[:dataMaxValue] = calories[1];
					values[:iconText] = "C";
					values[:iconColor] = Graphics.COLOR_ORANGE;
					values[:barColor] = Graphics.COLOR_ORANGE;
					break;
				case DATA_FLOORS_CLIMBED:
					var floorsClimbed = getFloorsClimbed();
					values[:currentData] = floorsClimbed[0];
					values[:displayData] = values[:currentData] == -1 ? _errorDisplay : values[:currentData].toString();
					values[:dataMaxValue] = floorsClimbed[1];
					values[:iconText] = "G";
					values[:iconColor] = Graphics.COLOR_PURPLE;
					values[:barColor] = Graphics.COLOR_PURPLE;
					break;
				case DATA_ACTIVE_MINUTES_WEEK:
					var activeMinutesWeek = getActiveMinutesWeek();
					values[:currentData] = activeMinutesWeek[0];
					values[:displayData] = values[:currentData] == -1 ? _errorDisplay : values[:currentData].toString();
					values[:dataMaxValue] = activeMinutesWeek[1];
					values[:iconText] = "H";
					values[:iconColor] = Graphics.COLOR_YELLOW;
					values[:barColor] = Graphics.COLOR_YELLOW;
					break;								
				case DATA_DISTANCE:
					var distance = getDistance();
					values[:displayData] = distance[0] == -1 ? _errorDisplay : distance[0].toString() + distance[1];
					values[:iconText] = "I";
					values[:iconColor] = Graphics.COLOR_LT_GRAY;
					break;	
				case DATA_WEATHER:
					var weather = getCurrentWeather();
					values[:displayData] = weather[0] == -1 ? _errorDisplay : weather[0].toString() + "º";  //unicode 186, \u00BA : real degree icon: ° unicode 176;
					values[:iconText] = weather[1];
					values[:iconColor] = Graphics.COLOR_BLUE;
					break;
				case DATA_DEVICE_INDICATORS:
					var deviceIndicators = getDeviceIndicators();
					values[:displayData] = deviceIndicators.equals("") ? _errorDisplay : "";
					values[:iconText] = deviceIndicators;
					values[:iconColor] = Graphics.COLOR_PINK;
					break;								
				case DATA_MOVEBAR:
					var moveBarLevel = getMoveBarLevel();
					values[:currentData] = moveBarLevel[0] == 0 ? 0 : moveBarLevel[0] + 3;
					values[:displayData] = moveBarLevel[0] == -1 ? _errorDisplay : "";
					values[:dataMaxValue] = ActivityMonitor.MOVE_BAR_LEVEL_MAX + 3;
					values[:iconText] = moveBarLevel[1];
					values[:iconColor] = Graphics.COLOR_GREEN;
					values[:barColor] = Graphics.COLOR_GREEN;
					break;
				case DATA_REMAINING_TIME:
					var remainingTime = getRemainingTime();
					values[:displayData] = remainingTime == -1 ? _errorDisplay : remainingTime.toString();
					values[:iconText] = "T";
					values[:iconColor] = Graphics.COLOR_BLUE;
					break;
				case DATA_METERS_CLIMBED:
					var metersClimbed = getMetersClimbed();
					values[:displayData] = metersClimbed == -1 ? _errorDisplay : metersClimbed.toString();
					values[:iconText] = "X";
					values[:iconColor] = Graphics.COLOR_LT_GRAY;
					break;
				case DATA_SUNRISE_SUNSET:
					var nextSunriseSunset = getNextSunriseSunsetTime();
					values[:displayData] = nextSunriseSunset[0] == -1 ? _errorDisplay : nextSunriseSunset[0];
					values[:iconText] = nextSunriseSunset[1] ? "E" : "F";
					values[:iconColor] = Graphics.COLOR_YELLOW;
					break;						
				case DATA_OFF:
					values[:valid] = false;
					break;						
			}
		}

		return values;
	}
    
	//! get the current calories burned this day
	//! @return Array of burned calories and calories goal for the current day in kCal
    private function getCalories() as Array<Number> {
    	var calories = _info.calories != null ? _info.calories : -1;
    	var caloriesGoal = totalCaloriesGoal;

    	// Caloriesgoal calculation has no meaning if no calorie data was collected or user selected a reasonable range
    	if (calories != -1 && (caloriesGoal == null || caloriesGoal < 1 || caloriesGoal > 10000)) {
	    	var weight = _userProfile.weight; // g
	    	var height = _userProfile.height; // cm
	    	var birthYear = _userProfile.birthYear; // year
	    	var gender = _userProfile.gender; // 0 female, 1 male
	    	var activityClass = _userProfile.activityClass; // 0-100
    	
    		if (weight != null && height != null && birthYear != null && gender != null && activityClass != null) {
	    		// The Harris-Benedict formula
	    		// https://en.wikipedia.org/wiki/Harris%E2%80%93Benedict_equation
	    		// https://www.healthline.com/health/fitness-exercise/how-many-calories-do-i-burn-a-day#calories-burned
	    		var bmr = 0;
	    		var age = Gregorian.info(Time.now(), Time.FORMAT_SHORT).year - birthYear; // year
	    		weight /= 1000; //kg
	    		if (gender == UserProfile.GENDER_FEMALE) {
	    			bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
	    		} else {
	    			bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
	    		}
	    		
	    		var activityLevel = 1.2 + 0.007 * activityClass;     		
    			caloriesGoal = bmr * activityLevel;
    		}
    	}

    	return [calories, caloriesGoal];
    }
    
	//! get distance traveled this day
	//! @return Array of distance traveled in km or mi, and this unit according to user setting
    private function getDistance() as Array<Number or String> {
    	var distance = new [2];
    	if (_info.distance == null) {
    		return [-1, ""];
    	}
    	
    	if (_deviceSettings.distanceUnits == System.UNIT_METRIC) {
    		distance[0] = _info.distance / 100000.0;
    		distance[1] = "K";
    	} else if (_deviceSettings.distanceUnits == System.UNIT_STATUTE) {
    		distance[0] = _info.distance / 100000.0 * 0.621371192;
    		distance[1] = "M";
    	}
    	
		// convert to specified decimal places (0,1,2)
    	if (distance[0] >= 100.0) {
    		distance[0] = distance[0].toNumber(); 
    	} else if (distance[0] < 100.0 && distance[0] >= 10) {
    		distance[0] = distance[0].format("%.1f");
    	} else {
    		distance[0] = distance[0].format("%.2f");
    	}

    	return distance;
    }
    
	//! get the current HR
	//! @return current heart rate, or from last reasonable sample, or resting HR
    private function getCurrentHeartRate() as Number {
		var activityInfo = Activity.getActivityInfo();
    	var heartRate = activityInfo.currentHeartRate;
		
		if (heartRate == null) {
	    	var sample = null;
	    	
	    	// Check HR history of the last specified (5) number of samples
	    	if (ActivityMonitor has :getHeartRateHistory) {
		    	var numberOfSamples = 5;
				var hrIterator = ActivityMonitor.getHeartRateHistory(numberOfSamples, true);
			    
			    for (var i = 0; i < numberOfSamples; i++) {
			    	if (sample == null || sample.heartRate == ActivityMonitor.INVALID_HR_SAMPLE) {
			    		sample = hrIterator.next();
			    	} else {
			    		break;
			    	}
			    }
			}
		    
		    // if not valid, give back the resting HR
		    if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
	    		heartRate = sample.heartRate;
	    	} else {
	    		heartRate = _userProfile.restingHeartRate;
	    		if (heartRate == null) {
	    			heartRate = -1;
	    		}
	    	}
		}
		
    	return heartRate;
	}
    
	//! get battery status
    //! @return array of current battery status and maximum battery status
    private function getBatteryStat() as Array<Number> {
		var systemStats = System.getSystemStats();
    	return [systemStats.battery, 100];
    }

	//! get current steps for current day
    //! @return array of current steps taken and steps goal    
    private function getSteps() as Array<Number> {
    	var steps = _info.steps != null ? _info.steps : -1;
    	var stepGoal = _info.stepGoal != null ? _info.stepGoal : 8000;
    	return [steps, stepGoal];
    }
    
    //API 2.1.0
	//! get active minutes for current week
    //! @return array of active minutes done and active minutes goal  
    private function getActiveMinutesWeek() as Array<Number> {
    	if (_info has :activeMinutesWeek) {
	    	var activeMinutesWeek = _info.activeMinutesWeek != null ? _info.activeMinutesWeek.total : -1;
	    	var activeMinutesWeekGoal = _info.activeMinutesWeekGoal != null ? _info.activeMinutesWeekGoal : 300; // if active minutes goal is not set, 300 is default
	   		return [activeMinutesWeek, activeMinutesWeekGoal];
   		} else {
   			return [-1, 0];
   		}
    }
    
    //API 2.1.0
	//! get floors climbed for current day
    //! @return array of floors climbed and floors climbed goal
	(:floorsClimbed)
    private function getFloorsClimbed () as Array<Number or String> {
    	if (_info has :floorsClimbed) {
	    	var floorsClimbed  = _info.floorsClimbed  != null ? _info.floorsClimbed  : -1;
	    	var floorsClimbedGoal = _info.floorsClimbedGoal != null ? _info.floorsClimbedGoal : 10; // if floorsClimbedGoal is not set, 10 is my default
	   		return [floorsClimbed , floorsClimbedGoal];
   		} else {
   			return [-1, 0];
   		}
    }
    
    // API 3.2.0
	//! get current temperature and condition
    //! @return array of temperature according to device settings and condition for icon
	(:weather)
    private function getCurrentWeather() as Array<Number or String> {
    	if (Application has :Weather) {
    		var currentCondition = Weather.getCurrentConditions();
			if (currentCondition != null) {
				var condition = " ";
				var temperature = currentCondition.temperature != null ? currentCondition.temperature : -1;
				
				if (temperature != -1) {
					if (_deviceSettings.temperatureUnits == System.UNIT_STATUTE) {
						temperature = ((temperature * (9.0 / 5)) + 32).toNumber();
					}
					
					condition = getWeatherIcon(currentCondition.condition);
				}
				
				return [temperature, condition];
			}
    	}

    	return [-1, "R"];
    }

	//! Get weather icon
	//! @param condition current weather condition
	//! return icon Text (a letter) for current icon
	(:weather)
	private function getWeatherIcon(condition) {
    	var iconText = "";
    	switch (condition) {
    		case Weather.CONDITION_CLEAR:
			case Weather.CONDITION_MOSTLY_CLEAR:
			case Weather.CONDITION_FAIR:
    			iconText = "K";
    			break;
			case Weather.CONDITION_PARTLY_CLEAR:
			case Weather.CONDITION_PARTLY_CLOUDY:
			case Weather.CONDITION_MOSTLY_CLOUDY:
			case Weather.CONDITION_WINDY:
			case Weather.CONDITION_THIN_CLOUDS:			
    			iconText = "L";
    			break;
			case Weather.CONDITION_HAZY:
			case Weather.CONDITION_FOG:
			case Weather.CONDITION_CLOUDY:
			case Weather.CONDITION_MIST:
			case Weather.CONDITION_DUST:
			case Weather.CONDITION_HAZE:
    			iconText = "M";
    			break;
			case Weather.CONDITION_LIGHT_RAIN:
			case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:
			case Weather.CONDITION_CHANCE_OF_SHOWERS:
			case Weather.CONDITION_SCATTERED_SHOWERS:
			case Weather.CONDITION_DRIZZLE:
    			iconText = "N";
    			break;
			case Weather.CONDITION_RAIN:
			case Weather.CONDITION_UNKNOWN_PRECIPITATION:
			case Weather.CONDITION_HEAVY_RAIN:
			case Weather.CONDITION_SHOWERS:
			case Weather.CONDITION_LIGHT_SHOWERS:
			case Weather.CONDITION_HEAVY_SHOWERS:
			case Weather.CONDITION_FLURRIES:		
    			iconText = "O";
    			break;
			case Weather.CONDITION_THUNDERSTORMS:
			case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
			case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:	
    			iconText = "P";
    			break;
			case Weather.CONDITION_SNOW:
			case Weather.CONDITION_WINTRY_MIX:
			case Weather.CONDITION_HAIL:
			case Weather.CONDITION_LIGHT_SNOW:
			case Weather.CONDITION_HEAVY_SNOW:
			case Weather.CONDITION_LIGHT_RAIN_SNOW:
			case Weather.CONDITION_HEAVY_RAIN_SNOW:			
			case Weather.CONDITION_RAIN_SNOW:			
			case Weather.CONDITION_CHANCE_OF_SNOW:
			case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:
			case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW:
			case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW:			
			case Weather.CONDITION_FREEZING_RAIN:
			case Weather.CONDITION_SLEET:
			case Weather.CONDITION_ICE_SNOW:
    			iconText = "Q";
    			break;
			case Weather.CONDITION_SANDSTORM:
			case Weather.CONDITION_VOLCANIC_ASH:
			case Weather.CONDITION_TORNADO:
			case Weather.CONDITION_SMOKE:
			case Weather.CONDITION_ICE:
			case Weather.CONDITION_HURRICANE:
			case Weather.CONDITION_TROPICAL_STORM:			
			case Weather.CONDITION_SAND:
			case Weather.CONDITION_SQUALL:
    			iconText = "R";
    			break;
			case Weather.CONDITION_UNKNOWN:
			default:
    			iconText = "R";
    			break;
    	}
    	
    	return iconText;		
    }

   	//! Get the device indicators
	//! @return string for icons
	(:deviceIndicators)
    private function getDeviceIndicators() as String {
		_deviceSettings = System.getDeviceSettings();

		var deviceIndicators = "";
		if (_deviceSettings.notificationCount != null && _deviceSettings.notificationCount >= 1) {
			deviceIndicators = deviceIndicators + "J";
		}

		if (_deviceSettings.alarmCount != null && _deviceSettings.alarmCount >= 1) {
			deviceIndicators = deviceIndicators + "S";
		}

		if (_deviceSettings has :doNotDisturb && _deviceSettings.doNotDisturb) {
			deviceIndicators = deviceIndicators + "Y";
		}

		if (_deviceSettings.phoneConnected != null && _deviceSettings.phoneConnected) {
			deviceIndicators = deviceIndicators + "Z";
		}

		return deviceIndicators;
	}

	//! Get the moveBar level
	//! @return moveBar level and icon
	(:moveBar)
    private function getMoveBarLevel() as Array<Number or String> {
    	var moveBarLevel = _info.moveBarLevel  != null ? _info.moveBarLevel  : -1;
		var moveBarIcon = "U";
		if (moveBarLevel > ActivityMonitor.MOVE_BAR_LEVEL_MIN) {
			var extraLevels = moveBarLevel - 1;
			moveBarIcon = "V";
			if (extraLevels > 0) {
				for (var i = 0; i < extraLevels; i++) {
					moveBarIcon += "W";
				}
			}
		}

		return [moveBarLevel, moveBarIcon];
    }

	//! Get the remaining day to a date
	//! @return remaining day
	(:remainingTime)
    private function getRemainingTime() as Number {
		var selectedDate = new Time.Moment(selectedToDate);
		var today = new Time.Moment(Time.today().value());

		if (selectedDate.value() < today.value()) {
			return -1;
		}

		var timeDifference = selectedDate.subtract(today).value(); // in seconds
		timeDifference = timeDifference / 60 / 60 / 24;

		return timeDifference.toNumber();
    }

    //API 2.1.0
	//! get meters climbed for current day
    //! @return meters climbed
	(:floorsClimbed)
    private function getMetersClimbed () as Number {
		if (_info has :floorsClimbed) {
			return _info.metersClimbed != null ? _info.metersClimbed.toNumber()  : -1;
		} else {
			return -1;
		}
    }

	//! Get the next sunrise or sunset
	//! @return the next sunrise or sunset according to which is the next
	(:sunriseSunset)	
    private function getNextSunriseSunsetTime() as String {
    	return sunriseSunset.getNextSunriseSunset(_deviceSettings);
	}
}
