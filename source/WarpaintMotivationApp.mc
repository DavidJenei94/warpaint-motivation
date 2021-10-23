import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.WatchUi;
import Toybox.Background;
import Toybox.Time;
import Toybox.System;

// global variables
var myView as View;

var theme as Number;
var themeColors = {
    :foregroundPrimaryColor => 0xFFFFFF,
    :foregroundSecondaryColor => 0xFFFFFF,
    :backgroundColor => 0x000000,
    :isColorful => false
};

var displaySecond as Integer;
var militaryFormat as Boolean;

var selectedValueForDataFieldMiddle as Integer;
var selectedValueForDataFieldLeft as Integer;
var selectedValueForDataFieldRight as Integer;

var selectedToDate as Number;

var dataBarWidth as Integer; //DELETE/REPLACE to layout
var selectedValueForDataBarOuterLeftTop as Integer;
var selectedValueForDataBarInnerRightBottom as Integer;
var dataBarSplit as Integer;
var sunriseSunsetDrawingEnabled as Boolean;
var sunriseSunset as SunriseSunset;

var smallFont as Font;
var mediumFont as Font;
var largeFont as Font;
var iconFont as Font;

var totalCaloriesGoal as Number;

var motivationalQuote as String;
var motivationalQuoteProperty as String;
var motivationalQuoteChangeInterval as Number;
var motivationalQuoteArray = [];

// Store in storage/property
var locationLat as Float;
var locationLng as Float;

enum { 
    DATA_BATTERY,  //0 
    DATA_STEPS,
    DATA_HEARTRATE,
    DATA_CALORIES,
    DATA_SUNRISE_SUNSET,
    DATA_DISTANCE, //5
    DATA_FLOORS_CLIMBED,
    DATA_ACTIVE_MINUTES_WEEK,
    DATA_WEATHER,
    DATA_DEVICE_INDICATORS,
    // Deleted data field //10
    DATA_MOVEBAR = 11,
    DATA_REMAINING_TIME,
    DATA_METERS_CLIMBED,
    DATA_OFF = -1
}

enum { 
    DATABAR_OUTER_LEFT_TOP,
    DATABAR_INNER_RIGHT_BOTTOM
}

enum { 
    DATABAR_SPLIT_OFF,
    DATABAR_SPLIT_OUTER_LEFT_TOP,
    DATABAR_SPLIT_INNER_RIGHT_BOTTOM,
    DATABAR_SPLIT_ALL
}

(:background)
class WarpaintMotivationApp extends Application.AppBase {

