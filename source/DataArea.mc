using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

import Toybox.Lang;
import Toybox.Complications;

class DataArea extends Ui.Drawable {

	private var mRow1Y;
	private var mRow2Y;

	private var mLeftGoalType;
	private var mLeftGoalIsValid;
	private var mLeftGoalCurrent;
	private var mLeftGoalMax;

	private var mRightGoalType;
	private var mRightGoalIsValid;
	private var mRightGoalCurrent;
	private var mRightGoalMax;

	private var mGoalIconY;
	private var mGoalIconLeftX;
	private var mGoalIconRightX;

	typedef DataAreaParams as {
		:locX as Number,
		:width as Number,
		:row1Y as Number,
		:row2Y as Number,
		:goalIconY as Number,
		:goalIconLeftX as Number,
		:goalIconRightX as Number
	};

	function initialize(params as DataAreaParams) {
		Drawable.initialize(params);

		mRow1Y = params[:row1Y];
		mRow2Y = params[:row2Y];

		mGoalIconY = params[:goalIconY];
		mGoalIconLeftX = params[:goalIconLeftX];
		mGoalIconRightX = params[:goalIconRightX];
	}

	function setGoalValues(leftType, leftValues as GoalValues, rightType, rightValues as GoalValues) {
		mLeftGoalType = leftType;
		mLeftGoalIsValid = leftValues[:isValid];

		if (leftValues[:isValid]) {
			mLeftGoalCurrent = leftValues[:current].format(INTEGER_FORMAT);
			mLeftGoalMax = (mLeftGoalType == GOAL_TYPE_BATTERY) ? "%" : leftValues[:max].format(INTEGER_FORMAT);
		} else {
			mLeftGoalCurrent = null;
			mLeftGoalMax = null;
		}

		mRightGoalType = rightType;
		mRightGoalIsValid = rightValues[:isValid];

		if (rightValues[:isValid]) {
			mRightGoalCurrent = rightValues[:current].format(INTEGER_FORMAT);
			mRightGoalMax = (mRightGoalType == GOAL_TYPE_BATTERY) ? "%" : rightValues[:max].format(INTEGER_FORMAT);
		} else {
			mRightGoalCurrent = null;
			mRightGoalMax = null;
		}
	}

