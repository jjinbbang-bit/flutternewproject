import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygptrainer/helper/dialogs.dart';
import 'package:mygptrainer/models/chat_user.dart';
import 'package:mygptrainer/screens/auth/login_screen.dart';

import '../../api/apis.dart';
import '../../main.dart';
import '../../widgets/chat_user_card.dart';



class ProfileScreen extends StatefulWidget {
  final Mygptrainer user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //app bar
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: const Text('프로필'),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
                backgroundColor: Colors.redAccent,
                onPressed: () async {
                  Dialogs.showProgressBar(context);
                  await APIs.auth.signOut().then((value) async {
                    await GoogleSignIn().signOut().then((value) {});
                    //다이얼로그 숨기기
                    Navigator.pop(context);
                    //로그인 화면으로 이동시키기
                    Navigator.pop(context);

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  });
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout')),
          ),
          //body
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(children: [
                  SizedBox(width: mq.width, height: mq.height * .03),
                  //leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  Stack(
                    children: [
                      //profile image
                      _image != null
                          ?
                          //내 프로파일(휴대폰에 저장된 이미지)
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(File(_image!),
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  //프로필 이미지를 Cover할지 그냥 짜를지, fill하게 채울지 선택가능
                                  fit: BoxFit.cover))
                          :
                          //서버에 저장된 이미지
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                //구글 계정 이미지 가져오기
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                //placeholder: (context, url) =>
                                //    const CircleAvatar(child: Icon(CupertinoIcons.person)),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                        child: Icon(CupertinoIcons.person)),
                              ),
                            ),
                      //갤러리 카메라 이미지 버튼으로 바꾸기
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: mq.height * .03), //별명 칸 크기

                  Text(widget.user.email,
                      style: TextStyle(color: Colors.black54, fontSize: 18)),
                  SizedBox(height: mq.height * 0.04),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'eg. 홍길동',
                        label: Text('NickName')),
                  ),

                  SizedBox(height: mq.height * .02),

                  SizedBox(height: mq.height * 0.05),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.info_outline, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'eg. 식단 목표',
                        label: Text('about')),
                  ),
                  SizedBox(height: mq.height * 0.06),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        minimumSize: Size(mq.width * .4, mq.height * .06)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        log('inside validator');
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(
                              context, 'Profile Updated Successfully!');
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, size: 28),
                    label: const Text('UPDATE', style: TextStyle(fontSize: 16)),
                  ),
                ]),
              ),
            ),
          )),
    );
  }

  //사용자 프로파일 사진을 가지고 올 수 있는 곳.
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                  top: mq.height * .03, bottom: mq.height * .05),
              children: [
                //사진 가져오기
                const Text('Pick Profile Picture',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                //공간 확보
                SizedBox(height: mq.height * .02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //갤러리로 가져오기(그림만 아직 완전히 구현된거 아님.)
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            fixedSize: Size(mq.width * .3, mq.height * .15)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 80);
                          if (image != null) {
                            log('Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                            setState(() {
                              _image = image.path;
                            });
                            APIs.updateProfilePicture(File(_image!));
                            //bOttom sheet
                            Navigator.pop(context);
                          }
                          // Capture a photo.
                        },
                        child: Image.asset('images/gallery.png')),
                    //카메라로 찍어서 가져오기
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            fixedSize: Size(mq.width * .3, mq.height * .15)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 80);
                          if (image != null) {
                            log('Image Path: ${image.path}');
                            setState(() {
                              _image = image.path;
                            });
                            APIs.updateProfilePicture(File(_image!));
                            //bOttom sheet
                            Navigator.pop(context);
                          }
                        },
                        child: Image.asset('images/camera.png'))
                  ],
                )
              ]);
               });
  }
}
