import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Background;
import Toybox.Time;
import Toybox.Activity;

// global variables
var myView as View;

var theme as Number;
var dataIconsThemeColor as Boolean;
var foregroundColor as Number;
var backgroundColor as Number;

var updatingSecondsInLowPowerMode as Boolean;
var militaryFormat as Boolean;

var selectedValueForDataFieldMiddle as Integer;
var selectedValueForDataFieldLeft as Integer;
var selectedValueForDataFieldRight as Integer;

var dataBarWidth as Integer;
var unfilledDataBarColor = 0x555555; // Graphics.COLOR_DK_GRAY;
var selectedValueForDataBarOuterLeftTop as Integer;
var selectedValueForDataBarInnerRightBottom as Integer;

var smallFont as Font;
var mediumFont as Font;
var largeFont as Font;
var iconFont as Font;

var totalCaloriesGoal as Number;

var motivationalQuote as String;

var locationLat = null;
var locationLng = null;

enum { 
    THEME_WHITE_DARK,
    THEME_BLUE_DARK,
    THEME_RED_DARK,
    THEME_GREEN_DARK,
    THEME_BLACK_LIGHT
}

enum { 
    DATA_BATTERY,   
    DATA_STEPS,
    DATA_HEARTRATE,
    DATA_CALORIES,
    DATA_SUNRISE_SUNSET,
    DATA_DISTANCE,
    DATA_FLOORS_CLIMBED,
    DATA_ACTIVE_MINUTES_WEEK,
    DATA_WEATHER,
    DATA_NOTIFICATION
}

enum { 
    DATABAR_OUTER_LEFT_TOP,
    DATABAR_INNER_RIGHT_BOTTOM
}

(:background)
class WarpaintMotivationApp extends Application.AppBase {

    //! Constructor
    function initialize() {
        AppBase.initialize();

        // register for temporal event every 5 minutes
        if (Toybox has :Background) {
        	Background.registerForTemporalEvent(new Time.Duration(5 * 60));
    	}
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
    	myView = new WarpaintMotivationView();
    	onSettingsChanged();
        return [ myView ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        setGlobalVariables();
        setCoordinates();
        myView.selectThemeColors();
        myView.loadFonts();    
        WatchUi.requestUpdate();
    }

    //! Set the motivational quote
    function onBackgroundData(data) as Void {
		var apiData = data["motivationalQuote"];
		if (apiData instanceof String) {
			motivationalQuote = apiData;		
		} else if (apiData instanceof Number) {
			motivationalQuote = "HTTP error number: " + apiData;
		} else {
			motivationalQuote = "Unknown error. Please contact developer.";
		}

		if (Toybox.Application has :Storage) {
			Properties.setValue("MotivationalQuote", motivationalQuote);
		} else {
			getApp().setProperty("MotivationalQuote", motivationalQuote);
		}
		WatchUi.requestUpdate();
	}
	
    //! Get Service Delegate
    //! @return new ServiceDelegate for backkground service
	function getServiceDelegate() as Array<ServiceDelegate> {
		return [new BackgroundService()];
	}

    //! Set global variables (fonts are in the View)
    private function setGlobalVariables() as Void {
    	if (Toybox.Application has :Storage) {
		    theme = Properties.getValue("Theme");
            dataIconsThemeColor = Properties.getValue("ThemeDataIconsColor");

            updatingSecondsInLowPowerMode = Properties.getValue("UpdateSecondInLowPowerMode");
            militaryFormat = Properties.getValue("UseMilitaryFormat");

            dataBarWidth = Properties.getValue("DataBarWidth");
            selectedValueForDataFieldMiddle = Properties.getValue("DataFieldMiddle");
			selectedValueForDataFieldLeft = Properties.getValue("DataFieldLeft");
			selectedValueForDataFieldRight = Properties.getValue("DataFieldRight");
            selectedValueForDataBarOuterLeftTop = Properties.getValue("DataBarOuterLeftTop");
			selectedValueForDataBarInnerRightBottom = Properties.getValue("DataBarInnerRightBottom");

            motivationalQuote = Properties.getValue("MotivationalQuote");
		} else {
		    theme = getApp().getProperty("Theme");
            dataIconsThemeColor = getApp().getProperty("ThemeDataIconsColor");

            updatingSecondsInLowPowerMode = getApp().getProperty("UpdateSecondInLowPowerMode");
            militaryFormat = getApp().getProperty("UseMilitaryFormat");

            dataBarWidth = getApp().getProperty("DataBarWidth");
		    selectedValueForDataFieldMiddle = getApp().getProperty("DataFieldMiddle");
			selectedValueForDataFieldLeft = getApp().getProperty("DataFieldLeft");
			selectedValueForDataFieldRight = getApp().getProperty("DataFieldRight");
            selectedValueForDataBarOuterLeftTop = getApp().getProperty("DataBarOuterLeftTop");
			selectedValueForDataBarInnerRightBottom = getApp().getProperty("DataBarInnerRightBottom");

            motivationalQuote = getApp().getProperty("MotivationalQuote");
		}
    }

    //! Set coordinates for sunrise sunset calculation and store it
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

//! Give back App
//! @return App
function getApp() as WarpaintMotivationApp {
    return Application.getApp() as WarpaintMotivationApp;
}
