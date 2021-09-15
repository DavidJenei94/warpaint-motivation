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
var foregroundColor as Number;
var backgroundColor as Number;
var foregroundTriColor as Number;
var isColorful as Boolean;

var updatingSecondsInLowPowerMode as Boolean;
var militaryFormat as Boolean;

var selectedValueForDataFieldMiddle as Integer;
var selectedValueForDataFieldLeft as Integer;
var selectedValueForDataFieldRight as Integer;

var dataBarWidth as Integer;
var unfilledDataBarAsBGColor as Boolean;
var unfilledDataBarColor as Number;
var selectedValueForDataBarOuterLeftTop as Integer;
var selectedValueForDataBarInnerRightBottom as Integer;

var smallFont as Font;
var mediumFont as Font;
var largeFont as Font;
var iconFont as Font;

var totalCaloriesGoal as Number;

var motivationalQuote as String;
var motivationalQuoteProperty as String;
var motivationalQuoteChangeInterval as Number;
var motivationalQuoteArray = [];
var firstLineWidthPercent as Number;
var secondLineWidthPercent as Number;
var thirdLineWidthPercent as Number;

// Store in storage/property
var locationLat = null;
var locationLng = null;

enum { 
    THEME_WHITE_DARK_COLORFUL,
    THEME_WHITE_DARK_BICOLOR,
    THEME_WHITE_DARK_TRICOLOR,
    THEME_BLACK_LIGHT_COLORFUL,
    THEME_BLACK_LIGHT_BIICOLOR,
    THEME_BLACK_LIGHT_TRICOLOR,
    THEME_GRAY_DARK_COLORFUL,
    THEME_GRAY_DARK_BICOLOR,
    THEME_GRAY_DARK_TRICOLOR,
    THEME_GRAY_LIGHT_COLORFUL,
    THEME_GRAY_LIGHT_BICOLOR,
    THEME_GRAY_LIGHT_TRICOLOR,
    THEME_RED_DARK_COLORFUL,
    THEME_RED_DARK_BICOLOR,
    THEME_RED_DARK_TRICOLOR,
    THEME_RED_LIGHT_COLORFUL,
    THEME_RED_LIGHT_BICOLOR,
    THEME_RED_LIGHT_TRICOLOR,
    THEME_BLUE_DARK_COLORFUL,
    THEME_BLUE_DARK_BICOLOR,
    THEME_BLUE_DARK_TRICOLOR,
    THEME_BLUE_LIGHT_COLORFUL,
    THEME_BLUE_LIGHT_BICOLOR,
    THEME_BLUE_LIGHT_TRICOLOR,
    THEME_GREEN_DARK_COLORFUL,
    THEME_GREEN_DARK_BICOLOR,
    THEME_GREEN_DARK_TRICOLOR,
    THEME_GREEN_LIGHT_COLORFUL,
    THEME_GREEN_LIGHT_BICOLOR,
    THEME_GREEN_LIGHT_TRICOLOR,
    THEME_YELLOW_DARK_COLORFUL,
    THEME_YELLOW_DARK_BICOLOR,
    THEME_YELLOW_DARK_TRICOLOR,
    THEME_YELLOW_LIGHT_COLORFUL,
    THEME_YELLOW_LIGHT_BICOLOR,
    THEME_YELLOW_LIGHT_TRICOLOR,
    THEME_ORANGE_DARK_COLORFUL,
    THEME_ORANGE_DARK_BICOLOR,
    THEME_ORANGE_DARK_TRICOLOR,
    THEME_ORANGE_LIGHT_COLORFUL,
    THEME_ORANGE_LIGHT_BICOLOR,
    THEME_ORANGE_LIGHT_TRICOLOR,
    THEME_PURPLE_DARK_COLORFUL,
    THEME_PURPLE_DARK_BICOLOR,
    THEME_PURPLE_DARK_TRICOLOR,
    THEME_PURPLE_LIGHT_COLORFUL,
    THEME_PURPLE_LIGHT_BICOLOR,
    THEME_PURPLE_LIGHT_TRICOLOR,
    THEME_PINK_DARK_COLORFUL,
    THEME_PINK_DARK_BICOLOR,
    THEME_PINK_DARK_TRICOLOR,
    THEME_PINK_LIGHT_COLORFUL,
    THEME_PINK_LIGHT_BICOLOR,
    THEME_PINK_LIGHT_TRICOLOR
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
    	onSettingsChanged();
        return [ myView ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        setGlobalVariables();
        myView.selectThemeColors();
        myView.loadFonts();    
        WatchUi.requestUpdate();
    }

