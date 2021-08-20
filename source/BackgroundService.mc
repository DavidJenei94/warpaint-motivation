import Toybox.Background;
import Toybox.System;
import Toybox.Communications;

(:background)
class BackgroundService extends System.ServiceDelegate {
	
	//! Constructor
	function initialize() {
		System.ServiceDelegate.initialize();
	}
	
	//! Get a motivational quote by temporal event
	function onTemporalEvent() as Void {
		System.println("onTemporalEvent");
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
		};

		Communications.makeWebRequest(
			"https://script.google.com/macros/s/AKfycbyXupQFDzCRwSmXoiGv3kI3Y58Q240FFmuQPAXzoqtu4RXKgZu8IfVFJTrqvZIbCQ7G/exec", 
			{}, 
			options, 
			method(:recieveMotivationalQuote)
		);
	
	}
	
	//! Called by temporal event which send the data to the app
	function recieveMotivationalQuote(responseCode, data) as Void {

		// HTTP failure: return responseCode.
		// Otherwise, return data response.
		if (responseCode != 200) {
			data = responseCode;
			System.println("HTTP error: " + responseCode);
		}

		Background.exit({
			"motivationalQuote" => data
		});
	}
}
