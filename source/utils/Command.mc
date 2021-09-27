using Toybox.System;
using Toybox.Communications;

class Command {
  var _next;
  var _queue;

  function initialize() {
    _next = null;
    _queue = null;
  }

  function start() {}

  function finish() {
    var queue = _queue;
    _queue = null;

    if (queue != null) {
      queue.finishCommand();
    }
  }
}

class CommandExecutor {
  hidden var _head;
  hidden var _tail;

  function initialize() {
    _head = null;
    _tail = null;
  }

  function addCommand(command) {
    command._queue = self;

    if (_head == null) {
      _head = command;
      _tail = command;

      command.start();
    } else {
      _tail._next = command;
      _tail = command;
    }
  }

  function finishCommand() {
    // remove the front item in the queue
    var head = _head;
    _head = head._next;
    head._next = null;
    head._queue = null;

    // now _head is null or references the next command
    if (_head == null) {
      _tail = null;
    } else {
      _head.start();
    }
  }
}

class UnaryCommand extends Command {
  hidden var _callback;
  hidden var _params;

  function initialize(callback, params) {
    Command.initialize();

    _callback = callback;
    _params = params;
  }

  function start() {
    if (_params == null || _params.size() == 0) {
      _callback.invoke();
    } else if (_params.size() == 1) {
      _callback.invoke(_params[0]);
    } else if (_params.size() == 2) {
      _callback.invoke(_params[0], _params[1]);
    } else if (_params.size() == 3) {
      _callback.invoke(_params[0], _params[1], _params[2]);
    }
    _callback = null;

    Command.finish();
  }
}

class WebRequestCommand extends Command {
  hidden var _url;
  hidden var _params;
  hidden var _options;
  hidden var _callback;

  function initialize(url, params, options, callback) {
    Command.initialize();
    _url = url;
    _params = params;
    _options = options;
    _callback = callback;
  }

  function start() {
    System.println("Fetching: " + _url);
    Communications.makeWebRequest(_url, _params, _options, self.method(:handleResponse));
  }

  function handleResponse(code, data) {
    System.println("Response: " + code);
    _callback.invoke(code, data);
    _callback = null;

    // remove self from the queue, start the next request
    Command.finish();
  }
}