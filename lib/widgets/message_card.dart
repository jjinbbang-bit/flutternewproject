import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mygptrainer/api/apis.dart';
import 'package:mygptrainer/main.dart';

import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromld
        ? _greenMessage()
        : _blueMessage();
  }

  //받은 메세지
  Widget _blueMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //메세지 내용
        //긴 메세지 줄 띄우기 능력 : Flexible
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == 'text'
                ? Text(widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                        //구글 계정 이미지 가져오기
                        imageUrl: widget.message.msg,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 70)),
                  ),
          ),
        ),

        //메세지 보낸 시간
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(widget.message.sent,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ),
      ],
    );
  }

  //보낸 메세지
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * .04),
            //메세지 내용
            const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),
            //긴 메세지 줄 띄우기 능력 : Flexible
            const SizedBox(width: 2),
            //메세지 보낸 시간
            Text('${widget.message.read}12:00 AM',
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == 'text'
                ? Text(widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                        //구글 계정 이미지 가져오기

                        imageUrl: widget.message.msg,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 70)),
                  ),
          ),
        ),
      ],
    );
  }
}
