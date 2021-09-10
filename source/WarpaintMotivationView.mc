import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;

class WarpaintMotivationView extends WatchUi.WatchFace {

    private var viewDrawables = {};
	private var _isAwake as Boolean;
	private var _isMotivationalQuoteSet as Boolean;
	private var _splittedMotivationalQuote = new String[3];
	private var _partialUpdatesAllowed as Boolean;
	private var _SecondsBoundingBox = new Number[4];
    private var _data as Data;
    private var _outerLeftTopDataBar as DataBar;
    private var _innerRightBottomDataBar as DataBar;
	private var _burnInProtection as Boolean;
	private var _burnInTimeChanged as Boolean;
	private var _burnInTimeDisplayed as Boolean;
	private var _checkerboardArray = new [2];

    //! Constructor
    function initialize() {
        WatchFace.initialize();
        _isAwake = true;
		_isMotivationalQuoteSet = false;
        _partialUpdatesAllowed = (WatchUi.WatchFace has :onPartialUpdate);
        _data = new Data();
        _outerLeftTopDataBar = new DataBar();
    	_innerRightBottomDataBar = new DataBar();

        // check Burn in Protect requirement
		var settings = System.getDeviceSettings();
		_burnInProtection = (settings has :requiresBurnInProtection) ? settings.requiresBurnInProtection : false;
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

		_splittedMotivationalQuote = MotivationField.splitMotivationalQuote(dc, motivationalQuote);
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
		
        // Clear dc with backgroundcolor
        dc.setColor(foregroundColor, backgroundColor);
    	dc.clear();
    
		// If AMOLED watch is in low power mode it shows different layout
		if (_burnInProtection && !_isAwake) {
			if (!_burnInTimeDisplayed) {
				// Free memory of other drawables (reload later when awake)
				setLayout(Rez.Layouts.AlwaysOn(dc));
				loadDrawables();

				_burnInTimeDisplayed = true;
			}

			dc.setColor(foregroundColor, backgroundColor);
			dc.setPenWidth(1);
			var height = dc.getHeight();
			var width = dc.getWidth();
			_burnInTimeChanged = !_burnInTimeChanged;
			if (_burnInTimeChanged) {
				viewDrawables[:timeTextTop].drawTime(dc);
				dc.drawLine(width * 0.1, height * 0.5, width * 0.9, height * 0.5);
			} else {
				viewDrawables[:timeTextBottom].drawTime(dc);
				dc.drawLine(width * 0.1, height * 0.5 - 1, width * 0.9, height * 0.5 - 1);
			}

		} else {
			// Reload drawables if changed from low power mode in case of AMOLED
			if (_burnInProtection && _burnInTimeDisplayed) {
				setLayout(Rez.Layouts.WatchFace(dc));
				loadDrawables();

				_burnInTimeDisplayed = false;
			}

			// Set and draw time, AM/PM
			viewDrawables[:timeText].drawTime(dc);
			viewDrawables[:timeText].drawAmPm(dc);

			// Set and draw date
			viewDrawables[:dateText].drawDate(dc);

			// set data fields and icons
			_data.refreshData();
			var middleValues = _data.getDataForDataField(selectedValueForDataFieldMiddle);
			var leftValues = _data.getDataForDataField(selectedValueForDataFieldLeft);
			var rightValues = _data.getDataForDataField(selectedValueForDataFieldRight);
			viewDrawables[:middleDataText].drawData(dc, middleValues[:displayData], middleValues[:iconText], middleValues[:iconColor]);
			viewDrawables[:leftDataText].drawData(dc, leftValues[:displayData], leftValues[:iconText], leftValues[:iconColor]);
			viewDrawables[:rightDataText].drawData(dc, rightValues[:displayData], rightValues[:iconText], rightValues[:iconColor]);

			// Set data bars
			var outerLeftTopValues = _data.getDataForDataField(selectedValueForDataBarOuterLeftTop);
			var innerRightBottomValues = _data.getDataForDataField(selectedValueForDataBarInnerRightBottom);
			
			var screenShape = System.getDeviceSettings().screenShape;
			if (screenShape == System.SCREEN_SHAPE_ROUND) {
				if (selectedValueForDataBarOuterLeftTop == DATA_SUNRISE_SUNSET) {
					var sunsetSunrise = new SunriseSunset();
					sunsetSunrise.drawSunriseSunsetArc(dc);
				} else {
					_outerLeftTopDataBar.drawRoundDataBar(dc, outerLeftTopValues[:currentData], outerLeftTopValues[:dataMaxValue], outerLeftTopValues[:barColor], DATABAR_OUTER_LEFT_TOP);
				}
				
				_innerRightBottomDataBar.drawRoundDataBar(dc, innerRightBottomValues[:currentData], innerRightBottomValues[:dataMaxValue], innerRightBottomValues[:barColor], DATABAR_INNER_RIGHT_BOTTOM);			
			} else if (screenShape == System.SCREEN_SHAPE_SEMI_ROUND) {
				_outerLeftTopDataBar.drawSemiRoundDataBar(dc, outerLeftTopValues[:currentData], outerLeftTopValues[:dataMaxValue], outerLeftTopValues[:barColor], DATABAR_OUTER_LEFT_TOP);
				_innerRightBottomDataBar.drawSemiRoundDataBar(dc, innerRightBottomValues[:currentData], innerRightBottomValues[:dataMaxValue], innerRightBottomValues[:barColor], DATABAR_INNER_RIGHT_BOTTOM);
			} else if (screenShape == System.SCREEN_SHAPE_RECTANGLE) {
				_outerLeftTopDataBar.drawRectangleDataBar(dc, outerLeftTopValues[:currentData], outerLeftTopValues[:dataMaxValue], outerLeftTopValues[:barColor], DATABAR_OUTER_LEFT_TOP);
				_innerRightBottomDataBar.drawRectangleDataBar(dc, innerRightBottomValues[:currentData], innerRightBottomValues[:dataMaxValue], innerRightBottomValues[:barColor], DATABAR_INNER_RIGHT_BOTTOM);
			}

			// Set motivational quote
			// Interval is to change motivational quote
			// If motivational quote is null or the minute is the selected one, refresh quote
			var intervalToChangeQuote = motivationalQuoteChangeInterval > 60 ? (motivationalQuoteChangeInterval / 60) : motivationalQuoteChangeInterval;
			var remainder = motivationalQuoteChangeInterval > 60 ? System.getClockTime().hour % intervalToChangeQuote : System.getClockTime().min % intervalToChangeQuote;
			if (motivationalQuote == null || (!_isMotivationalQuoteSet && remainder == 0)) {
				MotivationField.setMotivationalQuote();
				_splittedMotivationalQuote = MotivationField.splitMotivationalQuote(dc, motivationalQuote);
				_isMotivationalQuoteSet = true;
			}
			if (_isMotivationalQuoteSet && remainder == 1) {
				_isMotivationalQuoteSet = false;
			}
			viewDrawables[:topMotivationText].drawMotivationText(dc, _splittedMotivationalQuote[0]);
			viewDrawables[:middleMotivationText].drawMotivationText(dc, _splittedMotivationalQuote[1]);
			viewDrawables[:bottomMotivationText].drawMotivationText(dc, _splittedMotivationalQuote[2]);

			// Draw seconds
			if (_partialUpdatesAllowed && updatingSecondsInLowPowerMode) {
				// If this device supports partial updates
				onPartialUpdate(dc);
			} else if (_isAwake) {
				viewDrawables[:timeText].drawSeconds(dc);
			}
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

    //! Set forground and backgorund colors for themes
    function selectThemeColors() as Void {
    	switch (theme) {
    		case THEME_WHITE_DARK:
    			foregroundColor = Graphics.COLOR_WHITE;
    			backgroundColor = Graphics.COLOR_BLACK;
				unfilledDataBarColor = selectUnfilledDataBarColor(Graphics.COLOR_DK_GRAY);
    			break;
    		case THEME_BLUE_DARK:
    			foregroundColor = Graphics.COLOR_BLUE;
    			backgroundColor = Graphics.COLOR_BLACK;
				unfilledDataBarColor = selectUnfilledDataBarColor(Graphics.COLOR_DK_GRAY);
    			break;
    		case THEME_RED_DARK:
    			foregroundColor = Graphics.COLOR_RED;
    			backgroundColor = Graphics.COLOR_BLACK;
				unfilledDataBarColor = selectUnfilledDataBarColor(Graphics.COLOR_DK_GRAY);
    			break;
    		case THEME_GREEN_DARK:
    			foregroundColor = Graphics.COLOR_GREEN;
    			backgroundColor = Graphics.COLOR_BLACK;
				unfilledDataBarColor = selectUnfilledDataBarColor(Graphics.COLOR_DK_GRAY);
    			break;
    		case THEME_BLACK_LIGHT:
    			foregroundColor = Graphics.COLOR_BLACK;
    			backgroundColor = Graphics.COLOR_WHITE;
				unfilledDataBarColor = selectUnfilledDataBarColor(Graphics.COLOR_DK_GRAY);
    			break;
    	}
    }

	//! Select the unfilled data bar color according to the Settings
	//! @param color the color of the unfilled data bar if not the background color
	//! @return final color of the unfilled data bar
	private function selectUnfilledDataBarColor(color as Number) as Number {
		return unfilledDataBarAsBGColor ? backgroundColor : color;
	}

}
