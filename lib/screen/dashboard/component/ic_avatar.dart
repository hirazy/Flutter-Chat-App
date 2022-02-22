import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

Widget icAvatar(urlAvatar, width, height, callBack) {
  return GestureDetector(
    child: Container(
      margin: const EdgeInsets.only(left: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width / 2),
        child: CachedNetworkImage(
          imageUrl: urlAvatar,
          width: width,
          height: height,
          placeholder: (context, url) => const Image(
            image: AssetImage('assets/img/ic_avatar.png'),
          ),
          imageBuilder: (context, ImageProvider imageProvider) {
            return Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider)));
          },
          errorWidget: (context, url, error) => const Image(
            image: AssetImage('assets/img/ic_avatar.png'),
          ),
        ),
      ),
    ),
    onTap: callBack,
  );
}
