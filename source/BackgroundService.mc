import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Application.Storage;
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

		var motivationalQuoteArraySize = null;
		if (Toybox.Application has :Storage) {
            motivationalQuoteArraySize = Storage.getValue("MotivationalQuoteArraySize");
		} else {
            motivationalQuoteArraySize = getApp().getProperty("MotivationalQuoteArraySize");
		}

		if (motivationalQuoteArraySize == null) {
			motivationalQuoteArraySize = 0;
		}

		var motivationalQuoteArrayMaxSize = 5;
		if (motivationalQuoteArraySize < motivationalQuoteArrayMaxSize) {
			var options = {
				:method => Communications.HTTP_REQUEST_METHOD_GET,
				:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
			};
			var motivationalQuoteNo = motivationalQuoteArrayMaxSize - motivationalQuoteArraySize;
			Communications.makeWebRequest(
				"https://script.google.com/macros/s/AKfycbxsyX-_TLgm9GKgUueu6z9vGrOOSRCLlxd3ITx6ptYRcNv8Mgq_PTYmsWatKfHlWMEO/exec", 
				{"motivationalQuoteNo" => motivationalQuoteNo}, 
				options, 
				method(:recieveMotivationalQuote)
			);
		}
	
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
