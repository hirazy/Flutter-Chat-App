import 'package:equatable/equatable.dart';

abstract class ShuffleEvent extends Equatable{

}

class ShuffleLoadingEvent extends ShuffleEvent{
  @override
  List<Object?> get props => throw UnimplementedError();
}

class ShuffleLoadedEvent extends ShuffleEvent{
  @override
  List<Object?> get props => throw UnimplementedError();
}