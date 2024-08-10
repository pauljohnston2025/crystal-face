using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;

import Toybox.Lang;
import Toybox.Complications;

enum /* INDICATOR_TYPES */ {
		INDICATOR_TYPE_BLUETOOTH = 0,
		INDICATOR_TYPE_ALARMS,
		INDICATOR_TYPE_NOTIFICATIONS,
		INDICATOR_TYPE_BLUETOOTH_OR_NOTIFICATIONS,
		INDICATOR_TYPE_BATTERY,
		INDICATOR_TYPE_RECOVERY,
		INDICATOR_TYPE_CURRENT_TEMPERATURE_GARMIN, // based on garmin, not open weather maps (symbol is '°C')
		INDICATOR_TYPE_CURRENT_TEMPERATURE_GARMIN_NO_C, // based on garmin, not open weather maps (symbol is '°' without the c for better fittment of text )
	}

class Indicators extends Ui.Drawable {

	private var mSpacing;
	private var mBatteryWidth;

	private var mIndicator1Type;
	private var mIndicator2Type;
	private var mIndicator3Type;
	// first draw will set it
	private var mIndicatorCount as Number = 0;

	typedef IndicatorsParams as {
		:locX as Number,
		:locY as Number,
		:spacingX as Number,
		:spacingY as Number,
		:batteryWidth as Number
	};

	function initialize(params as IndicatorsParams) {
		Drawable.initialize(params);

		if (params[:spacingX] != null) {
			mSpacing = params[:spacingX];
		} else {
			mSpacing = params[:spacingY];
		}
		mBatteryWidth = params[:batteryWidth];

		onSettingsChanged();
	}

	function onSettingsChanged() {
		mIndicator1Type = getPropertyValue("Indicator1Type");
		mIndicator2Type = getPropertyValue("Indicator2Type");
		mIndicator3Type = getPropertyValue("Indicator3Type");
	}

	function draw(dc) {

		// #123 Protect against null or unexpected type e.g. String.
		mIndicatorCount = App.getApp().getIntProperty("IndicatorCount", 1);

		// // Horizontal layout for rectangle-148x205, rectangle-320x360
		// if (mIsHorizontal) {
		// 	drawHorizontal(dc, indicatorCount);

		// // Vertical layout for others.
		// } else {
		// 	drawVertical(dc, indicatorCount);
		// }
		drawIndicators(dc, mIndicatorCount);
	}

	(:horizontal_indicators)
	// function drawHorizontal(dc, indicatorCount) {
	function drawIndicators(dc, indicatorCount) {
		if (indicatorCount == 3) {
			drawIndicator(dc, mIndicator1Type, locX - mSpacing, locY);
			drawIndicator(dc, mIndicator2Type, locX, locY);
			drawIndicator(dc, mIndicator3Type, locX + mSpacing, locY);
		} else if (indicatorCount == 2) {
			drawIndicator(dc, mIndicator1Type, locX - (mSpacing / 2), locY);
			drawIndicator(dc, mIndicator2Type, locX + (mSpacing / 2), locY);
		} else if (indicatorCount == 1) {
			drawIndicator(dc, mIndicator1Type, locX, locY);
		}
	}

	(:vertical_indicators)
	// function drawVertical(dc, indicatorCount) {
	function drawIndicators(dc, indicatorCount) {
		if (indicatorCount == 3) {
			drawIndicator(dc, mIndicator1Type, locX, locY - mSpacing);
			drawIndicator(dc, mIndicator2Type, locX, locY);
			drawIndicator(dc, mIndicator3Type, locX, locY + mSpacing);
		} else if (indicatorCount == 2) {
			drawIndicator(dc, mIndicator1Type, locX, locY - (mSpacing / 2));
			drawIndicator(dc, mIndicator2Type, locX, locY + (mSpacing / 2));
		} else if (indicatorCount == 1) {
			drawIndicator(dc, mIndicator1Type, locX, locY);
		}
	}

