import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mygptrainer/api/apis.dart';
import 'package:mygptrainer/main.dart';
import 'package:mygptrainer/screens/auth/login_screen.dart';
import 'package:mygptrainer/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));
      if (APIs.auth.currentUser != null) {
        log('\nUser : ${APIs.auth.currentUser}');

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(top: 35.0),
          child: Text('Welcome to Gptrainer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20, color: Colors.black87, letterSpacing: 0.5)),
        ),
      ),
      body: Stack(children: [
        Positioned(
            top: mq.height * .15,
            right: mq.width * 0.25,
            width: mq.width * .5,
            child: Image.asset('images/icon.png')),
        Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Text('MADE IN KHU WITH JHK',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.black, letterSpacing: 0.5))),
      ]),
    );
  }
}
