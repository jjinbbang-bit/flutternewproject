import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mygptrainer/api/apis.dart';
import 'package:mygptrainer/helper/dialogs.dart';
import 'package:mygptrainer/main.dart';
import 'package:mygptrainer/screens/auth/jinhome_screen.dart';
import 'package:mygptrainer/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      //far hiding progress bar
      Navigator.pop(context);

      if (user != null) {
        log('\nUser : ${user.user}');
        log('\nUserAdditionalInfo : ${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const JinhomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const JinhomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackbar(context, 'Something went wrong (check Internet)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    //mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/pig.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
            bottom: mq.height * 0.15,
            width: mq.width,
            height: mq.height * 0.07,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(212, 255, 195, 206),
                ),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
                icon: Image.asset('images/google.png'),
                label: RichText(
                    text: const TextSpan(
                        style: TextStyle(color: Colors.white, fontSize: 19),
                        children: [
                      TextSpan(text: 'Login in with '),
                      TextSpan(
                          text: 'Google',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ]))))
      ]),
    );
  }
}
