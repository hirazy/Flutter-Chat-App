import 'dart:async';

class StreamControllerHelper{

  static var shared = StreamControllerHelper();

  final StreamController<int> _controller =  StreamController<int>.broadcast();

  Stream<int> get stream => _controller.stream;
  StreamSink<int> get sink => _controller.sink;

  setLastIndex(index) {
    sink.add(index);
  }
}