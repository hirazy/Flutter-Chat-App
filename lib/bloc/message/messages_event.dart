import 'package:chat_app/data/model/message.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class MessageEvent extends Equatable {
  MessageEvent([List props = const []]) : super();
}

class LoadedMessagesEvent extends MessageEvent{

  final List<MessageRoom> messages;

  LoadedMessagesEvent(this.messages) : super([messages]);

  @override
  List<Object?> get props => props;
}

class LoadingMessagesEvent extends MessageEvent {
  @override
  String toString() => 'LoadContents';

  @override
  List<Object?> get props => props;
}

class LoadMoreEvent extends MessageEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class AddMessageEvent extends MessageEvent {
  final MessageRoom message;

  AddMessageEvent(this.message) : super([message]);

  @override
  List<Object?> get props => props;
}

class LoadMessagesFailedEvent extends MessageEvent{

  final String errorMessage;

  LoadMessagesFailedEvent(this.errorMessage);

  @override
  List<Object?> get props => throw UnimplementedError();
}