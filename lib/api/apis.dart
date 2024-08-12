import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mygptrainer/models/chat_user.dart';
import 'package:mygptrainer/models/message.dart';
import 'package:mygptrainer/widgets/chat_user_card.dart';

class APIs {
  //권한
  static FirebaseAuth auth = FirebaseAuth.instance;
  //DATABASE 접근 권한(EC2)
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  //FirebaseStorge 접근 권한(Bucket)
  static FirebaseStorage storage = FirebaseStorage.instance;
  //자기 정보 저장
  static late Mygptrainer me;
  //정보 복귀
  static User get user => auth.currentUser!;
  //사용자가 있는지 없는지
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //현재 사용자
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = Mygptrainer.fromJson(user.data()!);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }
  //새로운 사용자 만들기

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = Mygptrainer(
        id: user.uid, //since user = auth.currentUser!
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "편의점 음식 먹지 말기",
        image: user.photoURL.toString(),
        createdAt: time,
        isonline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //User 정보 update
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  //프로파일 이미지 storage 저장
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension : $ext');
    //프로파일 이미지 위치 조사
    final ref = storage.ref().child('profile.pictures/${user.uid}.');
    //해당 위치 이미지 업로드
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    //firestore에 집어 넣기
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  /// *************** Chat Screen Related APIs **********************
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';
  // 받은 메세지를 Firsbase에 모두 저장
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      Mygptrainer ChatUser) {
    return firestore
        .collection('chats/${getConversationID(ChatUser.id)}/messages/')
        .snapshots();
  }

// chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)
  static Future<void> sendMessages(Mygptrainer chatUser, String msg,
      {String type = 'text'}) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final message = Message(
      msg: msg,
      read: '',
      told: chatUser.id,
      fromld: user.uid,
      type: type,
      sent: time,
    );

    try {
      await firestore
          .collection('chats/${getConversationID(chatUser.id)}/messages/')
          .doc(time)
          .set(message.toJson());
      log('Message sent successfully');
    } catch (e) {
      log('Failed to send message: $e');
    }
  }

  static Future<void> sendChatImage(Mygptrainer chatUser, File file,
      {String type = 'image'}) async {
    final ext = file.path.split('.').last;

    //프로파일 이미지 위치 조사
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    //해당 위치 이미지 업로드
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    //firestore에 집어 넣기
    final imageUrl = await ref.getDownloadURL();
    await sendMessages(chatUser, imageUrl, type: 'image');
  }
}
