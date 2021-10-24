import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;

class Motivation {

    private var _splittedMotivationalQuote = new String[3];
    private var _isMotivationalQuoteSet as Boolean;
    private var _firstLineWidthPercent as Number;
    private var _secondLineWidthPercent as Number;
    private var _thirdLineWidthPercent as Number;

    private var hardcodedMotivationalQuotes = [
		"I DIDN'T COME THIS FAR TO ONLY COME THIS FAR",
		"PAIN IS TEMPORARY, BUT GREATNESS LASTS FOREVER",
		"IF IT WAS EASY EVERYBODY WOULD DO IT",
		"DON'T WAIT FOR THE OPPORTUNITY, CREATE IT",
		"IT NEVER GETS EASIER, YOU JUST GET BETTER",
		"NEVER FORGET WHY YOU STARTED",
		"GO HARD OR GO HOME",
		"BE THE BEST YOU CAN BE",
		"YESTERDAY YOU SAID TOMORROW",
		"I'M NOT A SURVIVOR, I'M A WARRIOR",
		"YOU ONLY FAIL WHEN YOU STOP TRYING",
		"IT WILL BE HARD, BUT IT WILL BE WORTH IT",
		"YOU'VE COME TOO FAR TO QUIT NOW",
		"YOU WILL WISH YOU HAD STARTED TODAY",
		"WHATEVER IT TAKES",
		"NO MORE EXCUSES",
		"DISCIPLINE SEPARATES GREAT FROM AVERAGE",
		"THE HARDER I WORK, THE LUCKIER I GET",
		"HARD WORK BEATS TALENT",
		"DON'T FORGET TO APPRECIATE WHAT YOU HAVE",
		"STRUGGLE MAKES YOU STRONGER",
		"BETTER THAN YESTERDAY",
		"STAY FOCUSED ON YOUR GOAL",
		"EVERY SINGLE DAY MATTERS",
		"YOU WERE CREATED TO DO GREAT THINGS",
		"CHAMPIONSHIP IS WON IN THE TRAINING ROOM",
		"DON'T BE AFRAID TO BE DIFFERENT",
		"TURN ON BEAST MODE",
		"NO MATTER WHAT, YOU DON'T GIVE UP",
		"NO MORE TAKING THE EASY ROAD",
		"ONLY QUITTING IS THE END",
		"NOTHING WILL BREAK ME",
		"TO GET YOUR GOAL YOU HAVE TO TAKE RISKS",
		"DISCIPLINE EQUALS FREEDOM",
		"ELIMINATE ALL THE DISTRACTIONS",
		"SACRIFICES MADE TODAY ARE GONNA PAY OFF",
		"PAIN OF DISCIPLINE OR PAIN OF REGRET",
		"BE SO GOOD NO ONE CAN IGNORE YOU",
		"IF YOU DON'T TRY, YOU WILL NEVER KNOW",
		"BECOME THE BEST VERSION OF YOU"
	];

    //! Constructor
    //! @param dc Device Content
    function initialize(dc as Dc, firstLineWidth as Number, secondLineWidth as Number, thirdLineWidth as Number) {
        _isMotivationalQuoteSet = true;
        _firstLineWidthPercent = firstLineWidth;
        _secondLineWidthPercent = secondLineWidth;
        _thirdLineWidthPercent = thirdLineWidth;
        self.splitMotivationalQuote(dc);
    }

	//! Get the splitted the motivational quote
	//! @param dc Device Content
    function getSplittedMotivationalQuote(dc as Dc) {
        return _splittedMotivationalQuote;
    }

	//! Split the motivational quote
	//! @param dc Device Content
	private function splitMotivationalQuote(dc as Dc) as Void {
        var motivation = motivationalQuote;

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
			_splittedMotivationalQuote = [motivationFirstPart, motivationSecondPart, motivationThirdPart];
		}
    	
		// Split automatically with spaces and length

    	var motivationLengthInPixels = dc.getTextWidthInPixels(motivation, smallFont);
    	var screenWidth = dc.getWidth();
    	
    	var maxTextLength = screenWidth * _firstLineWidthPercent + screenWidth * _secondLineWidthPercent + screenWidth * _thirdLineWidthPercent;
    	
    	var firstMiddleSpaceIndex = null;
    	var secondMiddleSpaceIndex = null;
    	
