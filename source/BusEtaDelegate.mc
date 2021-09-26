import Toybox.Lang;
import Toybox.WatchUi;

class BusEtaDelegate extends WatchUi.BehaviorDelegate {
  var switchPage;

  function initialize(switchPage) {
    BehaviorDelegate.initialize();
    self.switchPage = switchPage;
  }

  function onMenu() as Boolean {
    WatchUi.pushView(new Rez.Menus.MainMenu(), new BusEtaMenuDelegate(), WatchUi.SLIDE_UP);
    return true;
  }

  function onPreviousPage() {
    System.println("prev page");
    self.switchPage.invoke(-1);
  }

  function onNextPage() {
    System.println("next page");
    self.switchPage.invoke(+1);
  }


}