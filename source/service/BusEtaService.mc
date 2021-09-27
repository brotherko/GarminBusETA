import Toybox.Application;
import Toybox.System;

class BusEtaService {
  hidden var _busEta;
  
  hidden var _onUpdate;
  hidden var _onReady;

  hidden var _queue;

  function initialize(opts) {
    _busEta = new BusEta({
      :route => opts[:route],
      :dir => opts[:dir],
      :stop => opts[:stop]
    });

    _onUpdate = opts[:onUpdate];
    _onReady = opts[:onReady];

    _queue = new CommandExecutor();

    load();
  }

  function load() {
    var serviceType = "1";
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };

    _queue.addCommand(
      new WebRequestCommand(
        "https://data.etabus.gov.hk/v1/transport/kmb/route/"
          + _busEta.route + "/"
          + (_busEta.dir.equals("O") ? "outbound" : "inbound") + "/"
          + serviceType,
        null,
        options,
        method(:routeResponseHandler)
      )
    );

    _queue.addCommand(
      new WebRequestCommand(
        "https://data.etabus.gov.hk/v1/transport/kmb/route-stop/"
          + _busEta.route + "/"
          + (_busEta.dir.equals("O") ? "outbound" : "inbound") + "/"
          + serviceType,
        null,
        options,
        method(:routeStopResponseHandler)
      )
    );

    _queue.addCommand(
      new WebRequestCommand(
        "https://data.etabus.gov.hk/v1/transport/kmb/stop/"
          + _busEta.stop,
        null,
        options,
        method(:stopResponseHandler)
      )
    );

    self.update();

    if (_onReady) {
      _queue.addCommand(
        new UnaryCommand(_onReady, [self])
      );
    }
  }

  function getBusEta() {
    return _busEta;
  }

  function routeResponseHandler(responseCode, responseData) {
    if (responseCode == 200) {
      var data = responseData["data"];
      _busEta.directionName = data["dest_en"];
    }
  }

  function stopResponseHandler(responseCode, responseData) {
    if (responseCode == 200) {
      var data = responseData["data"];
      _busEta.stopName = data["name_en"];
    }
  }

  function routeStopResponseHandler(responseCode, responseData) {
    if (responseCode == 200) {
      var data = responseData["data"];
      for (var i = 0; i < data.size(); i++) {
        var row = data[i];
        if (row["stop"].equals(_busEta.stop)) {
          _busEta.seq = row["seq"].toNumber();
        }
      }
    }
  }

  function update() {
    var options = {                                             // set the options
      :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };

    _queue.addCommand(
      new WebRequestCommand(
        "https://data.etabus.gov.hk/v1/transport/kmb/stop-eta/"
          + _busEta.stop,
        null,
        options,
        method(:updateHandler)
      )
    );

    if (_onUpdate) {
      _queue.addCommand(
        new UnaryCommand(_onUpdate, [self])
      );
    }
  }

  function updateHandler(responseCode, responseData) {
    var etaArrsize = 0;
    var etaArr = new [10];

    if (responseCode == 200) {
      var data = responseData["data"];
      for (var i = 0; i < data.size(); i++) {
        var row = data[i];
        if (row["route"].equals(_busEta.route)
          && row["seq"] == _busEta.seq
          && row["dir"].equals(_busEta.dir)
        ) {
          if (row["eta"]) {
            var etaMoment = TimeUtil.parseISOString(row["eta"]);
            if (etaMoment) {
              etaArr[etaArrsize] = etaMoment;
              etaArrsize += 1;
            }
          }
        }
      }
      _busEta.updateEta(etaArr, etaArrsize);
      _busEta.lastUpdate = Time.now();
    }
  }

}
