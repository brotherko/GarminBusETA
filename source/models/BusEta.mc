const MAX_ETA_SIZE = 3;

class BusEta {
  var route;
  var dir;
  var stop;

  var seq;
  var directionName;
  var stopName;
  var eta;
  var lastUpdate;

  function initialize(opts) {
    route = opts[:route];
    dir = opts[:dir];
    stop = opts[:stop];

    eta = new [MAX_ETA_SIZE];
    debugPrint();
  }

  function debugPrint() {
    System.println("route:" + route);
    System.println("dir:" + dir);
    System.println("stop:" + stop);
    System.println("directionName:" + directionName);
    System.println("seq:" + seq);
    System.println("stop name:" + stopName);
    System.println("ETA:" + eta);
  }

  function compareDate(m1, m2) {
    return m1.greaterThan(m2);
  }

  function updateEta(arr, size) {
    var sortedArr = ArrayUtil.sorted(arr.slice(0, size), method(:compareDate));
    for (var i = 0; i < MAX_ETA_SIZE; i++) {
      if (i < size) {
        eta[i] = sortedArr[i];
      } else {
        eta[i] = null;
      }
    }
  }
}