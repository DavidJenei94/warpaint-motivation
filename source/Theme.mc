
class Theme {

    //! Set forground and backgorund colors for themes
    static function selectThemeColors() as Void {
		// Themes are split to save memory on 8-16 colors devices
		if (theme < 50) {
			selectBasicTheme();
		} else  if (theme >= 50 && theme < 200) {
			selectStandardTheme();
		} else if (theme >= 200) {
			selectExtraTheme();
		}

		setFixedColors();
    }  

	//! Set the fixed colors like the background of the dark and light themes
	//! and the secondary color of the normal themes
	static private function setFixedColors() as Void {
		if (theme % 5 == 0) {
			themeColors[:backgroundColor] = 0x000000;
		} else if (theme % 5 == 1) {
			themeColors[:backgroundColor] = 0xFFFFFF;
		} else if (theme % 5 == 2) {
			themeColors[:foregroundSecondaryColor] = themeColors[:foregroundPrimaryColor];
		}
	}

	//! Set forground and backgorund colors for basic themes
    (:basicThemes)
	static private function selectBasicTheme() as Void {
	
		themeColors[:isColorful] = theme == 3 || theme == 4 ? true : false;
		
		//Themes
		switch (theme) {
			case 0: // Class (Dark)
			case 3: // Class (Dark - Colorful)
				themeColors[:foregroundPrimaryColor] = 0xFFFFFF;
				themeColors[:foregroundSecondaryColor] = 0xFFFFFF;
				themeColors[:backgroundColor] = 0x000000;
				break;
			case 1: // Class (Light)
			case 4: // Class (Light - Colorful)
				themeColors[:foregroundPrimaryColor] = 0x000000;
				themeColors[:foregroundSecondaryColor] = 0x000000;
				themeColors[:backgroundColor] = 0xFFFFFF;
				break;
			case 5: // Conquest (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFF0000;
				themeColors[:foregroundSecondaryColor] = 0xFFFFFF;
				break;
			case 6: // Conquest (Light)
				themeColors[:foregroundPrimaryColor] = 0xFF0000;
				themeColors[:foregroundSecondaryColor] = 0x000000;
				break;
			case 7: // Conquest
				themeColors[:foregroundPrimaryColor] = 0xFF0000;
				themeColors[:backgroundColor] = 0xFFFFFF;
				break;
			case 10: // Essence (Dark)
				themeColors[:foregroundPrimaryColor] = 0x00FF00;
				themeColors[:foregroundSecondaryColor] = 0xFFFFFF;
				break;
			case 11: // Essence (Light)
				themeColors[:foregroundPrimaryColor] = 0x00FF00;
				themeColors[:foregroundSecondaryColor] = 0x000000;
				break;
			case 12: // Essence
				themeColors[:foregroundPrimaryColor] = 0x00FF00;
				themeColors[:backgroundColor] = 0x000000;
				break;
			case 15: // Passion (Dark)
				themeColors[:foregroundPrimaryColor] = 0x0000FF;
				themeColors[:foregroundSecondaryColor] = 0xFFFFFF;
				break;
			case 16: // Passion (Light)
				themeColors[:foregroundPrimaryColor] = 0x0000FF;
				themeColors[:foregroundSecondaryColor] = 0x000000;
				break;
			case 17: // Passion
				themeColors[:foregroundPrimaryColor] = 0x0000FF;
				themeColors[:backgroundColor] = 0xFFFFFF;
				break;
			case 20: // Liberty (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFAA00;
				themeColors[:foregroundSecondaryColor] = 0xFFFFFF;
				break;
			case 21: // Liberty (Light)
				themeColors[:foregroundPrimaryColor] = 0xFFAA00;
				themeColors[:foregroundSecondaryColor] = 0x000000;
				break;
			case 22: // Liberty
				themeColors[:foregroundPrimaryColor] = 0xFFAA00;
				themeColors[:backgroundColor] = 0x000000;
				break;
			case 25: // Princess (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFF00FF;
				themeColors[:foregroundSecondaryColor] = 0xFFFFFF;
				break;
			case 26: // Princess (Light)
				themeColors[:foregroundPrimaryColor] = 0xFF00FF;
				themeColors[:foregroundSecondaryColor] = 0x000000;
				break;
			case 27: // Princess
				themeColors[:foregroundPrimaryColor] = 0xFF00FF;
				themeColors[:backgroundColor] = 0x000000;
				break;
			case 30: // Rule (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFF0000;
				themeColors[:foregroundSecondaryColor] = 0x0000FF;
				break;
			case 31: // Rule (Light)
				themeColors[:foregroundPrimaryColor] = 0x0000FF;
				themeColors[:foregroundSecondaryColor] = 0xFF0000;
				break;
			case 32: // Rule
				themeColors[:foregroundPrimaryColor] = 0xFF0000;
				themeColors[:backgroundColor] = 0x0000FF;
				break;
			case 35: // Sensation (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFF00FF;
				themeColors[:foregroundSecondaryColor] = 0x00FF00;
				break;
			case 36: // Sensation (Light)
				themeColors[:foregroundPrimaryColor] = 0xFF00FF;
				themeColors[:foregroundSecondaryColor] = 0x00FF00;
				break;
			case 37: // Sensation
				themeColors[:foregroundPrimaryColor] = 0x00FF00;
				themeColors[:backgroundColor] = 0xFF00FF;
				break;
			case 40: // Freezing (Dark)
				themeColors[:foregroundPrimaryColor] = 0x00FFFF;
				themeColors[:foregroundSecondaryColor] = 0x0000FF;
				break;
			case 41: // Freezing (Light)
				themeColors[:foregroundPrimaryColor] = 0x00FFFF;
				themeColors[:foregroundSecondaryColor] = 0x0000FF;
				break;
			case 42: // Freezing
				themeColors[:foregroundPrimaryColor] = 0x00FFFF;
				themeColors[:backgroundColor] = 0x0000FF;
				break;
		}
	}

