
import 'package:chat_app/services/service_manager.dart';
import 'package:chat_app/viewmodel/chat/chat_view_model.dart';
import 'package:mobx/mobx.dart';


// class ChatListState = ChatListVM with _$ChatListState;

enum MessageStatus { loading, loaded, empty }

abstract class ChatListVM with Store{

  @observable
  MessageStatus messageStatus = MessageStatus.empty;

  @observable
  ObservableList<ChatViewModel> messageList = ObservableList();

  @observable
  ObservableList<String> writingUsers = ObservableList<String>();

  // @action
  // Future<void> fetchMessage(String receiverID) async{
  //   messageStatus = MessageStatus.loading;
  //
  //   var list = await ServiceManager.shared.fetchRoom(receiverID);
  //   this.messageList =
  //       ObservableList.of((list.map((e) => ChatViewModel(message: e))));
  //
  //   if (messageList.isNotEmpty) {
  //     // Veri Var ise
  //     messageStatus = MessageStatus.loaded;
  //   } else {
  //     messageStatus = MessageStatus.empty;
  //   }
  // }

}
