import Toybox.WatchUi;

// Extend text to set as drawable text
class MotivationField extends WatchUi.Text {

	private var _motivationPartText as String;
	private var _lineWidth as Double;

	//! Constructor
	//! @param params in the layout.xml the drawable object's param tags
	function initialize(params) {
		Text.initialize(params);
		_lineWidth = params[:lineWidth];
	}

	//! Draw Motivational quote part to Text field
	//! @param dc Device Content
	function draw(dc as Dc) as Void {
		drawMotivationText(dc);
	}
	
	//! Draw motivational quote
	//! @param dc Device Content
	private function drawMotivationText(dc as Dc) as Void {		
        self.setColor(themeColors[:foregroundPrimaryColor]);
        self.setText(_motivationPartText);
		Text.draw(dc);
	}

	//! Set Motivational Quote Part
	//! @param motivationPartText the part of the splitted motivational quote
	function setMotivationPartText(motivationPartText as String) as Void {
		_motivationPartText = motivationPartText;
	}

	//! Get max line width percent of the current motivation line
	//! @return line width percent
	function getLineWidth() as Float {
		return _lineWidth;
	}
}