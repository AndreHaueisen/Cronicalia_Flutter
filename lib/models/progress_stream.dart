import 'dart:async';

class ProgressStream {
  StreamController<double> _controller = new StreamController<double>();

  int _filesTotalNumber = 0;
  int _filesDone = 0;

  void notifySuccess() {
    _filesDone++;
    _controller.add(_getProgress());
    if (_filesDone == _filesTotalNumber) {
      _reset();
    }
  }

  void _reset() {
    _controller.close();
    _filesDone = 0;
    _filesTotalNumber = 0;
    _controller = new StreamController<double>();
  }

  static const double ERROR_INDEX = -1.0;

  void notifyError() {
    _controller.addError(ERROR_INDEX);
  }

  double _getProgress() {
    double progress = (_filesDone / _filesTotalNumber);
    if (progress > 0.97) {
      return 1.0;
    } else {
      return progress;
    }
  }

  StreamController<double> get controller => _controller;

  set filesTotalNumber(int totalNumber) {
    assert(totalNumber > 0, "Files number has to be positive");
    _filesTotalNumber = totalNumber;
  }
}
