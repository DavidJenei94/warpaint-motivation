import Toybox.Graphics;
import Toybox.WatchUi;

class DataBar extends WatchUi.Drawable {

	private var _side as Integer;
	private var _dataBarWidth as Integer;
	private var _selectedValue as Number;
	private var _settings as System.DeviceSettings;
	
	//! Constructor
	//! @param side the side of the bar (outer-left-top or inner-right-bottom)
    function initialize(params) {
		Drawable.initialize(params);
		_side = params[:side];
		_dataBarWidth = params[:barWidth];
	}

	//! Set Selected Data
	//! @param selectedValue the selected datavalue
	function setSelectedData(selectedValue as Number) as Void {
		_selectedValue = selectedValue;
	}

	//! Set settings
	//! @param settings DeviceSettings
	function setSettings(settings as DeviceSettings) as Void {
		_settings = settings;
	}

	//! Draw the dataBar
	//! @param dc Device Content
	function draw(dc as Dc) as Void {
		var screenShape = _settings.screenShape;
		if (screenShape == System.SCREEN_SHAPE_ROUND) {
			if (sunriseSunsetDrawingEnabled && _side == DATABAR_OUTER_LEFT_TOP) {
				sunriseSunset.setDatabarWidth(_dataBarWidth);
				sunriseSunset.drawSunriseSunsetArc(dc, _settings);
			} else {
				if (_selectedValue != null && _selectedValue[:valid]){
					drawRoundDataBar(dc, _selectedValue[:currentData], _selectedValue[:dataMaxValue], _selectedValue[:barColor]);
				}
			}
		} else if (screenShape == System.SCREEN_SHAPE_SEMI_ROUND) {
			if (_selectedValue != null && _selectedValue[:valid]){
				drawSemiRoundDataBar(dc, _selectedValue[:currentData], _selectedValue[:dataMaxValue], _selectedValue[:barColor]);
			}
		} else if (screenShape == System.SCREEN_SHAPE_RECTANGLE) {
			if (_selectedValue != null && _selectedValue[:valid]){
				drawRectangleDataBar(dc, _selectedValue[:currentData], _selectedValue[:dataMaxValue], _selectedValue[:barColor]);
			}
		}
	}
    
	//! Draw the data bar for the round watchfaces
	//! @param dc Device Content
	//! @param actualValue the current value of the data
	//! @param maxValue the maximum value of the data
	//! @param color the color of the bar
    (:roundShape)    
    private function drawRoundDataBar(dc as DC, actualValue as Number, maxValue as Number, color as Number) as Void {
    	// Do not draw if error occurs in the data
		if (actualValue == -1) {
    		return;
    	}
    	
    	var x = dc.getWidth() / 2;
    	var y = dc.getHeight() / 2;
    	var actualDegree = getDegreeForActualValue(actualValue, maxValue);
    	var width = _dataBarWidth;
    	var radius = 0;
    	
		// The outer circle has to be wider because the middle x, y coordinates are not exactly in the middle of the screen
    	if (_side == DATABAR_OUTER_LEFT_TOP) {
    		width += 4;
    		radius =  x - _dataBarWidth / 2 + 2;
    	} else if (_side == DATABAR_INNER_RIGHT_BOTTOM) {
    		radius =  x - width / 2 - width - 2;
    	}
    	
    	if (actualValue != 0) {
			// Draw data bar and unfilled part
			dc.setPenWidth(width);
			selectActualDataBarColor(dc, color);
						
			if (actualValue < maxValue) {
				// draw actual value
				dc.drawArc(
					x, 
					y, 
					radius, 
					Graphics.ARC_CLOCKWISE, 
					90, 
					actualDegree
				);
			} else {
				dc.drawCircle(
					x,
					y,
					radius
				);
			}

			// Split the Round databar to 10 parts
			if (dataBarSplit == DATABAR_SPLIT_ALL || (dataBarSplit == DATABAR_SPLIT_OUTER_LEFT_TOP && _side == DATABAR_OUTER_LEFT_TOP) ||
				(dataBarSplit == DATABAR_SPLIT_INNER_RIGHT_BOTTOM && _side == DATABAR_INNER_RIGHT_BOTTOM)) {
				dc.setPenWidth(width + 1);
				dc.setColor(themeColors[:backgroundColor], themeColors[:backgroundColor]);
				for (var i = 342; i > 0; i -= 36) {
					dc.drawArc(
						x, 
						y, 
						radius, 
						Graphics.ARC_CLOCKWISE, 
						i+1, 
						i
					);
				}
			}
        } 			
    }
   