	function draw(dc) {
		drawGoalIcon(dc, mGoalIconLeftX, mLeftGoalType, mLeftGoalIsValid, Graphics.TEXT_JUSTIFY_LEFT);
		drawGoalIcon(dc, mGoalIconRightX, mRightGoalType, mRightGoalIsValid, Graphics.TEXT_JUSTIFY_RIGHT);

		var city = getPropertyValue("LocalTimeInCity");

		// #78 Setting with value of empty string may cause corresponding property to be null.
		if ((city != null) && (city.length() != 0)) {
			//drawTimeZone();
			var cityLocalTime = getStorageValue("CityLocalTime") as CityLocalTimeData?;

			// If available, use city returned from web request; otherwise, use raw city from settings.
			// N.B. error response will NOT contain city.
			if ((cityLocalTime != null) && (cityLocalTime["city"] != null)) {
				city = cityLocalTime["city"];
			}

			// Time zone 1 city.
			dc.setColor(gMonoDarkColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(
				locX + (width / 2),
				mRow1Y,
				gNormalFont,
				// Limit string length.
				city.substring(0, 10),
				Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
			);

			// Time zone 1 time.
			var time;
			if (cityLocalTime != null) {

				// Web request responded with server error e.g. unknown city.
				if (cityLocalTime["error"] != null) {

					time = "???";

				// Web request responded with time zone data for city.
				} else {
					var timeZoneGmtOffset;

					// Use next GMT offset if it's now applicable (new data will be requested shortly).
					if ((cityLocalTime["next"] != null) && (Time.now().value() >= (cityLocalTime as CityLocalTimeSuccessResponse)["next"]["when"])) {
						timeZoneGmtOffset = (cityLocalTime as CityLocalTimeSuccessResponse)["next"]["gmtOffset"];
					} else {
						timeZoneGmtOffset = (cityLocalTime as CityLocalTimeSuccessResponse)["current"]["gmtOffset"];
					}
					timeZoneGmtOffset = new Time.Duration(timeZoneGmtOffset);
					
					var localGmtOffset = Sys.getClockTime().timeZoneOffset;
					localGmtOffset = new Time.Duration(localGmtOffset);

					// (Local time) - (Local GMT offset) + (Time zone GMT offset)
					time = Time.now().subtract(localGmtOffset).add(timeZoneGmtOffset);
					time = Gregorian.info(time, Time.FORMAT_SHORT);
					time = App.getApp().getFormattedTime(time.hour, time.min) as FormattedTime;
					time = time[:hour] + ":" + time[:min] + time[:amPm]; 
				}

			// Awaiting response to web request sent by BackgroundService.
			} else {
				time = "...";
			}

			dc.setColor(gMonoLightColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(
				locX + (width / 2),
				mRow2Y,
				gNormalFont,
				time,
				Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
			);

		} else {
			drawGoalValues(dc, locX, mLeftGoalCurrent, mLeftGoalMax, Graphics.TEXT_JUSTIFY_LEFT);
			drawGoalValues(dc, locX + width, mRightGoalCurrent, mRightGoalMax, Graphics.TEXT_JUSTIFY_RIGHT);
		}
	}

	function drawGoalIcon(dc, x, type, isValid, align) {
		if (type == GOAL_TYPE_OFF) {
			return;
		}
		
		var icon = {
			GOAL_TYPE_BATTERY => "9",
			GOAL_TYPE_CALORIES => "6",
			GOAL_TYPE_STEPS => "0",
			GOAL_TYPE_FLOORS_CLIMBED => "1",
			GOAL_TYPE_ACTIVE_MINUTES => "2",
		}[type];

		dc.setColor(isValid ? gThemeColour : gMeterBackgroundColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(
			x,
			mGoalIconY,
			gIconsFont,
			icon,
			align
		);
	}

	function drawGoalValues(dc, x, currentValue, maxValue, align) {
		var digitStyle = getPropertyValue("GoalMeterDigitsStyle");

		// #107 Only draw values if digit style is not Hidden.
		if (digitStyle != 2 /* HIDDEN */) {
			if (currentValue != null) {
				dc.setColor(gMonoLightColour, Gfx.COLOR_TRANSPARENT);
				dc.drawText(
					x,

					// #107 Draw current value vertically centred if digit style is Current (i.e. not drawing max/target).
					(digitStyle == 1 /* CURRENT */) ? ((mRow1Y + mRow2Y) / 2) : mRow1Y,

					gNormalFont,
					currentValue,
					align | Graphics.TEXT_JUSTIFY_VCENTER
				);
			}

			// #107 Only draw max/target goal value if digit style is set to Current/Target.
			if ((maxValue != null) && (digitStyle == 0) /* CURRENT_TARGET */) {
				dc.setColor(gMonoDarkColour, Gfx.COLOR_TRANSPARENT);
				dc.drawText(
					x,
					mRow2Y,
					gNormalFont,
					maxValue,
					align | Graphics.TEXT_JUSTIFY_VCENTER
				);
			}
		}
	}

	function handleTouch(x as Number, y as Number) as Boolean {
		// these have text and an icon, but are justified left/right
		// todo could calculate this from text/icon hight if we have adccess to DC
		var iconAndTextLimit = 100;
		var heightLimit = 50;
		if (y < mGoalIconY || y > mGoalIconY + heightLimit) {
			return false;
		}

		if (x > mGoalIconLeftX && x < mGoalIconLeftX + iconAndTextLimit) {
			// todo get goal type from DataArea or CrystalView class
			return launchGoalType(mLeftGoalType);
		} else if (x > mGoalIconRightX - iconAndTextLimit && x < mGoalIconRightX) {
			// todo get goal type from DataArea or CrystalView class
			return launchGoalType(mRightGoalType);
		}

		return false;
	}

	function launchGoalType(goalType as Number) as Boolean {
		switch (goalType) {
		case GOAL_TYPE_BATTERY:
			Complications.exitTo(
				new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE));
			return true;

		case GOAL_TYPE_CALORIES:
			Complications.exitTo(
				new Complications.Id(Complications.COMPLICATION_TYPE_CALORIES));
			return true;
		case GOAL_TYPE_OFF:
			return false;
		case GOAL_TYPE_STEPS:
			Complications.exitTo(
				new Complications.Id(Complications.COMPLICATION_TYPE_STEPS));
			return true;
		case GOAL_TYPE_FLOORS_CLIMBED:
			Complications.exitTo(new Complications.Id(
				Complications.COMPLICATION_TYPE_FLOORS_CLIMBED));
			return true;
		case GOAL_TYPE_ACTIVE_MINUTES:
			Complications.exitTo(new Complications.Id(
				Complications.COMPLICATION_TYPE_INTENSITY_MINUTES));
			return true;
		}

		return false;
	}
}
