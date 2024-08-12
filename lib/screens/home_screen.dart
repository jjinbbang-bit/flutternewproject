import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mygptrainer/models/chat_user.dart';
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
      onTap: () => FocusScope.of(context).unfocus(),
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
              leading: Icon(CupertinoIcons.home),
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
                  : Text('Gptrainer'),
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

          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
                onPressed: () async {
                  await APIs.auth.signOut();
                  await GoogleSignIn().signOut();
                },
                child: const Icon(Icons.add_comment_rounded)),
          ),
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
        ),
      ),
    );
  }
}
