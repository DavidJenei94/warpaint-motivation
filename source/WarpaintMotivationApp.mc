import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// global variables
var myView as View;

var updatingSecondsInLowPowerMode as Boolean;
var militaryFormat as Boolean;

var foregroundColor as Number;
var backgroundColor as Number;

var smallFont as Font;
var mediumFont as Font;
var largeFont as Font;
var iconFont as Font;

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
        myView.loadFonts();        
        WatchUi.requestUpdate();
    }

    //! Set global variables (fonts are in the View
    private function setGlobalVariables() as Void {
    	if (Toybox.Application has :Storage) {
		    foregroundColor = Properties.getValue("ForegroundColor");
		    backgroundColor = Properties.getValue("BackgroundColor");

            updatingSecondsInLowPowerMode = Properties.getValue("UpdateSecondInLowPowerMode");
            militaryFormat = Properties.getValue("UseMilitaryFormat");
		} else {
		    foregroundColor = getApp().getProperty("ForegroundColor");
		    backgroundColor = getApp().getProperty("BackgroundColor");

            updatingSecondsInLowPowerMode = getApp().getProperty("UpdateSecondInLowPowerMode");
            militaryFormat = getApp().getProperty("UseMilitaryFormat");
		}
    }

}

//! Give back App
function getApp() as WarpaintMotivationApp {
    return Application.getApp() as WarpaintMotivationApp;
}