   	//! Get degree for actual value on a round watchface
	//! @param actual the current value of the data
	//! @param max the maximum value of the data
	//! @return the degree according to the current value
   	(:roundShape) 
	private function getDegreeForActualValue(actual, max) as Number {
    	if (actual >= max) {
    		return 90; //max value is at 90 degrees
    	}
    	
    	var unitMeasure = 360.0 / max;
    	return ((-1 * unitMeasure * actual) + 90).toNumber() % 360;
    }
    
	//! Draw the data bar for the semiround watchfaces
	//! @param dc Device Content
	//! @param actualValue the current value of the data
	//! @param maxValue the maximum value of the data
	//! @param color the color of the bar
    (:semiroundShape)   
    private function drawSemiRoundDataBar(dc as DC, actualValue as Number, maxValue as Number, color as Number) as Void {
    	// Do not draw if error occurs in the data
		if (actualValue == -1) {
    		return;
    	}
    	
    	var x = dc.getWidth() / 2;
    	var y = dc.getHeight() / 2;
    	var width = _dataBarWidth + 2;
    	var radius =  x - width / 4;
    	
    	// angleCorrection needed because with semiround shape only the corner of arc touches the top/bottom side
		// plus degrees have to be added
    	var angleCorrection = dc.getHeight() / 30;
    	
		// Currently at 2021.08.19 all semi-round watches have the 215 x 180 screen size
		// Angles calculated for that
    	var startAngle = _side == DATABAR_OUTER_LEFT_TOP ? 236 + angleCorrection : 305 - angleCorrection;
    	var endAngle = _side == DATABAR_OUTER_LEFT_TOP ? 124 - angleCorrection : 57 + angleCorrection;
    	var actualAngle = getDegreeForActualValueSemi(actualValue, maxValue, startAngle, endAngle, angleCorrection);
    	var arcRotation = _side == DATABAR_OUTER_LEFT_TOP ? Graphics.ARC_CLOCKWISE : Graphics.ARC_COUNTER_CLOCKWISE;
    	
    	dc.setPenWidth(width);
    	// draw dataBar progress only if the start and actual angles are not the same
    	if ((_side == DATABAR_OUTER_LEFT_TOP && actualAngle < startAngle) || 
    		(_side == DATABAR_INNER_RIGHT_BOTTOM && ((actualAngle >= 0 && actualAngle < 90) || actualAngle > startAngle))
    	) {
	    	// actual progress
			selectActualDataBarColor(dc, color);
	        dc.drawArc(
	        	x, 
	        	y, 
	        	radius, 
	        	arcRotation, 
	        	startAngle, 
	        	actualAngle
	        );
        }

		// Split the semi round databar to 5 parts
		if (dataBarSplit == DATABAR_SPLIT_ALL || (dataBarSplit == DATABAR_SPLIT_OUTER_LEFT_TOP && _side == DATABAR_OUTER_LEFT_TOP) ||
			(dataBarSplit == DATABAR_SPLIT_INNER_RIGHT_BOTTOM && _side == DATABAR_INNER_RIGHT_BOTTOM)) {
			dc.setColor(themeColors[:backgroundColor], themeColors[:backgroundColor]);
			if (_side == DATABAR_OUTER_LEFT_TOP) {
				for (var i = 236 + angleCorrection; i > 124 - angleCorrection; i -= (22 + angleCorrection / 2)) {
					dc.drawArc(
						x, 
						y, 
						radius, 
						Graphics.ARC_CLOCKWISE, 
						i, 
						i-1
					);
				}
			} else {
				for (var i = 56 + angleCorrection; i > -55 - angleCorrection; i -= (22 + angleCorrection / 2)) {
					var imod = i % 360;
					dc.drawArc(
						x, 
						y, 
						radius, 
						Graphics.ARC_CLOCKWISE, 
						imod, 
						imod-1
					);
				}
			}
		}
    }
    
