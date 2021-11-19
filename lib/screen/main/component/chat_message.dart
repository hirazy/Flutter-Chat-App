import 'dart:convert';

import 'package:chat_app/viewmodel/chat/chat_view_model.dart';
import 'package:flutter/cupertino.dart';

class ChatMessage extends StatelessWidget {
  final ChatViewModel message;

  ChatMessage({required this.message, required bool isMy});

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  Widget buildImage(BuildContext context) {
    return Align(
      alignment: message.isMy ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment:
              message.isMy ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                    color: message.isMy
                        ? const Color(0xFF1289FD)
                        : const Color(0xFFE5E4EA)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: 300,
                    height: 250,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(
                            base64Decode(message.content),
                          ),
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildText(BuildContext context){
    return Align(
      alignment: message.isMy ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
      ),
    );
  }
}
