import Toybox.Timer;

class BusEtaServiceManager {
  hidden var _services = new [10];
  hidden var _size = 0;
  hidden var _activeIdx = 0;
  hidden var _timer;

  hidden var _onReady;
  hidden var _onUpdate;


  function initialize(onReady, onUpdate) {
    _timer = new Timer.Timer();
    _onReady = onReady;
    _onUpdate = onUpdate;
  }

  function getActiveService() {
    return _services[_activeIdx];
  }

  function add(opts) {
    if (_size == 0) {
      opts[:onReady] = _onReady;
    }
    opts[:onUpdate] = _onUpdate;
    _services[_size] = new BusEtaService(opts);
    _size += 1;
  }

  function updateAll() {
    for (var i = 0; i < _size; i++) {
      var svc = _services[i];
      svc.update();
    }
  }

  function startAutoUpdate(updateInterval) {
    _timer.start(method(:updateAll), updateInterval, true);
  }

  function stopAutoUpdate() {
    _timer.stop();
  }
  
  function setActiveIdx(idx) {
    _activeIdx = idx;
  }

  function setActiveIdxByOffset(offset) {
    var next = _activeIdx + offset;
    if (next > _size - 1) {
      next = 0;
    }
    if (next < 0) {
      next = _size - 1;
    }
    _activeIdx = next;
    return next;
  }
}