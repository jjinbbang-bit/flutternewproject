import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mygptrainer/main.dart';
import 'package:mygptrainer/models/chat_user.dart';
import 'package:mygptrainer/screens/auth/chat_screen.dart';
class ChatUserCard extends StatefulWidget {
  final Mygptrainer user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}
class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      color: Color.fromARGB(201, 247, 247, 247), //채팅 상대 색깔
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: ListTile(
          //leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .3),
            child: CachedNetworkImage(
              //구글 계정 이미지 가져오기
              width: mq.height * .055,
              height: mq.height * .055,
              imageUrl: widget.user.image,
              //placeholder: (context, url) =>
              //    const CircleAvatar(child: Icon(CupertinoIcons.person)),
              errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
          title: Text(widget.user.name),
          subtitle: Text(widget.user.about, maxLines: 1),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
                //파란불 들어오는 기능
                color: Color.fromARGB(255, 0, 230, 215),
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}