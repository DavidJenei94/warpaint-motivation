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
	private var _isSunriseSunsetSet as Boolean;

	private var _burnInProtection as Boolean;
	private var _burnInTimeChanged as Boolean;
	private var _burnInTimeDisplayed as Boolean;

	private var _deviceSettings as System.DeviceSettings;

    //! Constructor
    function initialize() {
        WatchFace.initialize();
		_deviceSettings = System.getDeviceSettings();
        _isAwake = true;
		_isMotivationalQuoteSet = true;
		_isSunriseSunsetSet = false;
        _partialUpdatesAllowed = (WatchUi.WatchFace has :onPartialUpdate);
        _data = new Data(_deviceSettings);
        _outerLeftTopDataBar = new DataBar(DATABAR_OUTER_LEFT_TOP);
    	_innerRightBottomDataBar = new DataBar(DATABAR_INNER_RIGHT_BOTTOM);

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

			dc.setPenWidth(1);
			var height = dc.getHeight();
			var width = dc.getWidth();
			_burnInTimeChanged = !_burnInTimeChanged;
			if (_burnInTimeChanged) {
				viewDrawables[:timeTextTop].drawTime(dc, _deviceSettings, _burnInTimeDisplayed);
				dc.drawLine(width * 0.1, height * 0.5, width * 0.9, height * 0.5);
			} else {
				viewDrawables[:timeTextBottom].drawTime(dc, _deviceSettings, _burnInTimeDisplayed);
				dc.drawLine(width * 0.1, height * 0.5 - 1, width * 0.9, height * 0.5 - 1);
			}

		} else {
			// Clear dc with backgroundcolor
			dc.setColor(themeColors[:foregroundPrimaryColor], themeColors[:backgroundColor]);
			dc.clear();

			var clockTime = System.getClockTime();

			// Reload drawables if changed from low power mode in case of AMOLED
			if (_burnInProtection && _burnInTimeDisplayed) {
				setLayout(Rez.Layouts.WatchFace(dc));
				loadDrawables();

				_burnInTimeDisplayed = false;
			}

			// Set and draw time, AM/PM
			viewDrawables[:timeText].drawTime(dc, _deviceSettings, _burnInTimeDisplayed);
			viewDrawables[:timeText].drawAmPm(dc, _deviceSettings);

			// Set and draw date
			viewDrawables[:dateText].drawDate(dc);

			// set data fields and icons + Set sunriseSunset if necessary
			_data.refreshData(_deviceSettings);
			
			if (sunriseSunsetDrawingEnabled || selectedValueForDataFieldMiddle == DATA_SUNRISE_SUNSET || 
				selectedValueForDataFieldLeft == DATA_SUNRISE_SUNSET || selectedValueForDataFieldRight == DATA_SUNRISE_SUNSET) {

				if (sunriseSunset == null) {
					sunriseSunset = new SunriseSunset();
				}

				// interval in minutes
				var intervalToRefreshSunriseSunset = 15;
				var minRemainder = clockTime.min % intervalToRefreshSunriseSunset;
				if (!_isSunriseSunsetSet && minRemainder == 1) {
					sunriseSunset.refreshSunsetSunrise();
					_isSunriseSunsetSet = true;
				}
				
				if (_isSunriseSunsetSet && minRemainder != 1) {
					// Change back to false after the minute to prevent updating through every second (if not in low power mode)
					_isSunriseSunsetSet = false;
				}				
			}
			
			var middleValues = _data.getDataForDataField(selectedValueForDataFieldMiddle);
			var leftValues = _data.getDataForDataField(selectedValueForDataFieldLeft);
			var rightValues = _data.getDataForDataField(selectedValueForDataFieldRight);
			if (middleValues[:valid]){
				viewDrawables[:middleDataText].drawData(dc, middleValues[:displayData], middleValues[:iconText], middleValues[:iconColor]);
			}
			if (leftValues[:valid]){
				viewDrawables[:leftDataText].drawData(dc, leftValues[:displayData], leftValues[:iconText], leftValues[:iconColor]);
			}
			if (rightValues[:valid]){
				viewDrawables[:rightDataText].drawData(dc, rightValues[:displayData], rightValues[:iconText], rightValues[:iconColor]);
			}

			// Set data bars
			var outerLeftTopValues = !sunriseSunsetDrawingEnabled ? _data.getDataForDataField(selectedValueForDataBarOuterLeftTop) : {:valid => true};
			var innerRightBottomValues = _data.getDataForDataField(selectedValueForDataBarInnerRightBottom);
			
			var screenShape = _deviceSettings.screenShape;
			if (screenShape == System.SCREEN_SHAPE_ROUND) {
				if (outerLeftTopValues[:valid]){
					if (sunriseSunsetDrawingEnabled) {
						sunriseSunset.drawSunriseSunsetArc(dc, _deviceSettings);
					} else {
						_outerLeftTopDataBar.drawRoundDataBar(dc, outerLeftTopValues[:currentData], outerLeftTopValues[:dataMaxValue], outerLeftTopValues[:barColor]);
					}
				}
				
				if (innerRightBottomValues[:valid]){
					_innerRightBottomDataBar.drawRoundDataBar(dc, innerRightBottomValues[:currentData], innerRightBottomValues[:dataMaxValue], innerRightBottomValues[:barColor]);
				}			
			} else if (screenShape == System.SCREEN_SHAPE_SEMI_ROUND) {
				if (outerLeftTopValues[:valid]){
					_outerLeftTopDataBar.drawSemiRoundDataBar(dc, outerLeftTopValues[:currentData], outerLeftTopValues[:dataMaxValue], outerLeftTopValues[:barColor]);
				}
				if (innerRightBottomValues[:valid]){
					_innerRightBottomDataBar.drawSemiRoundDataBar(dc, innerRightBottomValues[:currentData], innerRightBottomValues[:dataMaxValue], innerRightBottomValues[:barColor]);
				}
			} else if (screenShape == System.SCREEN_SHAPE_RECTANGLE) {
				if (outerLeftTopValues[:valid]){
					_outerLeftTopDataBar.drawRectangleDataBar(dc, outerLeftTopValues[:currentData], outerLeftTopValues[:dataMaxValue], outerLeftTopValues[:barColor]);
				}
				if (innerRightBottomValues[:valid]){
					_innerRightBottomDataBar.drawRectangleDataBar(dc, innerRightBottomValues[:currentData], innerRightBottomValues[:dataMaxValue], innerRightBottomValues[:barColor]);
				}
			}

			// Set motivational quote
			// Interval is to change motivational quote
			// If motivational quote is null or the minute is the selected one, refresh quote
			var intervalToChangeQuote = motivationalQuoteChangeInterval > 60 ? (motivationalQuoteChangeInterval / 60) : motivationalQuoteChangeInterval;
			var remainder = motivationalQuoteChangeInterval > 60 ? clockTime.hour % intervalToChangeQuote : clockTime.min % intervalToChangeQuote;
			if (motivationalQuote == null || (!_isMotivationalQuoteSet && remainder == 0)) {
				MotivationField.setMotivationalQuote();
				_splittedMotivationalQuote = MotivationField.splitMotivationalQuote(dc, motivationalQuote);
				_isMotivationalQuoteSet = true;
			}
			if (_isMotivationalQuoteSet && remainder != 0) {
				// Change back to false after the minute to prevent updating through every second (if not in low power mode)
				_isMotivationalQuoteSet = false;
			}
			viewDrawables[:topMotivationText].drawMotivationText(dc, _splittedMotivationalQuote[0]);
			viewDrawables[:middleMotivationText].drawMotivationText(dc, _splittedMotivationalQuote[1]);
			viewDrawables[:bottomMotivationText].drawMotivationText(dc, _splittedMotivationalQuote[2]);

			// Draw seconds
			if (clockTime.sec != 0) {
				if (_partialUpdatesAllowed && displaySecond == 2) {
					// If this device supports partial updates
					onPartialUpdate(dc);
				} else if (_isAwake && displaySecond != 0) {
					viewDrawables[:timeText].drawSeconds(dc, _deviceSettings);
				}
			}
		}
    }

    //! Handle the partial update event - Draw seconds every second
    //! @param dc Device context
	(:partial_update)
    public function onPartialUpdate(dc as Dc) as Void {
		if (displaySecond == 2) {
	        _SecondsBoundingBox = viewDrawables[:timeText].getSecondsBoundingBox(dc, _deviceSettings);
	  
            // Set clip to the region of bounding box and which only updates that
	        dc.setClip(_SecondsBoundingBox[0], _SecondsBoundingBox[1], _SecondsBoundingBox[2], _SecondsBoundingBox[3]);
	        dc.setColor(themeColors[:foregroundPrimaryColor], themeColors[:backgroundColor]);
	    	dc.clear();
	        viewDrawables[:timeText].drawSeconds(dc, _deviceSettings);
	        
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
}
