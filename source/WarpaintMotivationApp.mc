import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

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
var unfilledDataBarColor = Graphics.COLOR_DK_GRAY;
var selectedValueForDataBarOuterLeftTop as Integer;
var selectedValueForDataBarInnerRightBottom as Integer;

var smallFont as Font;
var mediumFont as Font;
var largeFont as Font;
var iconFont as Font;

var totalCaloriesGoal as Number;

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

class WarpaintMotivationApp extends Application.AppBase {

    //! Constructor
    function initialize() {
        AppBase.initialize();
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
        selectThemeColors();
        myView.loadFonts();    
        WatchUi.requestUpdate();
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
		}
    }

    //! Set forground and backgorund colors
    private function selectThemeColors() as Void {
    	switch (theme) {
    		case THEME_WHITE_DARK:
    			foregroundColor = Graphics.COLOR_WHITE;
    			backgroundColor = Graphics.COLOR_BLACK;
    			break;
    		case THEME_BLUE_DARK:
    			foregroundColor = Graphics.COLOR_BLUE;
    			backgroundColor = Graphics.COLOR_BLACK;
    			break;
    		case THEME_RED_DARK:
    			foregroundColor = Graphics.COLOR_RED;
    			backgroundColor = Graphics.COLOR_BLACK;
    			break;
    		case THEME_GREEN_DARK:
    			foregroundColor = Graphics.COLOR_GREEN;
    			backgroundColor = Graphics.COLOR_BLACK;
    			break;
    		case THEME_BLACK_LIGHT:
    			foregroundColor = Graphics.COLOR_BLACK;
    			backgroundColor = Graphics.COLOR_WHITE;
    			break;
    	}
    }

}

//! Give back App
//! @return App
function getApp() as WarpaintMotivationApp {
    return Application.getApp() as WarpaintMotivationApp;
}