using Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time.Gregorian;

class BusEtaView extends WatchUi.View {
  var busEta;

  function initialize(busEta) {
    self.busEta = busEta;
    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.MainLayout(dc));
  }

  function formatEtaMins(time) {
    if (time == null) {
      return "--";
    }
    var now = Time.now();
    var mins = now.greaterThan(time)
      ? 0
      : TimeUtil.getDiffInMins(now, time);
    return mins.toString();
  }

  function formatLastUpdate(time) {
    var lastUpdateTime = Gregorian.info(time, Time.FORMAT_MEDIUM);
    return "Last update: " 
      + Lang.format("$1$:$2$:$3$", [
        lastUpdateTime.hour,
        lastUpdateTime.min,
        lastUpdateTime.sec
      ]);
  }

  function formatEtaOthers(time1, time2) {
    var text = "";
    text += time1 ? formatEtaMins(time1) : "--";
    text += "/" + (time2 ? formatEtaMins(time2) : "--");
    return text;
  }

  function onShow() {
    // updateScreen();
  }

  function onUpdate(dc as Dc) as Void {
    View.onUpdate(dc);
    updateScreen();
  }

  function updateScreen() {
    System.println("view data: " + busEta);

    View.findDrawableById("route").setText(busEta[:route]);
    View.findDrawableById("directionName").setText(busEta[:directionName]);
    View.findDrawableById("etaTime0").setText(
      formatEtaMins(busEta[:eta][0])
    );
    View.findDrawableById("etaTime1").setText(
      formatEtaMins(busEta[:eta][1])
    );
    View.findDrawableById("etaTime2").setText(
      formatEtaMins(busEta[:eta][2])
    );
    View.findDrawableById("lastUpdate").setText(
      formatLastUpdate(busEta[:lastUpdate])
    );
    View.findDrawableById("stopName").setText(busEta[:stopName]);
  }

  function onHide() as Void {
  }

}