	//! Get degree for actual value on a semiround watchface
	//! @param actual the current value of the data
	//! @param max the maximum value of the data
	//! @param startAngle the start angle of data bar
	//! @param endAngle the end angle of data bar
	//! @param angleCorrection plus degree needed because with semiround shape only the corner of arc touches the top/bottom side
	//! @return the degree according to the current value
    (:semiroundShape)
	private function getDegreeForActualValueSemi(actual, max, startAngle, endAngle, angleCorrection) {
    	if (actual >= max) {
    		return endAngle;
    	}
    	
		// Currently at 2021.08.19 all semi-round watches have the 215 x 180 screen size
		// Angles calculated for that (eg. the 112.0)
    	var unitMeasure = (112.0 + angleCorrection * 2) / max;
    	var plusAngle = _side == DATABAR_OUTER_LEFT_TOP ? startAngle : (-endAngle);
    	var arcDirection = _side == DATABAR_OUTER_LEFT_TOP ? (-1) : 1;
    	return (((arcDirection * unitMeasure * actual) + plusAngle).toNumber() + 360) % 360;
    }
    
	//! Draw the data bar for the rectangle watchfaces
	//! @param dc Device Content
	//! @param actualValue the current value of the data
	//! @param maxValue the maximum value of the data
	//! @param color the color of the bar
    (:rectangleShape)
    private function drawRectangleDataBar(dc as DC, actualValue as Number, maxValue as Number, color as Number) {
    	// Do not draw if error occurs in the data
		if (actualValue == -1) {
    		return;
    	}

		var percentFilled = actualValue < maxValue ? (actualValue.toFloat() / maxValue) : 1;

		// An extra pixel is needed for some rectangle watches to prevent a pixel space
		var extraPixel = actualValue.toDouble() == 0.0 ? 0 : 1;
    	
    	var x = 0;
    	var y = 0;
    	var barWidth = 0;
    	var barHeight = 0;
		var screenWidth = dc.getWidth();
    	var screenHeight = dc.getHeight();

    	// calculate x, y, width, height for fillRectangle
    	if (screenHeight <= screenWidth) {
	    	barWidth = _dataBarWidth;
			y = screenHeight - screenHeight * percentFilled;
			barHeight = screenHeight - y + extraPixel;
	    		
			if (_side == DATABAR_INNER_RIGHT_BOTTOM) {
	    		x = screenWidth - barWidth;
	    	}

    	} else {
    		// Currently at 2021.08.19 only the vivoactive HR
	    	barHeight = _dataBarWidth;
			barWidth = screenWidth * percentFilled + extraPixel;
	    		
			if (_side == DATABAR_INNER_RIGHT_BOTTOM) {
	    		y = screenHeight - barHeight;
	    	}
    	}
    	
		// Fill data bar
    	selectActualDataBarColor(dc, color);
    	dc.fillRectangle(x, y, barWidth, barHeight);

		// Split the rectangle databar to 4 parts
		if (dataBarSplit == DATABAR_SPLIT_ALL || (dataBarSplit == DATABAR_SPLIT_OUTER_LEFT_TOP && _side == DATABAR_OUTER_LEFT_TOP) ||
			(dataBarSplit == DATABAR_SPLIT_INNER_RIGHT_BOTTOM && _side == DATABAR_INNER_RIGHT_BOTTOM)) {
			dc.setColor(themeColors[:backgroundColor], themeColors[:backgroundColor]);
			if (screenHeight <= screenWidth) {
				for (var i = screenHeight - screenHeight / 4; i > 0; i -= screenHeight / 4) {
					dc.fillRectangle(x, i, barWidth, 2);
				}
			} else {
				for (var i = screenWidth - screenWidth / 4; i > 0; i -= screenWidth / 4) {
					dc.fillRectangle(i, y, 2, barHeight);
				}				
			}
		}
    }

	//! Select the databar color according to the theme and side
	//! @param dc Device Content
	//! @param color the color of the bar
	private function selectActualDataBarColor(dc as DC, color as Number) as Void {
		if (_side == DATABAR_INNER_RIGHT_BOTTOM && !themeColors[:isColorful]) {
			dc.setColor(themeColors[:foregroundSecondaryColor], themeColors[:backgroundColor]);			
		} else if (_side == DATABAR_OUTER_LEFT_TOP && !themeColors[:isColorful]) {
			dc.setColor(themeColors[:foregroundPrimaryColor], themeColors[:backgroundColor]);
		} else {
			dc.setColor(color, themeColors[:backgroundColor]);
		}
	}
}
