using Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time.Gregorian;

class BusEtaView extends WatchUi.View {
  var busEtaService;

  function initialize(busEtaService) {
    self.busEtaService = busEtaService;
    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.MainLayout(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
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

  // Update the view
  function onUpdate(dc as Dc) as Void {
    View.onUpdate(dc);

    var data = self.busEtaService.getViewData();
    System.println("view data: " + data);

    View.findDrawableById("route").setText(data[:route]);
    View.findDrawableById("directionName").setText(data[:directionName]);
    View.findDrawableById("etaTime0").setText(
      formatEtaMins(data[:eta][0])
    );
    View.findDrawableById("etaTime1").setText(
      formatEtaMins(data[:eta][1])
    );
    View.findDrawableById("etaTime2").setText(
      formatEtaMins(data[:eta][2])
    );
    View.findDrawableById("lastUpdate").setText(
      formatLastUpdate(data[:lastUpdate])
    );
    View.findDrawableById("stopName").setText(data[:stopName]);

  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {
  }

}