    //! Constructor
    function initialize() {
        AppBase.initialize();

        // register for temporal event every X minutes (in X * 60)
        if (Toybox has :Background) {
        	Background.registerForTemporalEvent(new Time.Duration(60 * 60));
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
        setGlobalVariables();
        Theme.selectThemeColors();
        myView.loadFonts();
        
        return [ myView ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        setGlobalVariables();
        Theme.selectThemeColors();
        myView.loadFonts();
        myView.onSettingsChanged();
        // Change motivational quote when settings are changed 
        // with set the motivationalQuote to be null 
        // and forcing to set new motivational quote in View
        motivationalQuote = null;

        WatchUi.requestUpdate();
    }

    //! Set the motivational quote
    //! @param data the data from the web request
    (:background_method)
    function onBackgroundData(data) as Void {
		var apiData = data["motivationalQuote"];
        if (apiData instanceof Array) {
            motivationalQuoteArray.addAll(apiData);
        } else if (apiData instanceof String) {
			motivationalQuoteArray.add(apiData);
		}

        if (Toybox.Application has :Storage) {
            Storage.setValue("MotivationalQuoteArray", motivationalQuoteArray);
            Storage.setValue("MotivationalQuoteArraySize", motivationalQuoteArray.size());
        } else {
            getApp().setProperty("MotivationalQuoteArray", motivationalQuoteArray);
            getApp().setProperty("MotivationalQuoteArraySize", motivationalQuoteArray.size());
        }

		WatchUi.requestUpdate();
	}
	
    //! Get Service Delegate
    //! @return new ServiceDelegate for backkground service
    (:background_method)
	function getServiceDelegate() as Array<ServiceDelegate> {
		return [new BackgroundService()];
	}

    //! Set global variables (fonts are in the View)
    private function setGlobalVariables() as Void {
    	if (Toybox.Application has :Storage) {
            setGlobalVariablesWithStorage();
		} else {
            setGlobalVariablesWithoutStorage();
		}
    }

    //! Set global variables with storage enabled
    (:has_storage)
    private function setGlobalVariablesWithStorage() as void {
        theme = Properties.getValue("Theme");

        displaySecond = Properties.getValue("DisplaySecond");
        militaryFormat = Properties.getValue("UseMilitaryFormat");

        selectedValueForDataFieldMiddle = Properties.getValue("DataFieldMiddle");
        selectedValueForDataFieldLeft = Properties.getValue("DataFieldLeft");
        selectedValueForDataFieldRight = Properties.getValue("DataFieldRight");
        selectedValueForDataBarOuterLeftTop = Properties.getValue("DataBarOuterLeftTop");
        selectedValueForDataBarInnerRightBottom = Properties.getValue("DataBarInnerRightBottom");
        sunriseSunsetDrawingEnabled = Properties.getValue("SunriseSunsetDrawing");
        dataBarSplit = Properties.getValue("DataBarSplit");

        selectedToDate = Properties.getValue("RemainingTimeToDate");

        totalCaloriesGoal = Properties.getValue("CaloriesGoal");

        motivationalQuoteProperty = Properties.getValue("MotivationalQuoteProperty");
        motivationalQuoteChangeInterval = Properties.getValue("MotivationalQuoteChangeInterval");

        motivationalQuote = Storage.getValue("MotivationalQuote");
        var motivationalQuoteStoredArray = Storage.getValue("MotivationalQuoteArray");
        if (motivationalQuoteStoredArray != null) {
            Storage.setValue("MotivationalQuoteArray", motivationalQuoteStoredArray);
        } else {
            Storage.setValue("MotivationalQuoteArray", motivationalQuoteArray);
        }
        Storage.setValue("MotivationalQuoteArraySize", motivationalQuoteArray.size());

        locationLat = Storage.getValue("LastLocationLat");
        locationLng = Storage.getValue("LastLocationLng");
    }

    //! Set global variables without storage enabled
    (:has_no_storage)
    private function setGlobalVariablesWithoutStorage() as void {
        theme = getApp().getProperty("Theme");

        displaySecond = getApp().getProperty("DisplaySecond");
        militaryFormat = getApp().getProperty("UseMilitaryFormat");

        selectedValueForDataFieldMiddle = getApp().getProperty("DataFieldMiddle");
        selectedValueForDataFieldLeft = getApp().getProperty("DataFieldLeft");
        selectedValueForDataFieldRight = getApp().getProperty("DataFieldRight");
        selectedValueForDataBarOuterLeftTop = getApp().getProperty("DataBarOuterLeftTop");
        selectedValueForDataBarInnerRightBottom = getApp().getProperty("DataBarInnerRightBottom");
        sunriseSunsetDrawingEnabled = getApp().getProperty("SunriseSunsetDrawing");
        dataBarSplit = getApp().getProperty("DataBarSplit");

        selectedToDate = getApp().getProperty("RemainingTimeToDate");

        totalCaloriesGoal = getApp().getProperty("CaloriesGoal");

        motivationalQuoteProperty = getApp().getProperty("MotivationalQuoteProperty");
        motivationalQuoteChangeInterval = getApp().getProperty("MotivationalQuoteChangeInterval");

        motivationalQuote = getApp().getProperty("MotivationalQuote");
        var motivationalQuoteStoredArray = getApp().getProperty("MotivationalQuoteArray");
        if (motivationalQuoteStoredArray != null) {
            getApp().setProperty("MotivationalQuoteArray", motivationalQuoteStoredArray);
        } else {
            getApp().setProperty("MotivationalQuoteArray", motivationalQuoteArray);
        }
        getApp().setProperty("MotivationalQuoteArraySize", motivationalQuoteArray.size());

        locationLat = getApp().getProperty("LastLocationLat");
        locationLng = getApp().getProperty("LastLocationLng");
    }
}

//! Give back App
//! @return App
function getApp() as WarpaintMotivationApp {
    return Application.getApp() as WarpaintMotivationApp;
}
