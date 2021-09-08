import Toybox.System;
import Toybox.ActivityMonitor;
import Toybox.UserProfile;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;
import Toybox.Graphics;

class Data {

	private var _info as ActivityMonitor.Info;
	private var _activityInfo as Activity.Info;
	private var _systemStats as System.Stats;
	private var _userProfile as UserProfile.Profile;
	private var _deviceSettings as System.DeviceSettings;

	private var _sunriseSunset as SunriseSunset;
	
	private var _errorDisplay = "-";
	
	//! Constructor
    function initialize() {
		refreshData();
    }

	// Refresh the actual data
	function refreshData() as Void {
        _info = ActivityMonitor.getInfo();
        _activityInfo = Activity.getActivityInfo();
        _systemStats = System.getSystemStats();
        _userProfile = UserProfile.getProfile();
        _deviceSettings = System.getDeviceSettings();
	}
    
	//! Get the selected data in dataField or dataBar
	//! @param selectedType selected data type
	//! @return values dictionary with the data values and settings
    function getDataForDataField(selectedType) {
		var values = {
			:currentData => 0,
			:displayData => _errorDisplay,
			:dataMaxValue => 0,
			:iconText => " ",
			:iconColor => foregroundColor,
			:barColor => foregroundColor
		};

		switch(selectedType) {
			case DATA_STEPS:
				var steps = getSteps();
				values[:currentData] = steps[0];
				values[:displayData] = values[:currentData] == -1 ? _errorDisplay : values[:currentData].toString();
				values[:dataMaxValue] = steps[1];
				values[:iconText] = "B";
				values[:iconColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_BLUE;
				values[:barColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_BLUE;
				break;
			case DATA_BATTERY:
				var battery = getBatteryStat();
				values[:currentData] = battery[0];
				values[:displayData] = values[:currentData] == -1 ? _errorDisplay : values[:currentData].toNumber().toString() + "%";
				values[:dataMaxValue] = battery[1];
				values[:iconText] = "D";
				values[:iconColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_YELLOW;
				values[:barColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_GREEN;
				break;
			case DATA_HEARTRATE:
				var heartRate = getCurrentHeartRate();
				values[:displayData] = heartRate == -1 ? _errorDisplay : heartRate.toString();				
				values[:iconText] = "A";
				values[:iconColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_RED;
				break;
			case DATA_CALORIES:
				var calories = getCalories();
				values[:currentData] = calories[0];
				values[:displayData] = values[:currentData] == -1 ? _errorDisplay : values[:currentData].toString();
				values[:dataMaxValue] = calories[1];
				values[:iconText] = "C";
				values[:iconColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_ORANGE;
				values[:barColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_ORANGE;
				break;
			case DATA_FLOORS_CLIMBED:
				var floorsClimbed = getFloorsClimbed();
				values[:currentData] = floorsClimbed[0];
				values[:displayData] = values[:currentData] == -1 ? _errorDisplay : values[:currentData].toString();
				values[:dataMaxValue] = floorsClimbed[1];
				values[:iconText] = "G";
				values[:iconColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_PURPLE;
				values[:barColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_PURPLE;
				break;
			case DATA_ACTIVE_MINUTES_WEEK:
				var activeMinutesWeek = getActiveMinutesWeek();
				values[:currentData] = activeMinutesWeek[0];
				values[:displayData] = values[:currentData] == -1 ? _errorDisplay : values[:currentData].toString();
				values[:dataMaxValue] = activeMinutesWeek[1];
				values[:iconText] = "H";
				values[:iconColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_YELLOW;
				values[:barColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_YELLOW;
				break;								
			case DATA_DISTANCE:
				var distance = getDistance();
				values[:displayData] = distance[0] == -1 ? _errorDisplay : distance[0].toString() + distance[1];
				values[:iconText] = "I";
				values[:iconColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_LT_GRAY;
				break;	
			case DATA_WEATHER:
				var weather = getCurrentWeather();
				values[:displayData] = weather[0] == -1 ? _errorDisplay : weather[0].toString() + "º";  //unicode 186, \u00BA : real degree icon: ° unicode 176;
				values[:iconText] = weather[1];
				values[:iconColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_DK_BLUE;
				break;
			case DATA_NOTIFICATION:
				var notificationCount = getNotificationCount();
				values[:displayData] = notificationCount == -1 ? _errorDisplay : notificationCount.toString();
				values[:iconText] = "J";
				values[:iconColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_PINK;
				break;				

			case DATA_SUNRISE_SUNSET:
				var nextSunriseSunset = getNextSunriseSunsetTime();
				values[:displayData] = nextSunriseSunset[0] == -1 ? _errorDisplay : nextSunriseSunset[0];
				values[:iconText] = nextSunriseSunset[1] ? "E" : "F";
				values[:iconColor] = dataIconsThemeColor ? foregroundColor : Graphics.COLOR_ORANGE;
				break;						
		}
		
		return values;
	}
    
	//! get the current calories burned this day
	//! @return Array of burned calories and calories goal for the current day in kCal
    private function getCalories() as Array<Number> {
    	var calories = _info.calories != null ? _info.calories : -1;
    	var caloriesGoal = totalCaloriesGoal;

    	// Caloriesgoal calculation has no meaning if no calorie data was collected or user selected a reasonable range
    	if (calories != -1 && (caloriesGoal == null || caloriesGoal < 1000 || caloriesGoal > 10000)) {
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
    		distance[1] = "k";
    	} else if (_deviceSettings.distanceUnits == System.UNIT_STATUTE) {
    		distance[0] = _info.distance / 100000.0 * 0.621371192;
    		distance[1] = "m";
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
    	var heartRate = _activityInfo.currentHeartRate;
		
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
    	return [_systemStats.battery, 100];
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
    private function getCurrentWeather() as Array<Number or String> {
    	if (Application has :Weather) {
    		var currentCondition = Weather.getCurrentConditions();
			if (currentCondition != null) {
				var condition = " ";
				var temperature = currentCondition.temperature != null ? currentCondition.temperature : -1;
				
				if (temperature != -1) {
					if (_deviceSettings.temperatureUnits == System.UNIT_STATUTE) {
						temperature = ((temperature * (9.0 / 5)) + 32).format("%.1f");
					}
					
					condition = getWeatherIcon(currentCondition.condition);
				}
				
				return [temperature, condition];
			}
    	}

    	return [-1, "O"];
    }

	//! Get weather icon
	//! @param condition current weather condition
	//! return icon Text (a letter) for current icon
	private function getWeatherIcon(condition) {
    	var iconText = "";
    	switch (condition) {
    		case Weather.CONDITION_CLEAR:
			case Weather.CONDITION_PARTLY_CLEAR:
			case Weather.CONDITION_MOSTLY_CLEAR:
			case Weather.CONDITION_FAIR:
    			iconText = "K";
    			break;
			case Weather.CONDITION_PARTLY_CLOUDY:
			case Weather.CONDITION_MOSTLY_CLOUDY:
			case Weather.CONDITION_WINDY:
			case Weather.CONDITION_HAZY:
			case Weather.CONDITION_FOG:
			case Weather.CONDITION_CLOUDY:
			case Weather.CONDITION_MIST:
			case Weather.CONDITION_DUST:
			case Weather.CONDITION_THIN_CLOUDS:			
			case Weather.CONDITION_HAZE:
    			iconText = "L";
    			break;							
			case Weather.CONDITION_RAIN:
			case Weather.CONDITION_THUNDERSTORMS:
			case Weather.CONDITION_SCATTERED_SHOWERS:
			case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
			case Weather.CONDITION_UNKNOWN_PRECIPITATION:
			case Weather.CONDITION_LIGHT_RAIN:
			case Weather.CONDITION_HEAVY_RAIN:
			case Weather.CONDITION_LIGHT_SHOWERS:
			case Weather.CONDITION_SHOWERS:
			case Weather.CONDITION_HEAVY_SHOWERS:
			case Weather.CONDITION_CHANCE_OF_SHOWERS:
			case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:		
			case Weather.CONDITION_DRIZZLE:
			case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:	
			case Weather.CONDITION_FLURRIES:		
    			iconText = "M";
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
    			iconText = "N";
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
    			iconText = "O";
    			break;
			case Weather.CONDITION_UNKNOWN:
			default:
    			iconText = " ";
    			break;
    	}
    	
    	return iconText;		
    }
    
	//! Get the notification count
	//! @return notification count
    private function getNotificationCount() as Number {
    	return _deviceSettings.notificationCount  != null ? _deviceSettings.notificationCount  : -1;
    }

	//! Get the next sunrise or sunset
	//! @return the next sunrise or sunset according to which is the next	
    private function getNextSunriseSunsetTime() as String {
		if (_sunriseSunset == null) {
			_sunriseSunset = new SunriseSunset();
		}
		
		var intervalToRefreshSunriseSunset = 30;
		if (System.getClockTime().min % intervalToRefreshSunriseSunset == 1) {
			_sunriseSunset.refreshSunsetSunrise();
		}
    	  
    	return _sunriseSunset.getNextSunriseSunset();
	}

	//! Check if the current time is the time of the next sunrise/sunset
	//! If it is the same, it should update on screen
	//! @return true if time equals the next sunrise/sunset
	private function currentSunriseSunsetIsDisplayed() as Boolean {
		var nextSunriseSunset = _sunriseSunset.getNextSunriseSunset()[0];
		
		var clockTime = System.getClockTime();
		var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        var currentTime = Lang.format("$1$:$2$", [hours.format("%02d"), clockTime.min.format("%02d")]);

		return nextSunriseSunset.equals(currentTime);
	}
}
