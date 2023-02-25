import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdbrain/nav_bar.dart';
import '../home.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

///The result screen displays the ML results.
///tflite model is ran in BodyParts/confirm_images.dart and sent to this page

class BodyResultsScreen extends StatefulWidget {
  Map _results;
  BodyResultsScreen(this._results, {Key? key}) : super(key: key);
  @override
  BodyResultsScreenState createState() => BodyResultsScreenState(_results);
}

class BodyResultsScreenState extends State<BodyResultsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference bodyPredictionsDB = FirebaseFirestore.instance.collection('bodyPredictionsDB');
  Map _results;
  String? userPredicted;
  bool _showOnFeed = true;
  bool sendingClassification = false;
  int activeIndex = 0;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  int sum = 0;
  int threshold = 5;
  BodyResultsScreenState(this._results);


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
    sendingClassification = true;
    setState((){});
    final User? user = auth.currentUser;
    final uid = user?.uid;
    final email = user?.email;
    final time = DateTime.now();

    String head_dorsal_img = 'body_sequence_images/head_dorsal-$uid${time.year}${time.month}${time.day}${time.hour}${time.second}';
    String head_side_img = 'body_sequence_images/head_side-$uid${time.year}${time.month}${time.day}${time.hour}${time.second}';
    String head_ventral_img = 'body_sequence_images/head_ventral-$uid${time.year}${time.month}${time.day}${time.hour}${time.second}';
    String body_dorsal_img = 'body_sequence_images/body_dorsal-$uid${time.year}${time.month}${time.day}${time.hour}${time.second}';
    String body_ventral_img = 'body_sequence_images/body_ventral-$uid${time.year}${time.month}${time.day}${time.hour}${time.second}';
    String wing_dorsal_img = 'body_sequence_images/wing_dorsal-$uid${time.year}${time.month}${time.day}${time.hour}${time.second}';
    String wing_ventral_img = 'body_sequence_images/wing_ventral-$uid${time.year}${time.month}${time.day}${time.hour}${time.second}';

    try {
      await storage.ref(head_dorsal_img).putFile(File(_results['head_dorsal'][0].path));
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
    try {
      await storage.ref(head_side_img).putFile(File(_results['head_side'][0].path));
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
    try {
      await storage.ref(head_ventral_img).putFile(File(_results['head_ventral'][0].path));
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
    try {
      await storage.ref(body_dorsal_img).putFile(File(_results['body_dorsal'][0].path));
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
    try {
      await storage.ref(body_ventral_img).putFile(File(_results['body_ventral'][0].path));
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
    try {
      await storage.ref(wing_dorsal_img).putFile(File(_results['wing_dorsal'][0].path));
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
    try {
      await storage.ref(wing_ventral_img).putFile(File(_results['wing_ventral'][0].path));
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }


    bodyPredictionsDB.add(
        {
      'date': '${time.month.toString()}/${time.day.toString()}/${time.year.toString()} ${time.hour.toString()}:${time.minute.toString()}',
      'uid' : uid,
      'email': email,
      'showOnFeed': _showOnFeed,
      'user_predicted': userPredicted,
      'head_dorsal_image': head_dorsal_img,
      'head_dorsal_label': _results['head_dorsal'][1],
      'head_dorsal_confidence': _results['head_dorsal'][2],
      'head_side_image': head_side_img,
      'head_side_label': _results['head_side'][1],
      'head_side_confidence': _results['head_side'][2],
      'head_ventral_image': head_ventral_img,
      'body_dorsal_image': body_dorsal_img,
      'body_dorsal_label': _results['body_dorsal'][1],
      'body_dorsal_confidence': _results['body_dorsal'][2],
      'body_ventral_image': body_ventral_img,
      'body_ventral_label': _results['body_ventral'][1],
      'body_ventral_confidence': _results['body_ventral'][2],
      'wing_dorsal_image': wing_dorsal_img,
      'wing_dorsal_label': _results['wing_dorsal'][1],
      'wing_dorsal_confidence': _results['wing_dorsal'][2],
      'wing_dorsal_lesser_label': _results['wing_dorsal_lesser'][1],
      'wing_dorsal_lesser_confidence': _results['wing_dorsal_lesser'][2],
      'wing_dorsal_secondary_label': _results['wing_dorsal_secondary'][1],
      'wing_dorsal_secondary_confidence': _results['wing_dorsal_secondary'][2],
      'wing_dorsal_primary_label': _results['wing_dorsal_primary'][1],
      'wing_dorsal_primary_confidence': _results['wing_dorsal_primary'][2],
      'wing_ventral_image': wing_ventral_img,
      }
    );

    print('user_predicted: $userPredicted');
    goHome();
  }

  void goHome() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Home()));
  }



  @override
  Widget build(BuildContext context) {
    var images = [_results['head_dorsal'][0],
      _results['head_side'][0], _results['head_ventral'][0],
      _results['body_dorsal'][0], _results['body_ventral'][0],
      _results['wing_dorsal'][0], _results['wing_ventral'][0]];
    final predictionOptions = ['Unknown',
      'Diazi (Mexican Duck)',
      'Platyrhynchos (Mallard Duck)',
      'Other'];
    sum += int.parse(_results['head_side'][1]);
    sum += int.parse(_results['body_dorsal'][1]);
    sum += int.parse(_results['body_ventral'][1]);
    sum += int.parse(_results['body_ventral_overall'][1]);
    sum += int.parse(_results['wing_dorsal'][1]);
    sum += int.parse(_results['wing_dorsal_secondary'][1]);
    sum += int.parse(_results['wing_dorsal_lesser'][1]);
    var duck = sum < 5 ? 'Diazi': 'Platyrhynchos';

    Widget buildImage(File image, int index) {
      return Container(
        //margin: EdgeInsets.symmetric(horizontal: 2),
        color: Colors.grey,
        child: Image.file(
            image,
            fit: BoxFit.cover,
        ),
      );
    }

    Widget buildIndicator() => AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: 7,
    );


    return Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'ML Results',
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
                child: !sendingClassification? Column(
                    children:
                    [
                      Text(duck,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      const Text(
                        "",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                CarouselSlider.builder(
                                options: CarouselOptions(
                                    height:200,
                                    onPageChanged: (index, reason) =>
                                        setState(() => activeIndex = index),
                                ),
                                itemCount: 7,
                                itemBuilder: (context, index, realIndex) {
                                  final image = images[index];
                                  return buildImage(image, index);
                                },
                              ),
                              SizedBox(height: 5),
                              buildIndicator(),
                            ]
                          )
                      ),
                      SizedBox(height: 15),
                      const Text(
                          'Your Prediction:',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          )
                      ),
                      SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          color: Colors.white,
                        ),
                        child: DropdownButton<String>(
                            value: userPredicted,
                            items: predictionOptions.map(buildMenuItem).toList(),
                            onChanged: (value) => setState(() => userPredicted = value)
                        ),
                      ),
                      const SizedBox(height: 20),
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
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: () {
                            _showOnFeed = false;
                            sendClassification;
                          },
                          child: Container(
                            padding: EdgeInsets.all(20),
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
                ) : CircularProgressIndicator()
            )
        )
    );
  }
}