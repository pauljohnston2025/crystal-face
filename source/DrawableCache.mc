using Toybox.WatchUi as Ui;

import Toybox.Lang;


class DrawableCache {
	// Cache references to drawables immediately after layout, to avoid expensive findDrawableById() calls in onUpdate();
	// todo access these through named methods, though may be bad for battery / performance?
	var mDrawables as Dictionary<Symbol, Ui.Drawable> = {};
	var mTime;
	var mDataFields;

	function cacheDrawables(view as Ui.View) {
		mDrawables[:LeftGoalMeter] = view.findDrawableById("LeftGoalMeter");
		mDrawables[:RightGoalMeter] = view.findDrawableById("RightGoalMeter");
		mDrawables[:DataArea] = view.findDrawableById("DataArea");
		mDrawables[:Indicators] = view.findDrawableById("Indicators");

		// Use mTime instead.
		// Cache reference to ThickThinTime, for use in low power mode. Saves nearly 5ms!
		// Slighly faster than mDrawables lookup.
		//mDrawables[:Time] = view.findDrawableById("Time");
		mTime = view.findDrawableById("Time");

		// Use mDataFields instead.
		//mDrawables[:DataFields] = view.findDrawableById("DataFields");
		mDataFields = view.findDrawableById("DataFields");

		mDrawables[:MoveBar] = view.findDrawableById("MoveBar");
	}
}
