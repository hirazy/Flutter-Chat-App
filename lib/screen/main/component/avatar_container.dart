
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget avatarContainer(conversationItemData){
  if(conversationItemData.unreadMsgCount > 0){
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Avatar(conversationItemData),
        // Positioned(
        //   right:-3.0 ,
        //   top: -3.0,
        //   //child: unreadMsgCountText(conversationItemData),
        // )
      ],
    );
  }else{
    return Avatar(conversationItemData);
  }
}

Widget Avatar(conversationItemData){
  return Container(
      margin: EdgeInsets.only(left:ScreenUtil().setWidth(20.0)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
      ),
      width: ScreenUtil().setWidth(100),
      height: ScreenUtil().setWidth(100)
  );
}