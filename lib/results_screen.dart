import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdbrain/nav_bar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

///The result screen displays the ML results.
///tflite model is ran in baseline_model.dart and sent to this page

class ResultsScreen extends StatefulWidget {
  File _image;
  String duckName;
  String confidence;
  ResultsScreen(this._image, this.duckName, this.confidence);
  @override
  ResultsScreenState createState() => ResultsScreenState(_image, duckName, confidence);
}

class ResultsScreenState extends State<ResultsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference predictionsDB = FirebaseFirestore.instance.collection('predictionsDB');
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  bool showOnFeed = true;
  File _image;
  String confidence;
  String? userPredicted;
  var duckName;

  ResultsScreenState(this._image, this.duckName, this.confidence);

  // dropdown menu so user can choose their own prediction
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
          item,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white,
            color: Colors.black,
          )
      )
  );

  //sends result to firestore server
  Future sendClassification() async {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    final email = user?.email;
    final time = DateTime.now();

    String imgLoc = 'duck_images/$uid${time.year}${time.month}${time.day}${time.hour}${time.second}';
    try {
      await storage.ref(imgLoc).putFile(_image);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
    predictionsDB.add({
      'mlPredicted': duckName,
      'confidence': confidence,
      'userPredicted': userPredicted,
      'image': imgLoc,
      'date': '${time.month.toString()}/${time.day.toString()}/${time.year.toString()} ${time.hour.toString()}:${time.minute.toString()}',
      'uid' : uid,
      'email': email,
      'showOnFeed': showOnFeed,
    }
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final predictionOptions = ['Unknown',
      'Diazi (Mexican Duck)',
      'Platyrhynchos (Mallard Duck)',
      'Other'];
    var duck;
    if (duckName == '0') {
      duck = 'Diazi (Mexican Duck)';
    }
    else {
      duck = 'Platyrhynchos (Mallard Duck)';
    }
    return Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Machine Learning Results',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 0.8),
            )
        ),
        body: Container(
            color: Colors.black.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A363B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                    children:
                      [
                        Text(duck,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "$confidence % confident",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(child: Image.file(_image)),
                      const SizedBox(height: 10),
                      const Text(
                          'Test Result:',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          )
                      ),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          color: Colors.white,
                        ),
                        child: DropdownButton<String>(
                            value: userPredicted,
                            items: predictionOptions.map(buildMenuItem).toList(),
                            onChanged: (value) => setState(() => this.userPredicted = value)
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: sendClassification,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.lightBlue,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: const Center(
                              child: Text(
                                "Save Result",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: () {
                            showOnFeed = false;
                            sendClassification;
                            },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.lightBlue,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: const Center(
                              child: Text(
                                "Discard Result",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                )
            )
        )
    );
  }
}