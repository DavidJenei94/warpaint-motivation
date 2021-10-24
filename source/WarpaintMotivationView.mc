import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;

class WarpaintMotivationView extends WatchUi.WatchFace {

    private var viewDrawables = {};
	private var _isAwake as Boolean;
	private var _splittedMotivationalQuote = new String[3];
	private var _partialUpdatesAllowed as Boolean;
	private var _SecondsBoundingBox = new Number[4];

    private var _data as Data;
    private var _motivation as Motivation;

	private var _burnInProtection as Boolean;
	private var _burnInTimeChanged as Boolean;
	private var _burnInTimeDisplayed as Boolean;

	private var _deviceSettings as System.DeviceSettings;

    //! Constructor
    function initialize() {
        WatchFace.initialize();
		_deviceSettings = System.getDeviceSettings();
        _isAwake = true;
        _partialUpdatesAllowed = (WatchUi.WatchFace has :onPartialUpdate);
        _data = new Data(_deviceSettings);

        // check Burn in Protect requirement
		_burnInProtection = (_deviceSettings has :requiresBurnInProtection) ? _deviceSettings.requiresBurnInProtection : false;
		if (_burnInProtection) {
			_burnInTimeChanged = true;
			_burnInTimeDisplayed = false;
		}
    }

    //! Load resources and drawables
	//! Split motivational quote initially (need dc, can't be in initialize())
	//! @param dc Device Content
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        loadDrawables();