	//! Set forground and backgorund colors for standard themes
    (:standardThemes)
	static private function selectStandardTheme() as Void {
	
		themeColors[:isColorful] = false;
		
		//Themes
		switch (theme) {
			case 50: // Blooming (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFAAAA;
				themeColors[:foregroundSecondaryColor] = 0x5555AA;
				break;
			case 51: // Blooming (Light)
				themeColors[:foregroundPrimaryColor] = 0xFFAAAA;
				themeColors[:foregroundSecondaryColor] = 0x5555AA;
				break;
			case 52: // Blooming
				themeColors[:foregroundPrimaryColor] = 0x5555AA;
				themeColors[:backgroundColor] = 0xFFAAAA;
				break;
			case 56: // Elegant (Light)
				themeColors[:foregroundPrimaryColor] = 0x000055;
				themeColors[:foregroundSecondaryColor] = 0x55FFFF;
				break;
			case 57: // Elegant
				themeColors[:foregroundPrimaryColor] = 0x000055;
				themeColors[:backgroundColor] = 0x55FFFF;
				break;
			case 60: // Bubblegum (Dark)
				themeColors[:foregroundPrimaryColor] = 0x55FF55;
				themeColors[:foregroundSecondaryColor] = 0xFF55AA;
				break;
			case 61: // Bubblegum (Light)
				themeColors[:foregroundPrimaryColor] = 0xFF55AA;
				themeColors[:foregroundSecondaryColor] = 0x55FF55;
				break;
			case 62: // Bubblegum
				themeColors[:foregroundPrimaryColor] = 0xFF55AA;
				themeColors[:backgroundColor] = 0x55FF55;
				break;
			case 65: // Savage (Dark)
				themeColors[:foregroundPrimaryColor] = 0x0055AA;
				themeColors[:foregroundSecondaryColor] = 0xAA0055;
				break;
			case 66: // Savage (Light)
				themeColors[:foregroundPrimaryColor] = 0xAA0055;
				themeColors[:foregroundSecondaryColor] = 0x0055AA;
				break;
			case 70: // Trust (Dark)
				themeColors[:foregroundPrimaryColor] = 0x0055AA;
				themeColors[:foregroundSecondaryColor] = 0xAAAAAA;
				break;
			case 71: // Trust (Light)
				themeColors[:foregroundPrimaryColor] = 0x0055AA;
				themeColors[:foregroundSecondaryColor] = 0xAAAAAA;
				break;
			case 72: // Trust
				themeColors[:foregroundPrimaryColor] = 0x0055AA;
				themeColors[:backgroundColor] = 0xAAAAAA;
				break;
			case 75: // Imagination (Dark)
				themeColors[:foregroundPrimaryColor] = 0x5555AA;
				themeColors[:foregroundSecondaryColor] = 0xAAFFFF;
				break;
			case 77: // Imagination
				themeColors[:foregroundPrimaryColor] = 0x5555AA;
				themeColors[:backgroundColor] = 0xAAFFFF;
				break;
			case 80: // Nature (Dark)
				themeColors[:foregroundPrimaryColor] = 0x00AA55;
				themeColors[:foregroundSecondaryColor] = 0xFFFFFF;
				break;
			case 81: // Nature (Light)
				themeColors[:foregroundPrimaryColor] = 0x00AA55;
				themeColors[:foregroundSecondaryColor] = 0x000000;
				break;
			case 82: // Nature
				themeColors[:foregroundPrimaryColor] = 0xFFFFFF;
				themeColors[:backgroundColor] = 0x00AA55;
				break;
			case 85: // Lust (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFAAAA;
				themeColors[:foregroundSecondaryColor] = 0x555555;
				break;
			case 86: // Lust (Light)
				themeColors[:foregroundPrimaryColor] = 0xFFAAAA;
				themeColors[:foregroundSecondaryColor] = 0x555555;
				break;
			case 87: // Lust
				themeColors[:foregroundPrimaryColor] = 0x555555;
				themeColors[:backgroundColor] = 0xFFAAAA;
				break;
			case 90: // Sweet (Dark)
				themeColors[:foregroundPrimaryColor] = 0xAA5555;
				themeColors[:foregroundSecondaryColor] = 0xFFAAAA;
				break;
			case 91: // Sweet (Light)
				themeColors[:foregroundPrimaryColor] = 0xAA5555;
				themeColors[:foregroundSecondaryColor] = 0xFFAAAA;
				break;
			case 92: // Sweet
				themeColors[:foregroundPrimaryColor] = 0xFFAAAA;
				themeColors[:backgroundColor] = 0xAA5555;
				break;
			case 95: // Moonlight (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFFF55;
				themeColors[:foregroundSecondaryColor] = 0x0055AA;
				break;
			case 97: // Moonlight
				themeColors[:foregroundPrimaryColor] = 0xFFFF55;
				themeColors[:backgroundColor] = 0x0055AA;
				break;
			case 100: // Luxury (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFF55AA;
				themeColors[:foregroundSecondaryColor] = 0xFFFF00;
				break;
			case 102: // Luxury
				themeColors[:foregroundPrimaryColor] = 0xFF55AA;
				themeColors[:backgroundColor] = 0xFFFF00;
				break;
			case 105: // Captivating (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFF5500;
				themeColors[:foregroundSecondaryColor] = 0xFFFF00;
				break;
			case 107: // Captivating
				themeColors[:foregroundPrimaryColor] = 0xFF5500;
				themeColors[:backgroundColor] = 0xFFFF00;
				break;
			case 110: // Christmas (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFF0000;
				themeColors[:foregroundSecondaryColor] = 0x55AAAA;
				break;
			case 111: // Christmas (Light)
				themeColors[:foregroundPrimaryColor] = 0xFF0000;
				themeColors[:foregroundSecondaryColor] = 0x55AAAA;
				break;
			case 112: // Christmas
				themeColors[:foregroundPrimaryColor] = 0xFF0000;
				themeColors[:backgroundColor] = 0x55AAAA;
				break;
			case 115: // Cheerful (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFAA00;
				themeColors[:foregroundSecondaryColor] = 0x555555;
				break;
			case 116: // Cheerful (Light)
				themeColors[:foregroundPrimaryColor] = 0x555555;
				themeColors[:foregroundSecondaryColor] = 0xFFAA00;
				break;
			case 117: // Cheerful
				themeColors[:foregroundPrimaryColor] = 0x555555;
				themeColors[:backgroundColor] = 0xFFAA00;
				break;
			case 120: // Rapture (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFF0055;
				themeColors[:foregroundSecondaryColor] = 0xFF55AA;
				break;
			case 121: // Rapture (Light)
				themeColors[:foregroundPrimaryColor] = 0xFF55AA;
				themeColors[:foregroundSecondaryColor] = 0xFF0055;
				break;
			case 122: // Rapture
				themeColors[:foregroundPrimaryColor] = 0xFF55AA;
				themeColors[:backgroundColor] = 0xFF0055;
				break;
			case 125: // Wilderness (Dark)
				themeColors[:foregroundPrimaryColor] = 0x005500;
				themeColors[:foregroundSecondaryColor] = 0xAAAA55;
				break;
			case 126: // Wilderness (Light)
				themeColors[:foregroundPrimaryColor] = 0x005500;
				themeColors[:foregroundSecondaryColor] = 0xAAAA55;
				break;
			case 127: // Wilderness
				themeColors[:foregroundPrimaryColor] = 0x005500;
				themeColors[:backgroundColor] = 0xAAAA55;
				break;
			case 130: // Nebula (Dark)
				themeColors[:foregroundPrimaryColor] = 0x555555;
				themeColors[:foregroundSecondaryColor] = 0xAA55AA;
				break;
			case 131: // Nebula (Light)
				themeColors[:foregroundPrimaryColor] = 0xAA55AA;
				themeColors[:foregroundSecondaryColor] = 0x555555;
				break;
			case 132: // Nebula
				themeColors[:foregroundPrimaryColor] = 0xAA55AA;
				themeColors[:backgroundColor] = 0xAAAAAA;
				break;
		}
	}

