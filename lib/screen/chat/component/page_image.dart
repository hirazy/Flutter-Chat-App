import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PageImage extends StatelessWidget {
  late List<String> galleryItems;
  late int indexStart;

  int currentIndex = 0;

  PageImage({required this.galleryItems, required this.indexStart});

  @override
  Widget build(BuildContext context) {
    currentIndex = indexStart;

    return Stack(children: [
      Container(
          child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Container(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              );
            },
            imageProvider:
                NetworkImage(URL_BASE + "/images/" + galleryItems[index]),
            initialScale: PhotoViewComputedScale.contained * 1,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: index),
          );
        },
        itemCount: galleryItems.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: indexStart),
        onPageChanged: (index) {
          currentIndex = index;
        },
      )),
      Container(
        margin: EdgeInsets.only(left: 50, bottom: 50),
        child: Align(
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              child: const Icon(
                Icons.download,
                size: 40,
                color: Colors.white,
              ),
              onTap: () {
                String url = galleryItems[currentIndex];
                _download(url);
              },
            )),
      )
    ]);
  }

  _download(String url) async{

    var imageId = await ImageDownloader.downloadImage("https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter.png");
    if (imageId == null) {
      return;
    }

    showToast("Downloaded Image Successfully!", Colors.green);

  }

  void showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: color,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
