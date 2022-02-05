import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/constant.dart';
import 'package:chat_app/viewmodel/chat/chat_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as IMG;

class ChatMessage extends StatelessWidget {
  final ChatViewModel message;
  final bool isMy;

  ChatMessage({required this.message, required this.isMy});

  int heightAppBar = 50;

  Widget widgetEmpty = const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  Widget buildMessage(BuildContext context) {
    return message.isImage ? buildImage(context) : buildText(context);
  }

  Widget buildImage(BuildContext context) {
    var maxWidth = MediaQuery.of(context).size.width;
    var maxHeight = MediaQuery.of(context).size.height;

    const myColor = Color(0xFF1289FD);
    const yourColor = Color(0xFFE5E4EA);
    const imageColor = Color(0xFFB4B4B4);

    double width = message.isMy ? maxWidth * 0.75 : maxWidth * 0.65;

    return Container(
        margin: isMy
            ? const EdgeInsets.only(right: 0, top: 5)
            : const EdgeInsets.only(left: 0, top: 5),
        child: Align(
          alignment:
              message.isMy ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            child: Column(
              crossAxisAlignment: message.isMy
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  child: Container(
                      child: Row(
                    children: [
                      (message.content.toLowerCase().endsWith('.png') &&
                              message.content.length < 50)
                          ? CachedNetworkImage(
                                width: width,
                                height: maxHeight / 5,
                                imageUrl:
                                    URL_BASE + "/images/" + message.content,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                fadeOutDuration: const Duration(seconds: 1),
                                fadeInDuration: const Duration(seconds: 3),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                imageBuilder:
                                    (context, ImageProvider imageProvider) {
                                  return Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: ResizeImage(imageProvider,height: 200, width: 200 ),
                                              fit: BoxFit.cover)));
                                },
                              )
                          : Container(
                              child: Image.memory(resizeImage(
                                  base64Decode(message.content),
                                  width,
                                  maxHeight))),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ));
  }

  Uint8List resizeImage(Uint8List data, double maxWidth, double maxHeight) {
    Uint8List resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    int width = img!.width;
    int height = img!.height;

    double aspect = width / height;

    if (aspect < 1.0) {
      int x = maxWidth.round();
      double height = maxWidth * (1 / aspect);
      int y = height.round();

      IMG.Image resized = IMG.copyResize(img!, width: x, height: y);
      resizedData = (IMG.encodeJpg(resized) as Uint8List?)!;
      return resizedData;
    }

    if (maxWidth * aspect > maxHeight * 0.45) {
      double height = maxHeight * 0.45;
      int y = height.round();
      double width = height * aspect;
      int x = width.round();

      IMG.Image resized = IMG.copyResize(img!, width: x, height: y);
      resizedData = (IMG.encodeJpg(resized) as Uint8List?)!;
      return resizedData;
    }

    double h = maxWidth * aspect;
    int y = h.round();

    int x = maxWidth.round();

    IMG.Image resized = IMG.copyResize(img!, width: x, height: y);
    resizedData = (IMG.encodeJpg(resized) as Uint8List?)!;

    return resizedData;
  }

  Widget buildText(BuildContext context) {
    var maxWidth = MediaQuery.of(context).size.width;
    return Container(
        margin: isMy
            ? const EdgeInsets.only(right: 6, top: 4)
            : const EdgeInsets.only(left: 6, top: 5),
        child: Align(
          alignment:
              message.isMy ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            child: Row(
              mainAxisAlignment: message.isMy
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [_avatarFriend(), _textContent(context, maxWidth)],
            ),
          ),
        ));
  }

  _textContent(BuildContext context, maxWidth) {
    return Container(
        constraints:
            BoxConstraints(maxWidth: isMy ? maxWidth * 0.8 : maxWidth * 0.65),
        margin: message.isMy ? null : const EdgeInsets.only(left: 3),
        child: message.isImage
            ? buildImage(context)
            : Padding(
                padding: const EdgeInsets.all(7),
                child: Text(
                  message.content,
                  style: TextStyle(
                      color: message.isMy ? Colors.white : Colors.black,
                      fontSize: 17),
                ),
              ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: message.isImage
              ? colorIsFriend
              : (message.isMy ? colorIsMy : colorIsFriend),
        ));
  }

  _avatarFriend() {
    return !message.isMy
        ? Container(
            child: GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(left: 4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(heightAppBar * 0.4),
                child: Image.network(
                  URL_ICON,
                  height: heightAppBar * 0.8,
                  width: heightAppBar * 0.8,
                ),
              ),
            ),
            onTap: () {},
          ))
        : widgetEmpty;
  }

  Future<Size> _calculateImageDimension() {
    Completer<Size> completer = Completer();
    Image image = new Image(
        image: CachedNetworkImageProvider(
            "https://i.stack.imgur.com/lkd0a.png")); // I modified this line
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }
}
