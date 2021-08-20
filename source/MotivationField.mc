import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;

// Extend text to set as drawable text
class MotivationField extends WatchUi.Text {

	private var hardcodedMotivationalQuotes = [
		"Go hard or go home!",
		"Be the best you can be!",
		"Yesterday you said tomorrow"
	];
	
	//! Constructor
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
				motivationSecondPart = motivation.substring(firstVerticalLineIndex, secondVerticalLineIndex + 1);
				motivationThirdPart = motivation.substring(secondVerticalLineIndex + 1, motivationLength);
			}
			return [motivationFirstPart, motivationSecondPart, motivationThirdPart];
		}
    	
		// Split automatically with spaces and length

    	var motivationLengthInPixels = dc.getTextWidthInPixels(motivation, smallFont);
    	var screenWidth = dc.getWidth();
    	
    	//percent of line that is useful (out of range for the data bars)
    	var firstLineWidthPercent = 0.78;
    	var secondLineWidthPercent = 0.67;
    	var thirdLineWidthPercent = 0.47;
    	
    	var maxTextLength = screenWidth * firstLineWidthPercent + screenWidth * secondLineWidthPercent + screenWidth * thirdLineWidthPercent;
    	
    	var firstMiddleSpaceIndex = null;
    	var secondMiddleSpaceIndex = null;
    	
    	if (dc.getTextWidthInPixels(motivation, smallFont) <= screenWidth * secondLineWidthPercent * 0.90) {
    		motivationSecondPart = motivation;
    	} else if (dc.getTextWidthInPixels(motivation, smallFont) <= maxTextLength) {
 	    	// split text at 0.50 and 1.00 and find first spaces
			// if not found it goes back with some characters
 	    	var firstSplitPart = 0.50;
 	    	var secondSplitPart = 1.00;
 	    	
 	    	do {
		    	motivationSecondPart = motivation.substring(Math.ceil(motivationLength * firstSplitPart), motivationLength); 
				firstMiddleSpaceIndex = motivationSecondPart.find(" ");
				if (firstMiddleSpaceIndex != null) {
					firstMiddleSpaceIndex = motivationSecondPart.find(" ") + Math.ceil(motivationLength * firstSplitPart);
					motivationFirstPart = motivation.substring(0, firstMiddleSpaceIndex);
				}
		    	firstSplitPart -= 0.03;
	    	} while (dc.getTextWidthInPixels(motivationFirstPart, smallFont) >= screenWidth * firstLineWidthPercent);
	    	
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
			    }			 
			    secondSplitPart -= 0.03;
			    
			} while (dc.getTextWidthInPixels(motivationSecondPart, smallFont) >= screenWidth * secondLineWidthPercent);
			
	  		if (dc.getTextWidthInPixels(motivationThirdPart, smallFont) >= screenWidth * thirdLineWidthPercent) {
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
	
	//! Get a random motivational quote 
	//! return a random quote from the list hard coded
	static function getRandomHardcodedMotivationalQuote() as String {
		var randomIndex = Math.rand() % hardcodedMotivationalQuotes.length;
		return hardcodedMotivationalQuotes[randomIndex];
	}
	
}