import Toybox.Time;

class TimeUtil {
  static function parseISOString(isostring) {
    var options = {
      :year => isostring.substring(0, 4).toNumber(),
      :month => isostring.substring(5, 7).toNumber(),
      :day => isostring.substring(8, 10).toNumber(),
      :hour => isostring.substring(11, 13).toNumber(),
      :minute => isostring.substring(14, 16).toNumber(),
      :second => isostring.substring(17, 19).toNumber()
    };

    var adjustGMT8 = new Time.Duration(28800);
    var timeMoment = Time.Gregorian.moment(options).subtract(adjustGMT8);

    return timeMoment;
  }

  static function getDiffInMins(time1, time2) {
    var diff = time1.subtract(time2);
    return diff.value()/60;
  }
}