    	if (dc.getTextWidthInPixels(motivation, smallFont) <= screenWidth * _secondLineWidthPercent * 0.95) {
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
	    	} while (dc.getTextWidthInPixels(motivationFirstPart, smallFont) >= screenWidth * _firstLineWidthPercent || firstMiddleSpaceIndex == null);
	    	
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
					motivationFirstPart = motivation.substring(0, 15) + "...";
					motivationSecondPart = "TOO LONG WORD";
					motivationThirdPart = "IN TEXT";
					break;
			    }

			    secondSplitPart -= 0.03;
				if (secondSplitPart < 0) {
					break;
				}
			} while (dc.getTextWidthInPixels(motivationSecondPart, smallFont) >= screenWidth * _secondLineWidthPercent);
			
			firstSplitPart = (firstSplitPart * 100).toNumber();
			secondSplitPart = (secondSplitPart * 100).toNumber();
			if (firstSplitPart == secondSplitPart) {
				motivationFirstPart = motivation.substring(0, 15) + "...";
				motivationSecondPart = "TOO LONG WORD";
				motivationThirdPart = "IN TEXT";				
			} else if (dc.getTextWidthInPixels(motivationThirdPart, smallFont) >= screenWidth * _thirdLineWidthPercent) {
				// too long motivational quote
				motivationThirdPart = "...";
	  		}
    	} else {
			// too long motivational quote
			motivationFirstPart = motivation.substring(0, 15) + "...";
			motivationSecondPart = "TOO LONG";
			motivationThirdPart = "TEXT";
  		}
    		
    	_splittedMotivationalQuote = [motivationFirstPart, motivationSecondPart, motivationThirdPart]; 
	}

	//! Set the motivational Quote
	private function setMotivationalQuote() as Void {
		if (Toybox has :Background) {
			setMotivationalQuoteWithBackground();
		} else {
			setMotivationalQuoteWithoutBackground();
		}
	}

	//! Set the motivational Quote
	private function setMotivationalQuoteWithoutBackground() as Void {
		var motivation = null;
		if (motivationalQuoteProperty.equals("") || motivationalQuoteProperty.equals("auto")) {
			motivation = getRandomHardcodedMotivationalQuote();
		} else {
			motivation = getUserMotivationalQuote(motivationalQuoteProperty);
		}

		motivationalQuote = motivation;

		// Did not work before for some reason??? :
		// Same issue as https://forums.garmin.com/developer/connect-iq/i/bug-reports/strange-symbol-not-found-error
		// Save last used motivational quote in case app is restarted
		if (Toybox.Application has :Storage) {
			Storage.setValue("MotivationalQuote", motivation);
		} else {
			getApp().setProperty("MotivationalQuote", motivation);
		}
	}

	//! Set the motivational Quote
	(:background_method)
	private function setMotivationalQuoteWithBackground() as Void {
		if (Toybox.Application has :Storage) {
            motivationalQuoteArray = Storage.getValue("MotivationalQuoteArray");
        } else {
            motivationalQuoteArray = getApp().getProperty("MotivationalQuoteArray");
        }
		
		var motivation = null;
		if (motivationalQuoteProperty.equals("") || motivationalQuoteProperty.equals("auto")) {
			if (!(Toybox has :Background)) {
				motivation = getRandomHardcodedMotivationalQuote();
			} else {
				if (motivationalQuoteArray != null && motivationalQuoteArray.size() != 0) {
					motivation = motivationalQuoteArray[motivationalQuoteArray.size() - 1];
					motivationalQuoteArray = motivationalQuoteArray.slice(0, motivationalQuoteArray.size() - 1);
					if (Toybox.Application has :Storage) {
						Storage.setValue("MotivationalQuoteArray", motivationalQuoteArray);
						Storage.setValue("MotivationalQuoteArraySize", motivationalQuoteArray.size());
					} else {
						getApp().setProperty("MotivationalQuoteArray", motivationalQuoteArray);
						getApp().setProperty("MotivationalQuoteArraySize", motivationalQuoteArray.size());
					}
				}

				if (motivation == null) {
					motivation = getRandomHardcodedMotivationalQuote();
				}
			}
		} else {
			motivation = getUserMotivationalQuote(motivationalQuoteProperty);
		}

		motivationalQuote = motivation;

		// Did not work before for some reason??? :
		// Same issue as https://forums.garmin.com/developer/connect-iq/i/bug-reports/strange-symbol-not-found-error
		// Save last used motivational quote in case app is restarted
		if (Toybox.Application has :Storage) {
			Storage.setValue("MotivationalQuote", motivation);
		} else {
			getApp().setProperty("MotivationalQuote", motivation);
		}
	}

	//! Get a random user defined motivational quote
	//! @param userMotivationInput the user input in the motivational field in settings
	//! @return a random quote from the user defined list
	private function getUserMotivationalQuote(userMotivationInput as String) as String {
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
	private function getRandomHardcodedMotivationalQuote() as String {
		var randomIndex = Math.rand() % hardcodedMotivationalQuotes.size();
		return hardcodedMotivationalQuotes[randomIndex];
	}

    //! Check if Motivation needs refresh
    //! @param dc Device Content
	function checkMotivationRefresh(dc as Dc) as Void {
        // Set motivational quote
        // Interval is to change motivational quote
        // If motivational quote is null or the minute is the selected one, refresh quote
        var clockTime = System.getClockTime();
        var intervalToChangeQuote = motivationalQuoteChangeInterval > 60 ? (motivationalQuoteChangeInterval / 60) : motivationalQuoteChangeInterval;
        var remainder = motivationalQuoteChangeInterval > 60 ? clockTime.hour % intervalToChangeQuote : clockTime.min % intervalToChangeQuote;
        if (motivationalQuote == null || (!_isMotivationalQuoteSet && remainder == 0)) {
            self.setMotivationalQuote();
            self.splitMotivationalQuote(dc);
            _splittedMotivationalQuote = self.getSplittedMotivationalQuote(dc);
            _isMotivationalQuoteSet = true;
        }
        if (_isMotivationalQuoteSet && remainder != 0) {
            // Change back to false after the minute to prevent updating through every second (if not in low power mode)
            _isMotivationalQuoteSet = false;
        }
    }
}