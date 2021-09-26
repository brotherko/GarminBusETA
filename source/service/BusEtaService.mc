import Toybox.Application;
import Toybox.System;

class BusEtaService {
  hidden var route;
  hidden var dir;
  hidden var stop;
  hidden var serviceType;

  hidden var onUpdate;
  hidden var onReady;


  var seq;
  var directionName;
  var stopName;
  var eta;
  var lastUpdate;

  hidden var _queue;

  function initialize(opts) {
    self.route = opts[:route];
    self.dir = opts[:dir];
    self.stop = opts[:stop];
    self.serviceType = opts[:serviceType];

    self.eta = new [3];

    self.onUpdate = opts[:onUpdate];
    self.onReady = opts[:onReady];

    _queue = new CommandExecutor();

    self.init();
  }

  function init() {
    var options = {                                             // set the options
      :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };

    _queue.add_command(
      new WebRequestCommand(
        "https://data.etabus.gov.hk/v1/transport/kmb/route/"
          + self.route + "/"
          + (self.dir.equals("O") ? "outbound" : "inbound") + "/"
          + serviceType,
        null,
        options,
        method(:routeResponseHandler)
      )
    );

    _queue.add_command(
      new WebRequestCommand(
        "https://data.etabus.gov.hk/v1/transport/kmb/route-stop/"
          + self.route + "/"
          + (self.dir.equals("O") ? "outbound" : "inbound") + "/"
          + serviceType,
        null,
        options,
        method(:getSeqResponseHandler)
      )
    );

    _queue.add_command(
      new WebRequestCommand(
        "https://data.etabus.gov.hk/v1/transport/kmb/stop/"
          + self.stop,
        null,
        options,
        method(:getStopInfoResponseHandler)
      )
    );

    self.update();

    _queue.add_command(
      new UnaryCommand(method(:debugPrint), [])
    );

    if (onReady) {
      _queue.add_command(
        new UnaryCommand(onReady, [self])
      );
    }
  }

  function debugPrint() {
    System.println("route:" + self.route);
    System.println("dir:" + self.dir);
    System.println("directionName:" + self.directionName);
    System.println("seq:" + self.seq);
    System.println("stop name:" + self.stopName);
    System.println("ETA:" + self.eta);
  }

  function routeResponseHandler(responseCode, responseData) {
    if (responseCode == 200) {
      var data = responseData["data"];
      self.directionName = data["dest_en"];
    }
  }


  function getStopInfoResponseHandler(responseCode, responseData) {
    if (responseCode == 200) {
      var data = responseData["data"];
      self.stopName = data["name_en"];
    }
  }

  function getSeqResponseHandler(responseCode, responseData) {
    if (responseCode == 200) {
      var data = responseData["data"];
      for (var i = 0; i < data.size(); i++) {
        var row = data[i];
        if (row["stop"].equals(self.stop)) {
          self.seq = row["seq"].toNumber();
        }
      }
    }
  }

  function getViewData() {
    System.println("getviewdata");
    var data = {
      :route => self.route,
      :directionName => self.directionName,
      :stopName => self.stopName,
      :eta => self.eta,
      :lastUpdate => self.lastUpdate,
    };
    return data;
  }

  function update() {
    var options = {                                             // set the options
      :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };

    _queue.add_command(
      new WebRequestCommand(
        "https://data.etabus.gov.hk/v1/transport/kmb/stop-eta/"
          + self.stop,
        null,
        options,
        method(:updateHandler)
      )
    );

    if (onUpdate) {
      _queue.add_command(
        new UnaryCommand(onUpdate, [self])
      );
    }
  }

  function updateHandler(responseCode, responseData) {
    if (responseCode == 200) {
      var data = responseData["data"];
      for (var i = 0; i < data.size(); i++) {
        var row = data[i];
        if (row["route"].equals(self.route)
          && row["seq"] == self.seq
          && row["dir"].equals(self.dir)
          && row["service_type"].equals(self.serviceType)
        ) {
          var etaMoment = row["eta"] ? TimeUtil.parseISOString(row["eta"]) : null;
          self.eta[row["eta_seq"] - 1] = etaMoment;
        }
      }
        self.lastUpdate = Time.now();
    }
  }

}
