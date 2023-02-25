import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdbrain/nav_bar.dart';
import '../home.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


///The result screen displays the ML results.
///tflite model is ran in BodyParts/confirm_images.dart and sent to this page

class PreviousBodyResult extends StatefulWidget {
  var _results;
  PreviousBodyResult(this._results, {Key? key}) : super(key: key);
  @override
  PreviousBodyResultState createState() => PreviousBodyResultState(_results);
}

class PreviousBodyResultState extends State<PreviousBodyResult> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference bodyPredictionsDB = FirebaseFirestore.instance.collection('bodyPredictionsDB');
  var _results;
  String? userPredicted;
  int activeIndex = 0;
  late String documentID;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  PreviousBodyResultState(this._results);

  @override
  void initState(){
    super.initState();
    documentID = _results['documentID'];
  }



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

  Future changePrediction() async {
    bodyPredictionsDB.doc(documentID).update({'userPredicted': userPredicted});
    Navigator.pop(context);
  }

  Future deleteResultFromFeed() async {
    bodyPredictionsDB.doc(documentID).update({'showOnFeed': false});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var images = [_results['head_dorsal_image'],
      _results['head_side_image'], _results['head_ventral_image'],
      _results['body_dorsal_image'], _results['body_ventral_image'],
      _results['wing_dorsal_image'], _results['wing_ventral_image']];
    final predictionOptions = ['Unknown',
      'Diazi (Mexican Duck)',
      'Platyrhynchos (Mallard Duck)',
      'Other'];
    var duck = 'diazi';

    Widget buildImage(String image, int index) {
      return Container(
        //margin: EdgeInsets.symmetric(horizontal: 2),
        color: Colors.grey,
        child: Image.network(
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
                child: Column(
                    children: [
                      Text(duck,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "% confident",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                                const SizedBox(height: 5),
                                buildIndicator(),
                              ]
                          )
                      ),
                      const SizedBox(height: 15),
                      const Text(
                          'Your Prediction:',
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
                            onChanged: (value) => setState(() => userPredicted = value)
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: changePrediction,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.lightBlue,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: const Center(
                              child: Text(
                                "Test Result",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: deleteResultFromFeed,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.lightBlue,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: const Center(
                              child: Text(
                                "Delete Result",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
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