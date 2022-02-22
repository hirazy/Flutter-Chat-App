import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/constant.dart';
import 'package:chat_app/viewmodel/chat/chat_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as IMG;
import 'package:shimmer/shimmer.dart';

class ChatMessage extends StatelessWidget {
  final ChatViewModel message;
  final bool isMy;
  final bool showAva;

  ChatMessage(
      {required this.message, required this.isMy, required this.showAva});

  int heightAppBar = 50;

  Widget widgetEmpty = const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [_avatarFriend(), _textContent(context, maxWidth)],
            ),
          ),
        ));
  }

  Widget buildImage(BuildContext context) {
    var maxWidth = MediaQuery.of(context).size.width;
    var maxHeight = MediaQuery.of(context).size.height;

    const myColor = Color(0xFF1289FD);
    const yourColor = Color(0xFFE5E4EA);
    const imageColor = Color(0xFFB4B4B4);

    double width = message.isMy ? maxWidth * 0.75 : maxWidth * 0.65;

    return Container(
        decoration: BoxDecoration(
            color: colorIsFriend,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        constraints: BoxConstraints(),
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
                      (message.content.length < 50)
                          ? FutureBuilder(
                              builder: (context, AsyncSnapshot<Size> snapshot) {
                                if (snapshot.hasData) {
                                  var x = snapshot.data!.width;
                                  var y = snapshot.data!.height;
                                  // _resize(width, maxHeight, x, y);

                                  double aspect = x / y;

                                  double maxH = maxHeight * 0.45;

                                  var maxW =
                                      isMy ? maxWidth * 0.8 : maxWidth * 0.65;

                                  if (aspect <= 1.0) {
                                    if (maxW * (1 / aspect) <= maxH) {
                                      y = maxW * (1 / aspect);
                                      x = maxW;
                                    } else {
                                      y = maxH;
                                      x = maxH * aspect;
                                    }
                                  } else if (maxW * (1 / aspect) > maxH ) {
                                    y = maxH;
                                    x = y * aspect;
                                  } else {
                                    double h = maxW * (1 / aspect);

                                    x = maxW;
                                    y = h;
                                  }

                                  return Container(
                                      width: x,
                                      height: y,
                                      child: CachedNetworkImage(
                                          width: x,
                                          height: y,
                                          imageUrl: URL_BASE +
                                              "/images/" +
                                              message.content,
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                                  baseColor: Colors.grey[200]!,
                                                  highlightColor:
                                                      Colors.grey[350]!,
                                                  child: const Center()),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                  color: Colors.grey,
                                                  constraints: BoxConstraints(
                                                      maxWidth: isMy
                                                          ? maxWidth * 0.8
                                                          : maxWidth * 0.65),
                                                  child: const Center(
                                                      child: Icon(
                                                          Icons.error))),
                                          imageBuilder: (context,
                                              ImageProvider imageProvider) {
                                            return Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.contain)));
                                          }));
                                } else {
                                  return CachedNetworkImage(
                                    width: width,
                                    height: maxHeight / 5,
                                    maxWidthDiskCache: width.round(),
                                    maxHeightDiskCache: (maxHeight / 3).round(),
                                    imageUrl:
                                        URL_BASE + "/images/" + message.content,
                                    placeholder: (context, url) => Container(
                                      width: width,
                                      height: maxHeight / 5,
                                      child: Shimmer.fromColors(
                                          baseColor: Colors.grey[200]!,
                                          highlightColor: Colors.grey[350]!,
                                          child: const Center()),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  );
                                }
                              },
                              future: _calculateImageDimension(
                                  URL_BASE + "/images/" + message.content),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
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

  void _resize(double maxWidth, double maxHeight, double width, double height) {
    double aspect = width / height;

    print("_resize " + aspect.toString());

    if (aspect <= 1.0) {
      double heightTmp = maxWidth * (1 / aspect);

      width = maxWidth;
      height = heightTmp;
    }

    if (maxWidth * aspect > maxHeight * 0.45) {
      double heightTmp = maxHeight * 0.45;
      double widthTmp = height * aspect;

      width = widthTmp;
      height = heightTmp;
    }

    double h = maxWidth * aspect;

    width = maxWidth;
    height = h;
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

  _textContent(BuildContext context, maxWidth) {
    return message.isImage
        ? buildImage(context)
        : Container(
            constraints: BoxConstraints(
                maxWidth: isMy ? maxWidth * 0.8 : maxWidth * 0.65),
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
    return (!message.isMy && showAva)
        ? Container(
            child: GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(left: 4.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(heightAppBar * 0.4),
                  child: CachedNetworkImage(
                    height: heightAppBar * 0.8,
                    width: heightAppBar * 0.8,
                    imageUrl:
                        "https://gravatar.com/avatar/${message.senderID}?d=identicon",
                    errorWidget: (context, url, error) => const Image(
                      image: AssetImage('assets/img/ic_avatar.png'),
                    ),
                    placeholder: (context, url) => const Image(
                      image: AssetImage('assets/img/ic_avatar.png'),
                    ),
                  )),
            ),
            onTap: () {},
          ))
        : (!showAva && !isMy)
            ? Container(
                child: GestureDetector(
                    child: Container(
                  margin: const EdgeInsets.only(left: 4.0),
                  child: SizedBox(
                    height: heightAppBar * 0.8,
                    width: heightAppBar * 0.8,
                  ),
                )),
              )
            : widgetEmpty;
  }

  Future<Size> _calculateImageDimension(String url) {
    Completer<Size> completer = Completer();
    Image image =
        Image(image: CachedNetworkImageProvider(url)); // I modified this line
    image.image.resolve(const ImageConfiguration()).addListener(
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
