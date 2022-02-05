import 'package:chat_app/data/model/room.dart';
import 'package:chat_app/data/model/user.dart';

abstract class ShuffleBlocState{
}

class ShuffleLoadingState extends ShuffleBlocState{

  @override
  String toString() => 'ShuffleLoading';
}

class ShuffleLoadedState extends ShuffleBlocState{
  late final List<RoomShuffle> rooms;

  ShuffleLoadedState(this.rooms);

  @override
  String toString() => 'ShuffleLoadedState { contents: $rooms }';
}

class ShuffleLoadMoreState extends ShuffleBlocState{
  @override
  String toString() => 'ShuffleLoading';
}

class ShuffleLoadErrorState extends ShuffleBlocState{
  late final String error;
  @override
  String toString() => 'ShuffleLoading';
}