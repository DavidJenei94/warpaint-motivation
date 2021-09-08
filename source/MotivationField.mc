import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;

// Extend text to set as drawable text
class MotivationField extends WatchUi.Text {

	static private var hardcodedMotivationalQuotes = [
		"Go hard or go home!",
		"Be the best you can be!",
		"Yesterday you said tomorrow"
	];
	
	//! Constructor
	//! @param params in the layout.xml the drawable object's param tags
	function initialize(params) {
		Text.initialize(params);
	}
	
	//! Draw motivational quote
	//! @param dc Device Content
	//! @param motivationPartText the part of the splitted motivational quote
	function drawMotivationText(dc as Dc, motivationPartText as String) as Void {		
        self.setColor(foregroundColor);
        self.setText(motivationPartText);
		Text.draw(dc);
	}
	
	//! Split the motivational quote
	//! @param dc Device Content
	//! @param motivation the motivational quote in string
	//! @return Array of the splitted part of motivational quote
	static function splitMotivationalQuote(dc as Dc, motivation as String) as Array<String> {
		// When starting the app (until storage problem is solved)
		if (motivation == null) {
			motivation = getRandomHardcodedMotivationalQuote();
		}

		var motivationLength = motivation.length();
		var motivationFirstPart = "";
    	var motivationSecondPart = "";
    	var motivationThirdPart = "";
		
		// Split with | vertical lines
		
		var firstVerticalLineIndex = null;
    	var secondVerticalLineIndex = null;
		firstVerticalLineIndex = motivation.find("|");
		if (firstVerticalLineIndex != null) {
			motivationFirstPart = motivation.substring(0, firstVerticalLineIndex);
			motivationSecondPart = motivation.substring(firstVerticalLineIndex + 1, motivationLength); //+1 to skip the vertical line at the start of it 
			secondVerticalLineIndex = motivationSecondPart.find("|");
			if (secondVerticalLineIndex != null) {
				secondVerticalLineIndex += firstVerticalLineIndex;
				motivationSecondPart = motivation.substring(firstVerticalLineIndex + 1, secondVerticalLineIndex + 1);
				motivationThirdPart = motivation.substring(secondVerticalLineIndex + 2, motivationLength); //+2 because there are 2 vertical lines before
			}
			return [motivationFirstPart, motivationSecondPart, motivationThirdPart];
		}
    	
		// Split automatically with spaces and length

    	var motivationLengthInPixels = dc.getTextWidthInPixels(motivation, smallFont);
    	var screenWidth = dc.getWidth();
    	
    	var maxTextLength = screenWidth * firstLineWidthPercent + screenWidth * secondLineWidthPercent + screenWidth * thirdLineWidthPercent;
    	
    	var firstMiddleSpaceIndex = null;
    	var secondMiddleSpaceIndex = null;
    	
    	if (dc.getTextWidthInPixels(motivation, smallFont) <= screenWidth * secondLineWidthPercent * 0.95) {
    		motivationSecondPart = motivation;
    	} else if (dc.getTextWidthInPixels(motivation, smallFont) <= maxTextLength) {
 	    	// split text at 0.50 and 1.00 and find first spaces
			// if not found it goes back with some characters
			var firstSplitPart = 0.49;
 	    	var secondSplitPart = 1.00;
 	    	
 	    	do {
		    	motivationSecondPart = motivation.substring(Math.ceil(motivationLength * firstSplitPart), motivationLength); 
				firstMiddleSpaceIndex = motivationSecondPart.find(" ");
				if (firstMiddleSpaceIndex != null) {
					firstMiddleSpaceIndex = motivationSecondPart.find(" ") + Math.ceil(motivationLength * firstSplitPart);
					motivationFirstPart = motivation.substring(0, firstMiddleSpaceIndex);
				}

		    	firstSplitPart -= 0.03;
				if (firstSplitPart < 0) {
					break;
				}
	    	} while (dc.getTextWidthInPixels(motivationFirstPart, smallFont) >= screenWidth * firstLineWidthPercent || firstMiddleSpaceIndex == null);
	    	
	    	do {
		    	motivationThirdPart = motivation.substring(Math.ceil(motivationLength * secondSplitPart), motivationLength);
		    	secondMiddleSpaceIndex = motivationThirdPart.find(" ");
		    	if (secondMiddleSpaceIndex != null) {	    	
		    		secondMiddleSpaceIndex = motivationThirdPart.find(" ") + Math.ceil(motivationLength * secondSplitPart);
			    	motivationThirdPart = motivation.substring(secondMiddleSpaceIndex + 1, motivationLength); //+1 to skip the space at the start of it 
			    	
			    	motivationSecondPart = motivation.substring(firstMiddleSpaceIndex + 1, secondMiddleSpaceIndex);
			   } else if (firstMiddleSpaceIndex != null) {
			    	//motivationThirdPart remains empty
			    	motivationThirdPart = "";
			    	motivationSecondPart = motivation.substring(firstMiddleSpaceIndex + 1, motivationLength);
			    } else {
					motivationFirstPart = motivation.substring(0, 10) + "...";
					motivationSecondPart = "Too long word";
					motivationThirdPart = "in text";
					break;
			    }

			    secondSplitPart -= 0.03;
				if (secondSplitPart < 0) {
					break;
				}
			} while (dc.getTextWidthInPixels(motivationSecondPart, smallFont) >= screenWidth * secondLineWidthPercent);
			
			firstSplitPart = (firstSplitPart * 100).toNumber();
			secondSplitPart = (secondSplitPart * 100).toNumber();
			if (firstSplitPart == secondSplitPart) {
				motivationFirstPart = motivation.substring(0, 10) + "...";
				motivationSecondPart = "Too long word";
				motivationThirdPart = "in text";				
			} else if (dc.getTextWidthInPixels(motivationThirdPart, smallFont) >= screenWidth * thirdLineWidthPercent) {
				// too long motivational quote
				motivationThirdPart = "...";
	  		}
    	} else {
			// too long motivational quote
			motivationFirstPart = motivation.substring(0, 10) + "...";
			motivationSecondPart = "Too long";
			motivationThirdPart = "text";
  		}
    		
    	return [motivationFirstPart, motivationSecondPart, motivationThirdPart]; 
	}

