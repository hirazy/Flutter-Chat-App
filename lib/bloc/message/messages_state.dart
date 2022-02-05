import 'package:chat_app/data/model/message.dart';

abstract class MessageState {
  MessageState([List props = const []]) : super();
}

class MessageStateLoaded extends MessageState {
  late final List<MessageRoom> messages;

  MessageStateLoaded(this.messages);

  @override
  String toString() => 'MessageStateLoaded { contents: $messages }';
}

class MessageStateLoading extends MessageState {
  @override
  String toString() => 'ContentsLoading';
}

class MessageStateLoadMore extends MessageState{
  @override
  String toString() => 'ContentsLoading';
}

class MessageStateLoadFailed extends MessageState{

  late final error;

  MessageStateLoadFailed(this.error);

  @override
  String toString() => 'MessageStateLoadFailed {}';
}