	//! Set forground and backgorund colors for extra themes
    (:extraThemes)
	static private function selectExtraTheme() as Void {
	
		themeColors[:isColorful] = false;
		
		//Themes
		switch (theme) {
			case 200: // Copper (Dark)
				themeColors[:foregroundPrimaryColor] = 0xAA5555;
				themeColors[:foregroundSecondaryColor] = 0x55AAFF;
				break;
			case 201: // Copper (Light)
				themeColors[:foregroundPrimaryColor] = 0xAA5555;
				themeColors[:foregroundSecondaryColor] = 0x55AAFF;
				break;
			case 202: // Copper
				themeColors[:foregroundPrimaryColor] = 0x55AAFF;
				themeColors[:backgroundColor] = 0xAA5555;
				break;
			case 205: // Breeze (Dark)
				themeColors[:foregroundPrimaryColor] = 0x55FFFF;
				themeColors[:foregroundSecondaryColor] = 0xAAAAAA;
				break;
			case 206: // Breeze (Light)
				themeColors[:foregroundPrimaryColor] = 0xAAAAAA;
				themeColors[:foregroundSecondaryColor] = 0x55FFFF;
				break;
			case 207: // Breeze
				themeColors[:foregroundPrimaryColor] = 0x55FFFF;
				themeColors[:backgroundColor] = 0x555555;
				break;						
			case 210: // Adventure (Dark)
				themeColors[:foregroundPrimaryColor] = 0x00AAAA;
				themeColors[:foregroundSecondaryColor] = 0xFF5500;
				break;
			case 211: // Adventure (Light)
				themeColors[:foregroundPrimaryColor] = 0x00AAAA;
				themeColors[:foregroundSecondaryColor] = 0xFF5500;
				break;
			case 215: // Inspiration (Dark)
				themeColors[:foregroundPrimaryColor] = 0x0055AA;
				themeColors[:foregroundSecondaryColor] = 0xAAFFFF;
				break;
			case 217: // Inspiration
				themeColors[:foregroundPrimaryColor] = 0xAAFFFF;
				themeColors[:backgroundColor] = 0x0055AA;
				break;						
			case 220: // Illumination (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFFF55;
				themeColors[:foregroundSecondaryColor] = 0xAAAAAA;
				break;
			case 222: // Illumination
				themeColors[:foregroundPrimaryColor] = 0xFFFF55;
				themeColors[:backgroundColor] = 0x555555;
				break;
			case 225: // Coast (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFF5555;
				themeColors[:foregroundSecondaryColor] = 0x55AAFF;
				break;
			case 226: // Coast (Light)
				themeColors[:foregroundPrimaryColor] = 0x55AAFF;
				themeColors[:foregroundSecondaryColor] = 0xFF5555;
				break;
			case 227: // Coast
				themeColors[:foregroundPrimaryColor] = 0xFF5555;
				themeColors[:backgroundColor] = 0x55AAFF;
				break;						
			case 230: // Freedom (Dark)
				themeColors[:foregroundPrimaryColor] = 0x55AAFF;
				themeColors[:foregroundSecondaryColor] = 0xFFFFFF;
				break;
			case 231: // Freedom (Light)
				themeColors[:foregroundPrimaryColor] = 0x55AAFF;
				themeColors[:foregroundSecondaryColor] = 0x000000;
				break;
			case 232: // Freedom
				themeColors[:foregroundPrimaryColor] = 0x55AAFF;
				themeColors[:backgroundColor] = 0xFFFFFF;
				break;
			case 235: // Grace (Dark)
				themeColors[:foregroundPrimaryColor] = 0xAAAAAA;
				themeColors[:foregroundSecondaryColor] = 0xFFAA55;
				break;
			case 236: // Grace (Light)
				themeColors[:foregroundPrimaryColor] = 0xAAAAAA;
				themeColors[:foregroundSecondaryColor] = 0xFFAA55;
				break;
			case 237: // Grace
				themeColors[:foregroundPrimaryColor] = 0xFFAA55;
				themeColors[:backgroundColor] = 0x555555;
				break;						
			case 240: // Exuberance (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFF5500;
				themeColors[:foregroundSecondaryColor] = 0xFFFFFF;
				break;
			case 241: // Exuberance (Light)
				themeColors[:foregroundPrimaryColor] = 0xFF5500;
				themeColors[:foregroundSecondaryColor] = 0x000000;
				break;
			case 242: // Exuberance
				themeColors[:foregroundPrimaryColor] = 0xFF5500;
				themeColors[:backgroundColor] = 0xFFFFFF;
				break;
			case 245: // Vitality (Dark)
				themeColors[:foregroundPrimaryColor] = 0x005555;
				themeColors[:foregroundSecondaryColor] = 0x555555;
				break;
			case 246: // Vitality (Light)
				themeColors[:foregroundPrimaryColor] = 0x555555;
				themeColors[:foregroundSecondaryColor] = 0x005555;
				break;
			case 247: // Vitality
				themeColors[:foregroundPrimaryColor] = 0x555555;
				themeColors[:backgroundColor] = 0x005555;
				break;						
			case 250: // Cozy (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFAAAA;
				themeColors[:foregroundSecondaryColor] = 0xFFAA55;
				break;
			case 251: // Cozy (Light)
				themeColors[:foregroundPrimaryColor] = 0xFFAA55;
				themeColors[:foregroundSecondaryColor] = 0xFFAAAA;
				break;
			case 255: // Verdant (Dark)
				themeColors[:foregroundPrimaryColor] = 0x005500;
				themeColors[:foregroundSecondaryColor] = 0xFFFFAA;
				break;
			case 257: // Verdant
				themeColors[:foregroundPrimaryColor] = 0x005500;
				themeColors[:backgroundColor] = 0xFFFFAA;
				break;						
			case 260: // Excitement (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFFF55;
				themeColors[:foregroundSecondaryColor] = 0x550055;
				break;
			case 262: // Excitement
				themeColors[:foregroundPrimaryColor] = 0xFFFF55;
				themeColors[:backgroundColor] = 0x550055;
				break;
			case 265: // Stimulation (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFFFFF;
				themeColors[:foregroundSecondaryColor] = 0xAA0000;
				break;
			case 266: // Stimulation (Light)
				themeColors[:foregroundPrimaryColor] = 0x000000;
				themeColors[:foregroundSecondaryColor] = 0xAA0000;
				break;
			case 267: // Stimulation
				themeColors[:foregroundPrimaryColor] = 0xFFFFFF;
				themeColors[:backgroundColor] = 0xAA0000;
				break;						
			case 270: // Blazing (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFFF00;
				themeColors[:foregroundSecondaryColor] = 0xFFFFFF;
				break;
			case 272: // Blazing
				themeColors[:foregroundPrimaryColor] = 0x000000;
				themeColors[:backgroundColor] = 0xFFFF00;
				break;
			case 275: // Alive (Dark)
				themeColors[:foregroundPrimaryColor] = 0xFFFF00;
				themeColors[:foregroundSecondaryColor] = 0x00AAFF;
				break;
			case 277: // Alive
				themeColors[:foregroundPrimaryColor] = 0x00AAFF;
				themeColors[:backgroundColor] = 0xFFFF00;
				break;						
			case 280: // Tropical (Dark)
				themeColors[:foregroundPrimaryColor] = 0x55AA00;
				themeColors[:foregroundSecondaryColor] = 0xFFAA55;
				break;
			case 281: // Tropical (Light)
				themeColors[:foregroundPrimaryColor] = 0x55AA00;
				themeColors[:foregroundSecondaryColor] = 0xFFAA55;
				break;
			case 282: // Tropical
				themeColors[:foregroundPrimaryColor] = 0xFFAA55;
				themeColors[:backgroundColor] = 0x55AA00;
				break;					
		}
	}
}