	//! Set the motivational Quote
	static function setMotivationalQuote() as Void {
		var motivation = null;
		if (motivationalQuoteProperty.equals("")) {
			if (!(Toybox has :Background)) {
				motivation = MotivationField.getRandomHardcodedMotivationalQuote();
			} else {
				if (motivationalQuoteArray.size() != 0) {
					motivation = motivationalQuoteArray[motivationalQuoteArray.size() - 1];
        			motivationalQuoteArray = motivationalQuoteArray.slice(0, motivationalQuoteArray.size() - 1);
					if (Toybox.Application has :Storage) {
						Storage.setValue("MotivationalQuoteArraySize", motivationalQuoteArray.size());
					} else {
						getApp().setProperty("MotivationalQuoteArraySize", motivationalQuoteArray.size());
					}
				} 

				if (motivation == null) {
					motivation = MotivationField.getRandomHardcodedMotivationalQuote();
				}
			}
		} else {
			motivation = getUserMotivationalQuote(motivationalQuoteProperty);
		}

		motivationalQuote = motivation;

		// Does not work:
		// Same issue as https://forums.garmin.com/developer/connect-iq/i/bug-reports/strange-symbol-not-found-error
		// Save last used motivational quote in case app is restarted
		/*if (Toybox.Application has :Storage) {
			Storage.setValue("MotivationalQuote", motivation);
		} else {
			getApp().setProperty("MotivationalQuote", motivation);
		}*/
	}

	//! Get a random user defined motivational quote
	//! @param userMotivationInput the user input in the motivational field in settings
	//! @return a random quote from the user defined list
	private static function getUserMotivationalQuote(userMotivationInput as String) as String {
		var motivationArray = [];
		var separatorIndex = null;
		separatorIndex = userMotivationInput.find(";");
		if (separatorIndex != null) {
 	    	do {
				motivationArray.add(userMotivationInput.substring(0, separatorIndex));
				userMotivationInput = userMotivationInput.substring(separatorIndex + 1, userMotivationInput.length());
				separatorIndex = userMotivationInput.find(";");
	    	} while (separatorIndex != null);
			motivationArray.add(userMotivationInput);

			var randomIndex = Math.rand() % motivationArray.size();
			return motivationArray[randomIndex];
		} else {
			return userMotivationInput;
		}
	}

	//! Get a random motivational quote 
	//! @return a random quote from the list hard coded
	static function getRandomHardcodedMotivationalQuote() as String {
		var randomIndex = Math.rand() % hardcodedMotivationalQuotes.size();
		return hardcodedMotivationalQuotes[randomIndex];
	}
	
}