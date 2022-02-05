import 'package:chat_app/viewmodel/chat/chat_view_model_list.dart';
import 'package:mobx/mobx.dart';

mixin _$ChatListState on ChatListVM, Store{
  final _messageStatusAtom = Atom(name: 'ChatListVm.messageStatus');

  MessageStatus get messageStatus{
    _messageStatusAtom.reportRead();
    return super.messageStatus;
  }

}