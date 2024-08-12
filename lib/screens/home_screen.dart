import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mygptrainer/models/chat_user.dart';
import 'package:mygptrainer/models/gemini_coll.dart';
import 'package:mygptrainer/screens/auth/gemini_screen.dart';
import 'package:mygptrainer/screens/auth/jinhome_screen.dart';
import 'package:mygptrainer/screens/auth/profile_screen.dart';

import '../api/apis.dart';
import '../main.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userId = 'yourUserId';
  String docId = 'yourDocId';
  String? _gptimage;
  int _selectedIndex = 2;
  List<Mygptrainer> _list = [];
  //돋보기
  final List<Mygptrainer> _searchlist = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    //GestureDetector => 타자칠 때마다 깜빡이게 기능
    return GestureDetector(
      //    onTap: () => FocusScope.of(context).unfocus(),
      //돋보기 뒤로 가기
      // ignore: deprecated_member_use
        child: WillPopScope(
          onWillPop: () {
            if (_isSearching) {
              _isSearching = !_isSearching;
            } else {}
            // return Future.value(false); // 아무것도 하지 말라는 기능
            return Future.value(true); // 손으로 밀면 뒤로 가는 기능
          },
          child: Scaffold(
            //app bar
              appBar: AppBar(
                  leading: Lottie.asset('assets/lottie/bear.json'),
                  leadingWidth: 100,
                  title: _isSearching
                      ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Name, Email, ...'),
                    autofocus: true,
                    style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                    //돋보기 검색 결과 데이터 변화 반영
                    onChanged: (val) {
                      //돋보기 검색 기능
                      _searchlist.clear();

                      for (var i in _list) {
                        if (i.name
                            .toLowerCase()
                            .contains(val.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(val.toLowerCase())) {
                          _searchlist.add(i);
                        }
                        setState(() {
                          _searchlist;
                        });
                      }
                    },
                  )
                      : Text('SNS'),
                  actions: [
                    //돋보기 버튼
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                          });
                        },
                        icon: Icon(_isSearching
                            ? CupertinoIcons.clear_circled_solid
                            : Icons.search)),
                    //개인 설정 버튼
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ProfileScreen(user: APIs.me)));
                        },
                        icon: const Icon(Icons.more_vert))
                  ]), //사용자 개인 화면으로 이동
              //body
              body: StreamBuilder(
                  stream: APIs.getAllUsers(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                            ?.map((e) => Mygptrainer.fromJson(e.data()))
                            .toList() ??
                            [];
                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            //_isSearching이 되었나 안되었나로 구분 동작
                              itemCount:
                              _isSearching ? _searchlist.length : _list.length,
                              padding: EdgeInsets.only(top: mq.height * 0.01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ChatUserCard(
                                    user: _isSearching
                                        ? _searchlist[index]
                                        : _list[index]); //ChatUserCard
                                // return Text('Name: ${list[index]}');
                              });
                        } else {
                          return Center(
                              child: Text('No Connection Found!',
                                  style: TextStyle(fontSize: 20)));
                        }
                    }
                  }),
              bottomNavigationBar: CircleNavBar(
                activeIcons: const [
                  Icon(Icons.home, color: Colors.deepPurple),
                  Icon(Icons.photo_camera, color: Colors.deepPurple),
                  Icon(Icons.group, color: Colors.deepPurple),
                ],
                inactiveIcons: const [
                  Text("Home"),
                  Text("Camera"),
                  Text("SNS"),
                ],
                color: Colors.deepPurple.shade100,
                circleColor: Colors.white,
                height: 60,
                circleWidth: 60,
                activeIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  if (index == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => JinhomeScreen()),
                    );
                  }
                  {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => JinhomeScreen(showDialogOnLoad: true)),
                    );
                  }
                },
                padding: EdgeInsets.only(
                    left: mq.width * 0.00,
                    right: mq.width * 0.00,
                    bottom: mq.height * 0.062), //메뉴창,
                cornerRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                shadowColor: Colors.deepPurple,
                elevation: 10, //발광하는 보라색 부분
              ),
              floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => GeminiScreen()));
                  },
                  child: Image.asset(
                    'images/bears.png',
                    width: mq.width * 0.12,
                    height: mq.height * 0.12,
                  ))),
        ));
  }

  void _showBottomSheet(String userId, String docId) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * .03,
                  bottom: MediaQuery.of(context).size.height * .07),
              children: [
                const Text('음식 촬영',
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                SizedBox(height: MediaQuery.of(context).size.height * .02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * .4,
                                MediaQuery.of(context).size.height * .2)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 80);
                          if (image != null) {
                            log('Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                            setState(() {
                              _gptimage = image.path;
                            });
                            await APIs.updateGeminiPicture(
                                Gemini(urlImage: image.path), File(_gptimage!));
                            Navigator.pop(context);
                          }
                        },
                        child: Image.asset('images/gallery.png')),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * .4,
                                MediaQuery.of(context).size.height * .2)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 80);
                          if (image != null) {
                            log('Image Path: ${image.path}');
                            setState(() {
                              _gptimage = image.path;
                            });
                            await APIs.updateGeminiPicture(
                                Gemini(urlImage: image.path), File(_gptimage!));
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
