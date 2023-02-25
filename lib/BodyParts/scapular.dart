import 'dart:io';
import 'package:birdbrain/login_page.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdbrain/nav_bar.dart';
import 'package:birdbrain/BodyParts/speculum.dart';

/// home page allows user to select picture from camera or gallery
/// home.dart then runs the image through the tflite
/// model and sends data to results_screen.dart.
/// User can also choose to view previous ML results

class Scapular extends StatefulWidget {
  Map _results;
  File _image;
  Scapular(this._results, this._image);
  @override
  _ScapularState createState() => _ScapularState(_results, _image);
}

class _ScapularState extends State<Scapular> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  File _image;
  Map _results;
  _ScapularState(this._results, this._image);


  //first function that is executed by default when this class is called
  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
    classifyImage(_image);
  }


  //loads tflite model
  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/baseline.tflite',
      labels: 'assets/labels.txt',
    );
  }
  //runs image through tflite model
  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      //the amount of categories our neural network can predict (here no. of animals)
      threshold: 0,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (output != null) {
      _results['scapular'] = [
        _image,
        output[0]['label'],
        output[0]['confidence']
      ];

    }

    dispose();
    if (output != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Speculum(_results, _image)));
    }
  }

  //sign out function
  signOut() async {
    await auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  //disposes and clears memory
  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Baseline',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 23,
          ),
        ),
      ),
      body: Container(
        color: Colors.black.withOpacity(0.9),
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 50),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text('Running model 4 on image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}