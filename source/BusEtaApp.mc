import Toybox.Application;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
import Toybox.Communications;
import Toybox.System;
import Toybox.Timer;

class BusEtaApp extends Application.AppBase {
  var etaManager = new BusEtaServiceManager(
    method(:onDataReady),
    method(:onDataUpdate)
  );
  var _currentPage;

  function initialize() {
    AppBase.initialize();
    etaManager.add({
      :route => "101",
      :stop => "B4B94159F6B89A6B",
      :dir => "O",
      :serviceType => 1,
    });
    etaManager.add({
      :route => "641",
      :stop => "72999453ECAC4693",
      :dir => "O",
      :serviceType => 1,
    });
    etaManager.add({
      :route => "101",
      :stop => "50C82DFB0AC97FC8",
      :dir => "I",
      :serviceType => 1,
    });
    etaManager.add({
      :route => "641",
      :stop => "50C82DFB0AC97FC8",
      :dir => "I",
      :serviceType => 1,
    });
  }

  function switchPage(offset) {
    etaManager.setActiveIdxByOffset(offset);
    self.switchToCurrentPage(offset > 0 ? Ui.SLIDE_UP : Ui.SLIDE_DOWN);
  }

  function switchToCurrentPage(transition) {
    Ui.switchToView(
      new BusEtaView(etaManager.getActiveService()),
      new BusEtaDelegate(method(:switchPage)),
      transition
    );
  }

  function onDataReady(srv) {
    self.switchToCurrentPage(Ui.SLIDE_IMMEDIATE);
  }

  function onDataUpdate(srv) {
    Ui.requestUpdate();
  }

  function onStart(state as Dictionary?) as Void {
    etaManager.updateAll();
    etaManager.startAutoUpdate(60000);
  } 

  function onHide(state as Dictionary?) as Void {
    etaManager.stopAutoUpdate();
  }


  function getInitialView() as Array<Views or InputDelegates>? {
    return [new LoadingView(), new BusEtaDelegate(method(:switchPage))];
  }
}


function getApp() as BusEtaApp {
  return Application.getApp() as BusEtaApp;
}
