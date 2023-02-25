import 'package:flutter/material.dart';
import 'package:birdbrain/login_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duck Classification',
      home: LoginCheck(),
      debugShowCheckedModeBanner: false,
    );
  }
}