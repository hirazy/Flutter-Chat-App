import 'package:chat_app/constants/constant.dart';
import 'package:chat_app/data/model/room.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ic_avatar.dart';

Widget CardShuffle(RoomShuffle room, onTap) {
  return GestureDetector(
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            icAvatar(room.picture, 40.0, 40.0, onTap),
            Container(
              margin: const EdgeInsets.only(left: 10, top: 3),
              child: Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      room.name,
                      style: TextStyle(
                          color: Colors.black54,
                          fontWeight: room.isSeen
                              ? FontWeight.normal
                              : FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      room.recentMessage,
                      style: TextStyle(
                          color: Colors.black54,
                          fontWeight: room.isSeen
                              ? FontWeight.normal
                              : FontWeight.bold),
                    ),
                  ),
                ],
              )),
            )
          ],
        ),
      ),
      onTap: onTap);
}