	function drawIndicator(dc, indicatorType, x, y) {

		// Battery indicator.
		if (indicatorType == INDICATOR_TYPE_BATTERY) {
			drawBatteryMeter(dc, x, y, mBatteryWidth, mBatteryWidth / 2);
			return;
		}

		if (indicatorType == INDICATOR_TYPE_RECOVERY)
		{
			var complication = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME));
			var value = complication.value;
			var strValue = "na";
			if(value != null) {
				// originally in minutes, we want hours
				strValue = (value / 60.0f).format("%.0f") + "h";
			}
			dc.setColor(gThemeColour, Graphics.COLOR_TRANSPARENT);
			dc.drawText(
				x,
				y,
				gNormalFont,
				strValue,
				Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
			);
			return;
		}
		
		if (indicatorType == INDICATOR_TYPE_CURRENT_TEMPERATURE_GARMIN || indicatorType == INDICATOR_TYPE_CURRENT_TEMPERATURE_GARMIN_NO_C)
		{
			var complication = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_CURRENT_TEMPERATURE));
			var value = complication.value;
			var strValue = "na";
			if(value != null) {
				strValue = value.format("%.0f") + "°";

				if (indicatorType == INDICATOR_TYPE_CURRENT_TEMPERATURE_GARMIN)
				{
					strValue += 'C';
				}
			}

			dc.setColor(gThemeColour, Graphics.COLOR_TRANSPARENT);
			dc.drawText(
				x,
				y,
				gNormalFont,
				strValue,
				Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
			);
			return;
		}

		// Show notifications icon if connected and there are notifications, bluetoothicon otherwise.
		var settings = Sys.getDeviceSettings();
		if (indicatorType == INDICATOR_TYPE_BLUETOOTH_OR_NOTIFICATIONS) {
			if (settings.phoneConnected && (settings.notificationCount > 0)) {
				indicatorType = INDICATOR_TYPE_NOTIFICATIONS;
			} else {
				indicatorType = INDICATOR_TYPE_BLUETOOTH;
			}
		}

		// is this more performant that switch statement and function call?
		var value = {
			INDICATOR_TYPE_BLUETOOTH => settings.phoneConnected,
			INDICATOR_TYPE_ALARMS => settings.alarmCount > 0,
			INDICATOR_TYPE_NOTIFICATIONS => settings.notificationCount > 0,
		}[indicatorType];

		dc.setColor(value ? gThemeColour : gMeterBackgroundColour, Graphics.COLOR_TRANSPARENT);

		// Icon.
		dc.drawText(
			x,
			y,
			gIconsFont,
			["8", ":", "5"][indicatorType], // Get icon font char for indicator type.
			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
		);
	}

	(:horizontal_indicators)
	function handleTouch(x as Number, y as Number) as Boolean {
		var widthLimit = mSpacing / 2;
		var heightLimit = mSpacing / 2;
		if (y < locY - heightLimit || y > locY + heightLimit) {
			return false;
		}

		switch (mIndicatorCount) {
		case 3:
		{
			var leftX = locX - mSpacing;
			var middleX = locX;
			var rightX = locX - mSpacing;
			// field 1
			if (x > leftX - widthLimit && x < leftX + widthLimit) {
				return launchIndicatorType(mIndicator1Type);
			}
			// field 2
			else if (x > middleX - widthLimit && x < middleX + widthLimit) {
				return launchIndicatorType(mIndicator2Type);
			}
			// field 3
			else if (x > rightX - widthLimit && x < rightX + widthLimit) {
				return launchIndicatorType(mIndicator3Type);
			}
			return false;
		}
		case 2:
		{
			var leftX = locX - (mSpacing / 2);
			var rightX = locX + (mSpacing / 2);
			// field 1
			if (x > leftX - widthLimit && x < leftX + widthLimit) {
				return launchIndicatorType(mIndicator1Type);
			}
			// field 2
			else if (x > rightX - widthLimit && x < rightX + widthLimit) {
				return launchIndicatorType(mIndicator2Type);
			}
			return false;
		}
		case 1:
			if (x > locX - widthLimit && x < locX + widthLimit) {
				return launchIndicatorType(mIndicator1Type);
			}
			return false;
		}

		return false;
	}
	
	(:vertical_indicators)
	function handleTouch(x as Number, y as Number) as Boolean {
		var widthLimit = mBatteryWidth / 2; // battery bar shoulld be a good indicator for available space
		var heightLimit = mSpacing / 2; // the icons always seem to be mSpacing appart, half the distance so we can do +-
		if (x < locX - widthLimit || x > locX + widthLimit) {
			return false;
		}

		switch (mIndicatorCount) {
		case 3:
		{
			var topY = locY - mSpacing;
			var middleY = locY;
			var bottomY = locY + mSpacing;
			// field 1
			if (y > topY - heightLimit && y < topY + heightLimit) {
				return launchIndicatorType(mIndicator1Type);
			}
			// field 2
			else if (y > middleY - heightLimit && y < middleY + heightLimit) {
				return launchIndicatorType(mIndicator2Type);
			}
			// field 3
			else if (y > bottomY - heightLimit && y < bottomY + heightLimit) {
				return launchIndicatorType(mIndicator3Type);
			}
			return false;
		}
		case 2:
		{
			var topY = locY - (mSpacing / 2);
			var bottomY = locY + (mSpacing / 2);
			// field 1
			if (y > topY - heightLimit && y < topY + heightLimit) {
				return launchIndicatorType(mIndicator1Type);
			}
			// field 2
			else if (y > bottomY - heightLimit && y < bottomY + heightLimit) {
				return launchIndicatorType(mIndicator2Type);
			}
			return false;
		}
		case 1:
			if (y > locY - heightLimit && y < locY + heightLimit) {
				return launchIndicatorType(mIndicator1Type);
			}
			return false;
		}

		return false;
	}

	function launchIndicatorType(indicatorType as Number) as Boolean {
		switch (indicatorType) {
		case INDICATOR_TYPE_BLUETOOTH:
			return false;
		case INDICATOR_TYPE_ALARMS:
			return false;
		case INDICATOR_TYPE_NOTIFICATIONS:
			Complications.exitTo(
				new Complications.Id(Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT));
			return true;
		case INDICATOR_TYPE_BLUETOOTH_OR_NOTIFICATIONS:
			var settings = Sys.getDeviceSettings();
			if (settings.phoneConnected && (settings.notificationCount > 0)) {
				return launchIndicatorType(INDICATOR_TYPE_NOTIFICATIONS);
			}

			return launchIndicatorType(INDICATOR_TYPE_BLUETOOTH);
		case INDICATOR_TYPE_BATTERY:
			Complications.exitTo(new Complications.Id(
				Complications.COMPLICATION_TYPE_BATTERY));
			return true;
		case INDICATOR_TYPE_RECOVERY:
			return false;
		case INDICATOR_TYPE_CURRENT_TEMPERATURE_GARMIN:
		case INDICATOR_TYPE_CURRENT_TEMPERATURE_GARMIN_NO_C:
			Complications.exitTo(new Complications.Id(
				Complications.COMPLICATION_TYPE_CURRENT_TEMPERATURE));
			return true;
		}

		return false;
	}
}
