import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Complications;
import Toybox.Application;

class CrystalDelegate extends WatchUi.WatchFaceDelegate {
  private var mDrawableCache as DrawableCache;

  function initialize(drawableCache as DrawableCache)
  {
    mDrawableCache = drawableCache;
    WatchFaceDelegate.initialize();
  }

  function onPress(clickEvent as WatchUi.ClickEvent) as Lang.Boolean {
    var coords = clickEvent.getCoordinates();
    // System.println("onPress: " + coords[0] + ", " + coords[1]);

    var x = coords[0];
    var y = coords[1];

    var dataFields = mDrawableCache.mDataFields;
    if (dataFields != null && dataFields.handleTouch(x, y))
    {
      return true;
    }
    
    var dataArea = mDrawableCache.mDrawables[:DataArea];
    if (dataArea != null && (dataArea as DataArea).handleTouch(x, y))
    {
      return true;
    }
    
    var indicators = mDrawableCache.mDrawables[:Indicators];
    if (indicators != null && (indicators as Indicators).handleTouch(x, y))
    {
      return true;
    }

    // todo move bar (which i might replace?)
    // hard code recovery time stat for now
    if (x > 68 && x < 245 && y > 231 && y < 261) {
      Complications.exitTo(
          new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME));
      return true;
    }

    return false;
  }
}