		var firstLineWidth = viewDrawables[:topMotivationText].getLineWidth();
		var secondLineWidth = viewDrawables[:middleMotivationText].getLineWidth();
		var thirdLineWidth = viewDrawables[:bottomMotivationText].getLineWidth();
		_motivation = new Motivation(dc, firstLineWidth, secondLineWidth, thirdLineWidth);
		_splittedMotivationalQuote = _motivation.getSplittedMotivationalQuote(dc);
    }

    //! Load drawables
    private function loadDrawables() as Void {
        viewDrawables[:timeText] = View.findDrawableById("TimeLabel");
		if (_burnInProtection) {
			viewDrawables[:timeTextTop] = View.findDrawableById("AlwaysOnTimeLabelTopLabel");
			viewDrawables[:timeTextBottom] = View.findDrawableById("AlwaysOnTimeLabelBottomLabel");
		}
        viewDrawables[:dateText] = View.findDrawableById("DateLabel");

        viewDrawables[:middleDataText] = View.findDrawableById("DataFieldMiddle");
		viewDrawables[:leftDataText] = View.findDrawableById("DataFieldLeft");
		viewDrawables[:rightDataText] = View.findDrawableById("DataFieldRight");

		viewDrawables[:leftDataBar] = View.findDrawableById("OuterLeftTopDataBar");
		viewDrawables[:rightDataBar] = View.findDrawableById("InnerRightBottomDataBar");

        viewDrawables[:topMotivationText] = View.findDrawableById("MotivationFieldTop");
		viewDrawables[:middleMotivationText] = View.findDrawableById("MotivationFieldMiddle");
		viewDrawables[:bottomMotivationText] = View.findDrawableById("MotivationFieldBottom");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    //! Update the view
    //! @param dc Device context
    function onUpdate(dc as Dc) as Void {

		// Set anti-aliasing if possible
		if (dc has :setAntiAlias) {
			dc.setAntiAlias(true);
		}
    
		// If AMOLED watch is in low power mode it shows different layout
		if (_burnInProtection && !_isAwake) {
			// Clear dc with backgroundcolor
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
			dc.clear();

			if (!_burnInTimeDisplayed) {
				// Free memory of other drawables (reload later when awake)
				setLayout(Rez.Layouts.AlwaysOn(dc));
				loadDrawables();

				_burnInTimeDisplayed = true;
			}

			// Draw To AlwaysOnLayout
			drawAlwaysOn(dc);

			// Set motivational quote
			_motivation.checkMotivationRefresh(dc);
			_splittedMotivationalQuote = _motivation.getSplittedMotivationalQuote(dc);
		} else {
			// Clear dc with backgroundcolor
			dc.setColor(themeColors[:foregroundPrimaryColor], themeColors[:backgroundColor]);
			dc.clear();

			// Reload drawables if changed from low power mode in case of AMOLED
			if (_burnInProtection && _burnInTimeDisplayed) {
				setLayout(Rez.Layouts.WatchFace(dc));
				loadDrawables();

				_burnInTimeDisplayed = false;
			}

			// Set settings to the Time and databars
			viewDrawables[:timeText].setSettings(_deviceSettings);
			viewDrawables[:leftDataBar].setSettings(_deviceSettings);
			viewDrawables[:rightDataBar].setSettings(_deviceSettings);
			// Set BurnInProtection for Time layout
			viewDrawables[:timeText].setBurnInProtection(_burnInTimeDisplayed);

			// Refresh data 
			_data.refreshData(_deviceSettings);

			// Check if refresh sunriseSunset is necessary
			SunriseSunset.checkSunriseSunsetRefresh();

			// Set data for data fields
			viewDrawables[:middleDataText].setSelectedData(_data.getDataForDataField(selectedValueForDataFieldMiddle));
			viewDrawables[:leftDataText].setSelectedData(_data.getDataForDataField(selectedValueForDataFieldLeft));
			viewDrawables[:rightDataText].setSelectedData(_data.getDataForDataField(selectedValueForDataFieldRight));
			
			// Set data for databars
			if (!sunriseSunsetDrawingEnabled) {
				viewDrawables[:leftDataBar].setSelectedData(_data.getDataForDataField(selectedValueForDataBarOuterLeftTop));
			}
			viewDrawables[:rightDataBar].setSelectedData(_data.getDataForDataField(selectedValueForDataBarInnerRightBottom));

			// Set motivational quote
			_motivation.checkMotivationRefresh(dc);
			_splittedMotivationalQuote = _motivation.getSplittedMotivationalQuote(dc);
			viewDrawables[:topMotivationText].setMotivationPartText(_splittedMotivationalQuote[0]);
			viewDrawables[:middleMotivationText].setMotivationPartText(_splittedMotivationalQuote[1]);
			viewDrawables[:bottomMotivationText].setMotivationPartText(_splittedMotivationalQuote[2]);

			// Call the parent onUpdate function to redraw the layout
			// Call the Drawables' draw function
			// Draw Time (+AM/PM), date, data fields, databars, Motivational quote
			View.onUpdate(dc);

			// Draw seconds
			if (System.getClockTime().sec != 0) {
				if (_partialUpdatesAllowed && displaySecond == 2) {
					// If this device supports partial updates
					onPartialUpdate(dc);
				} else if (_isAwake && displaySecond != 0) {
					viewDrawables[:timeText].drawSeconds(dc);
				}
			}
		}
    }

    //! Handle the partial update event - Draw seconds every second
    //! @param dc Device context
	(:partial_update)
    public function onPartialUpdate(dc as Dc) as Void {
		if (displaySecond == 2 && System.getClockTime().sec != 0) {
	        _SecondsBoundingBox = viewDrawables[:timeText].getSecondsBoundingBox(dc);
	  
            // Set clip to the region of bounding box and which only updates that
	        dc.setClip(_SecondsBoundingBox[0], _SecondsBoundingBox[1], _SecondsBoundingBox[2], _SecondsBoundingBox[3]);
	        dc.setColor(themeColors[:foregroundPrimaryColor], themeColors[:backgroundColor]);
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
        _isAwake = true;
		WatchUi.requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        _isAwake = false;
		WatchUi.requestUpdate(); // call onUpdate() in order to draw seconds
    }

    //! Load fonts - in View, because WatchUI is not supported in background events
    function loadFonts() as Void {
		smallFont = WatchUi.loadResource(Rez.Fonts.SmallFont);
		mediumFont = WatchUi.loadResource(Rez.Fonts.MediumFont);
		largeFont = WatchUi.loadResource(Rez.Fonts.LargeFont);
		iconFont = WatchUi.loadResource(Rez.Fonts.IconFont);
    }

	//! Reload DeviceSettings when settings are changed
    function onSettingsChanged() as Void {
		_deviceSettings = System.getDeviceSettings();
	}

	//! Draw To AlwaysOnLayout
	//! @param dc Device context
	(:burn_in_protection)
	function drawAlwaysOn(dc as Dc) as Void {
		dc.setPenWidth(1);
		var height = dc.getHeight();
		var width = dc.getWidth();
		_burnInTimeChanged = !_burnInTimeChanged;
		if (_burnInTimeChanged) {
			// Set settings and BurnInProtection for Time layout
			viewDrawables[:timeTextTop].setSettings(_deviceSettings);
			viewDrawables[:timeTextTop].setBurnInProtection(_burnInTimeDisplayed);
			viewDrawables[:timeTextTop].drawTime(dc);
			dc.drawLine(width * 0.1, height * 0.5, width * 0.9, height * 0.5);
		} else {
			// Set settings and BurnInProtection for Time layout
			viewDrawables[:timeTextBottom].setSettings(_deviceSettings);
			viewDrawables[:timeTextBottom].setBurnInProtection(_burnInTimeDisplayed);
			viewDrawables[:timeTextBottom].drawTime(dc);
			dc.drawLine(width * 0.1, height * 0.5 - 1, width * 0.9, height * 0.5 - 1);
		}
	}
}
