# warpaint-motivation
A Garmin Connect IQ watch face with motivational quotes.

## Description

The Warpaint Motivation is a unique watch face which inspires you with powerful and diversified motivational quotes while showing you the most important data you need.

The Warpaint Motivation is fully free, however if you enjoy using it you can support my work with a small donation on the following link: https://paypal.me/WarpaintVision (Please mention the name of the app: "Warpaint Motivation" and choose the option "donate to a friend" for less paypal fees).

Please leave a review if you like the watch face!
In case of any issues/questions please check the following 'Warpaint Motivation (WpM) - Garmin watch face help' spreadsheet, which includes the settings, FAQ, available features per device and available themes: https://docs.google.com/spreadsheets/d/1j0OmzTjzIc9nzAGclR-g87UA_Xr875As2goZkQ10z9s/edit?usp=sharing. If your question is not answered there, feel free to send me a message via 'Contact Developer' option.

### Features:
- Time, Date, Seconds and AM/PM indicator in the center
- Motivational Quote field at the bottom
- 3 customizable data fields at the top
- 2 customizable databars around or at the sides of the clock

### Settings you can change (it depends on what the watch supports):
- Select a theme from more than 100 (some devices support less color and they have a limited number of available themes). You can find all the themes on the 'Available themes' sheet on the 'Warpaint Motivation (WpM) - Garmin watch face help' spreadsheet.
- Enable Military time format when the 24 hour option is selected.
- Seconds display options: No display / Display only in active mode / Display seconds also when in low power mode (It drains the battery faster and does not work for AMOLED watches beacuse they require burn in protection).
- Set a Calorie goal which will serve as the max value on the databar (If 0, an automated calculation will be done according to your activity level).
- Set a uniqe motivational quote to display. It is advised to use less than 50 characters, which are needed to written in UPPERCASE and besides English letters and numbers the following characters are available: ' !"%&'()+,-./:;=?_º'. Use the | character to indicate the row split, otherwise it is automatically splitted according to length and spaces. Leave empty for automatic selection.
- Set how frequent the motivational quote is changed (15 min/30 min/60 min/2 hours/3 hours (default)/4 hours/8 hours/12 hours).
- Data fields: Battery, Steps, Heart Rate, Calories, Sunrise/Sunset, Distance, Floors climbed, Active minutes, Weather, Device indicators (Notifications, Alarms, Do Not Disturb, Bluetooth), Remaining Days, Move Bar, Meters climbed, Off.
- You can set a date for the 'Remaining days to selected date' data field.
- Databars: Battery, Steps, Calories, Floors climbed, Active minutes, Move Bar, Off.
- On round shape watches on the place of the outer databar you can set the Sunset/Sunrise position in a 24-hour splitted circle and the position of the sun.
- You can split the databars to equal parts (10 parts on round and 5 parts on semi round and 4 parts on rectangle watches). The Sunset/Sunrise position circle around the round watches splitted into 24 parts.

### Notes/FAQ:
- All possibilities to change the settings and customize the watch face are present on the following page: https://apps.garmin.com/settingsHelp. 
- The 12/24 hour mode and Statute/metric units can be changed directly on the device in Settings > System.
- Motivational quotes are collected via an internet connected mobile phone through bluetooth connection from a continuously growing collection of currently more than 140 quotes every hour (collects more than one quote, which are put in a queue to use in case of temporary connection errors). If no connection is available and the queue is empty, or the device CIQ level is 1.4.x or below, the motivational quote is selected from a pool of 40 defaults.
- You can change the currently displayed motivational quote manually by changing any of the settings.
- If Next Sunrise/Sunset data field shows '--' or the Sunrise/Sunset databar is empty, start any activities until you are located (GPS turns to green). Now the Sunrise/Sunset data will be updated in maximum of 30 minutes on the watch face.
- If other data field shows '--', check the device support sheet mentioned before. If it should be available please contact me because I might made a mistake in the sheet.
- Seconds normally hide after entering low power mode (usually after 10 seconds). You can enable to always show the seconds on some devices (it can drain the battery faster). The available devices for this option are in the device support sheet in the 'Update seconds in low power mode' column.
- In 'Device Indicators' data field the notifications and alarms icons are shown when there is at least 1 in that category.
- To uninstall Warpaint Motivation, first you need to change to any other watchface then you can proceed.
- Warpaint Motivation does not collect or forward any data.

### Credits
Thanks for the garmin developer community and the help they provided me on the forums and in the official documentations.
The motivational quotes are from the following youtube channels:
- Ben Lionel Scott (https://www.youtube.com/channel/UCgkKA7xEOoBQNpC5TJxPLiw)
- Team Fearless (https://www.youtube.com/c/TeamFearless)
- Motiversity (https://www.youtube.com/c/motiversity)
- Eddie Pinero (https://www.youtube.com/channel/UCZSFzP3302RUCqPNXFGlVFw)
The unique font is from Vic Fieger (https://www.vicfieger.com)

### Tags: 
Motivational, Inspirational, Data, Information, Stylish, Original, Creative, Customizable, Special, Cool, Awesome, Running, Race

## What's New

### 1.3.6
- Add D2™ Air X10, D2™ Mach 1, Forerunner® 255, Forerunner® 255 Music, Forerunner® 255s, Forerunner® 255s Music, Forerunner® 955 / Solar, Venu® Sq 2, Venu® Sq 2 Music support
### 1.3.5
- Add Fenix 7, Fenix 7S, Fenix 7X and Epix™ (Gen 2) support
### 1.3.4
- Add Venu 2 Plus support
### 1.3.3
- Fix issue: property without settings
### 1.3.2
- Code optimization
- Fix vivoactive_hr false data field issue
### 1.3.1
- Fix minor bugs
### 1.3.0
- Restructure and optimize code
- Fix AMOLED watches not updating motivational quote when in low power mode
- Fix fr735xt false data field issue
### 1.2.3
- Fix Sunrise/Sunset issue
### 1.2.2
- Modify Sunrise/Sunset calculation to be more accurate
### 1.2.1
- Restructure splitted databar option
### 1.2.0
- Add splitted databar option
- Remove fr645m weather data field (not supported by device)
### 1.1.1
- Merge notifications and alarms to the 'Device indicators' data field, which also contains Do Not Disturb and Bluetooth
### 1.1.0
- Add support for Forerunner® 55
- New data field options: Meters climbed, Alarms count, Remaining days to a selected date, Move bar, Off (Display nothing)
- New databar options: Move bar, Off
- New option to never show seconds
- Battery databar will now turn red under 20%
- Adjust Calories Goal error message and min max
- Fix notifications does not refresh issue
- Fix approach60, approach62 and fr735xt first time launch issues
### 1.0.3
- Remove Vivolife support because of low number of features.
### 1.0.2
- Fix motivational quote change interval issue.
### 1.0.1
- Fix unique Motivational Quote prompt in Settings.
- Fix databar titles in Settings.
### 1.0.0
- Public release.

## Permissions
This app requires access to:

- Run in the background when it is not active (potentially affecting battery life)
- Send/receive information to/from the Internet
- GPS location
- Your Garmin Connect™ fitness profile
