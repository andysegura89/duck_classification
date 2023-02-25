import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:birdbrain/home.dart';

/*
This page checks if the user is logged in. If they are,
then it redirects them to main.dart. If not, they get
redirected to login_page.dart
*/

class LoginCheck extends StatelessWidget {
  const LoginCheck({Key? key}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Home();
          }
          else {
            return LoginPage();
          }
        }
      ),
    );
  }
}