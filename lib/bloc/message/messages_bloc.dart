import 'dart:convert';

import 'package:chat_app/bloc/message/messages_state.dart';
import 'package:chat_app/constants/constant.dart';
import 'package:chat_app/data/model/message.dart';
import 'package:chat_app/data/model/room.dart';
import 'package:chat_app/services/service_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'messages_event.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc(MessageState initialState, this.roomID) : super(initialState);

  final String roomID;

  var serviceManager = new ServiceManager();

  @override
  Stream<MessageState> mapEventToState(MessageEvent event) async* {
    if (event is LoadingMessagesEvent) {
      yield* _loadingMessageState();
      try {
        final http.Response response = await serviceManager.fetchRoomRes(roomID);

        if (response.statusCode == 200) {
          var room = Room.fromJson(jsonDecode(response.body));
          yield* _loadedMessageState(LoadedMessagesEvent(room.messages));
        } else {
          switch(response.statusCode){
            case 400:
              yield* _loadFailedState(LoadMessagesFailedEvent(ERROR_MESSAGE_400));
              break;
            case 404:
              yield* _loadFailedState(LoadMessagesFailedEvent(ERROR_MESSAGE_404));
              break;
            case 500:
              yield* _loadFailedState(LoadMessagesFailedEvent(ERROR_MESSAGE_500));
              break;
          }
        }
      } catch (e) {
        print(e.toString());
        yield* _loadFailedState(LoadMessagesFailedEvent(ERROR_MESSAGE_500));
      }
    } else if (event is AddMessageEvent) {
      yield* _addMessageState(event);
    }
  }

  Stream<MessageState> _loadingMessageState() async* {
    print("Loading");
    yield MessageStateLoading();
  }

  Stream<MessageState> _loadFailedState(LoadMessagesFailedEvent event) async*{
    print("Load Failed");
    yield MessageStateLoadFailed(event.errorMessage);
  }

  Stream<MessageState> _loadedMessageState(LoadedMessagesEvent event) async* {
    // Loaded
    yield MessageStateLoaded(event.messages);
  }

  Stream<MessageState> _addMessageState(AddMessageEvent event) async* {
    print("Add Message");
    // Loading
    final List<MessageRoom> updateMessages =
        List.from((state as MessageStateLoaded).messages)..add(event.message);
    yield MessageStateLoaded(updateMessages);
  }
}