    //! Set the motivational quote
    function onBackgroundData(data) as Void {
		var apiData = data["motivationalQuote"];
        if (apiData instanceof Array) {
            motivationalQuoteArray.addAll(apiData);
            System.println("No of Motivational quotes downloaded: " + apiData.size());
        } else if (apiData instanceof String) {
			motivationalQuoteArray.add(apiData);
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

            updatingSecondsInLowPowerMode = Properties.getValue("UpdateSecondInLowPowerMode");
            militaryFormat = Properties.getValue("UseMilitaryFormat");

            dataBarWidth = Properties.getValue("DataBarWidth");
            unfilledDataBarAsBGColor = Properties.getValue("UnfilledDataBar");
            selectedValueForDataFieldMiddle = Properties.getValue("DataFieldMiddle");
			selectedValueForDataFieldLeft = Properties.getValue("DataFieldLeft");
			selectedValueForDataFieldRight = Properties.getValue("DataFieldRight");
            selectedValueForDataBarOuterLeftTop = Properties.getValue("DataBarOuterLeftTop");
			selectedValueForDataBarInnerRightBottom = Properties.getValue("DataBarInnerRightBottom");

            totalCaloriesGoal = Properties.getValue("CaloriesGoal");

            motivationalQuoteProperty = Properties.getValue("MotivationalQuoteProperty");
            motivationalQuoteChangeInterval = Properties.getValue("MotivationalQuoteChangeInterval");
            firstLineWidthPercent = Properties.getValue("FirstMotivationLineWidthPercent");
            secondLineWidthPercent = Properties.getValue("SecondMotivationLineWidthPercent");
            thirdLineWidthPercent = Properties.getValue("ThirdMotivationLineWidthPercent");

            //Does not work. Issue in Motivationfield.mc
            motivationalQuote = Storage.getValue("MotivationalQuote");

            Storage.setValue("MotivationalQuoteArraySize", motivationalQuoteArray.size());
		} else {
		    theme = getApp().getProperty("Theme");

            updatingSecondsInLowPowerMode = getApp().getProperty("UpdateSecondInLowPowerMode");
            militaryFormat = getApp().getProperty("UseMilitaryFormat");

            dataBarWidth = getApp().getProperty("DataBarWidth");
            unfilledDataBarAsBGColor = getApp().getProperty("UnfilledDataBar");
		    selectedValueForDataFieldMiddle = getApp().getProperty("DataFieldMiddle");
			selectedValueForDataFieldLeft = getApp().getProperty("DataFieldLeft");
			selectedValueForDataFieldRight = getApp().getProperty("DataFieldRight");
            selectedValueForDataBarOuterLeftTop = getApp().getProperty("DataBarOuterLeftTop");
			selectedValueForDataBarInnerRightBottom = getApp().getProperty("DataBarInnerRightBottom");

            totalCaloriesGoal = getApp().getProperty("CaloriesGoal");

            motivationalQuoteProperty = getApp().getProperty("MotivationalQuoteProperty");
            motivationalQuoteChangeInterval = getApp().getProperty("MotivationalQuoteChangeInterval");
            firstLineWidthPercent = getApp().getProperty("FirstMotivationLineWidthPercent");
            secondLineWidthPercent = getApp().getProperty("SecondMotivationLineWidthPercent");
            thirdLineWidthPercent = getApp().getProperty("ThirdMotivationLineWidthPercent");

            motivationalQuote = getApp().getProperty("MotivationalQuote");

            getApp().setProperty("MotivationalQuoteArraySize", motivationalQuoteArray.size());
		}
    }

}

//! Give back App
//! @return App
function getApp() as WarpaintMotivationApp {
    return Application.getApp() as WarpaintMotivationApp;
}
