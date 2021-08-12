import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class WarpaintMotivationView extends WatchUi.WatchFace {

    private var viewDrawables = {};
	private var _isAwake as Boolean;
	private var _partialUpdatesAllowed as Boolean;
	private var _SecondsBoundingBox = new Number[4];

    //! Constructor
    function initialize() {
        WatchFace.initialize();
        _isAwake = true;
        _partialUpdatesAllowed = (WatchUi.WatchFace has :onPartialUpdate);
    }

    //! Load resources and drawables
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        loadDrawables();
    }

    //! Load drawables
    private function loadDrawables() as Void {
        viewDrawables[:timeText] = View.findDrawableById("TimeLabel");
        viewDrawables[:dateText] = View.findDrawableById("DateLabel");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    //! Update the view
    //! @param dc Device context
    function onUpdate(dc as Dc) as Void {
		
        // Clear dc with backgroundcolor
        dc.setColor(foregroundColor, backgroundColor);
    	dc.clear();
    
    	// Set and draw time, AM/PM
        viewDrawables[:timeText].drawTime(dc);
        viewDrawables[:timeText].drawAmPm(dc);

    	// Draw seconds
        if (_partialUpdatesAllowed && updatingSecondsInLowPowerMode) {
            // If this device supports partial updates
            onPartialUpdate(dc);
        } else if (_isAwake) {
	        viewDrawables[:timeText].drawSeconds(dc);
    	}
    }

    //! Handle the partial update event - Draw seconds every second
    //! @param dc Device context
    public function onPartialUpdate(dc as Dc) as Void {
		if (updatingSecondsInLowPowerMode) {
	        _SecondsBoundingBox = viewDrawables[:timeText].getSecondsBoundingBox(dc);
	  
            // Set clip to the region of bounding box and which only updates that
	        dc.setClip(_SecondsBoundingBox[0], _SecondsBoundingBox[1], _SecondsBoundingBox[2], _SecondsBoundingBox[3]);
	        dc.setColor(foregroundColor, backgroundColor);
	    	dc.clear();
	        viewDrawables[:timeText].drawSeconds(dc);
	        
	        dc.clearClip();
		}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    //! Load fonts - in View, because WatchUI is not supported in background events
    function loadFonts() as Void {
		smallFont = WatchUi.loadResource(Rez.Fonts.SmallFont);
		mediumFont = WatchUi.loadResource(Rez.Fonts.MediumFont);
		largeFont = WatchUi.loadResource(Rez.Fonts.LargeFont);
		iconFont = WatchUi.loadResource(Rez.Fonts.IconFont);
    }

}
