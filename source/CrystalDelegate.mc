import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Complications;
import Toybox.Application;

class CrystalDelegate extends WatchUi.WatchFaceDelegate {
  function onPress(clickEvent as WatchUi.ClickEvent) as Lang.Boolean {
    var coords = clickEvent.getCoordinates();
    System.println("onPress: " + coords[0] + ", " + coords[1]);

    // todo: store mFieldCount in app too so we can access it and base our
    // handling off that too for now just assume all 3 set text portion
    //     dc.setClip(
    // x - 11,
    // mBottom - 4,
    // 25,
    // 12);
    // mTop
    // mBottom
    // todo get from app, but the ones i care about are
    var x = coords[0];
    var y = coords[1];
    var left = 112;
    var right = 248;
    var top = 40;
    var bottom = 73;
    var fieldTypes = Application.getApp().mFieldTypes;
    // if () return false;

    if (y > top && y < bottom) {
      // match the math in DataFields.update() for a 3 field watch
      var middleX = (right + left) / 2;
      // field 1
      if (x > left - 11 && x < left + 25 - 11) {
        return launchFieldType(fieldTypes[0]);
      }
      // field 2
      else if (x > middleX - 11 && x < middleX + 25 - 11) {
        return launchFieldType(fieldTypes[1]);
      }
      // field
      else if (x > right - 11 && x < right + 25 - 11) {
        return launchFieldType(fieldTypes[2]);
      }

      return false;
    }

    // goal bars we will allow touching the icon
    // get these from DataArea or CrystalView class
    var goalIconY = 280;
    var goalIconLeftX = 72;
    var goalIconRightX = 289;

    // these have text and an icon, but are justified left/right
    // todo could calculate this from text/icon hight if we have adccess to DC
    var iconAndTextLimit = 100;
    var heightLimit = 50;
    if (y > goalIconY && y < goalIconY + heightLimit) {
      if (x > goalIconLeftX && x < goalIconLeftX + iconAndTextLimit) {
        // todo get goal type from DataArea or CrystalView class
        return launchGoalType(GOAL_TYPE_STEPS);
      } else if (x > goalIconRightX - iconAndTextLimit && x < goalIconRightX) {
        // todo get goal type from DataArea or CrystalView class
        return launchGoalType(GOAL_TYPE_FLOORS_CLIMBED);
      }

      return false;
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

  function launchFieldType(fieldType as Number) as Boolean {
    switch (fieldType) {
      case FIELD_TYPE_SUNRISE:
        Complications.exitTo(
            new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE));
        return true;
      case FIELD_TYPE_HEART_RATE:
        Complications.exitTo(
            new Complications.Id(Complications.COMPLICATION_TYPE_HEART_RATE));
        return true;
      case FIELD_TYPE_BATTERY:
        Complications.exitTo(
            new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY));
        return true;
      case FIELD_TYPE_NOTIFICATIONS:
        Complications.exitTo(new Complications.Id(
            Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT));
        return true;
      case FIELD_TYPE_CALORIES:
        Complications.exitTo(
            new Complications.Id(Complications.COMPLICATION_TYPE_CALORIES));
        return true;
      case FIELD_TYPE_DISTANCE:
        Complications.exitTo(new Complications.Id(
            Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE));
        return true;
      case FIELD_TYPE_ALARMS:
        return false;
      case FIELD_TYPE_ALTITUDE:
        Complications.exitTo(
            new Complications.Id(Complications.COMPLICATION_TYPE_ALTITUDE));
        return true;
      case FIELD_TYPE_TEMPERATURE:
        Complications.exitTo(new Complications.Id(
            Complications.COMPLICATION_TYPE_CURRENT_TEMPERATURE));
        return true;
      case FIELD_TYPE_BATTERY_HIDE_PERCENT:
        Complications.exitTo(
            new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY));
        return true;
      case FIELD_TYPE_HR_LIVE_5S:
        Complications.exitTo(
            new Complications.Id(Complications.COMPLICATION_TYPE_HEART_RATE));
        return true;
      case FIELD_TYPE_SUNRISE_SUNSET:
        Complications.exitTo(
            new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE));
        return true;
      case FIELD_TYPE_WEATHER:
        Complications.exitTo(new Complications.Id(
            Complications.COMPLICATION_TYPE_CURRENT_WEATHER));
        return true;
      case FIELD_TYPE_PRESSURE:
        Complications.exitTo(new Complications.Id(
            Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE));
        return true;
      case FIELD_TYPE_HUMIDITY:
        return false;
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