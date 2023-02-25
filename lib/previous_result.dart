import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdbrain/nav_bar.dart';



/// Displays a previously saved result and allows the user
/// to change the user prediction or delete from
/// their previous_classifications.dart feed
/// (Note: deleting from feed does not delete from the server)

class PreviousResult extends StatefulWidget {
  String _image;
  String mlPredicted;
  String confidence;
  String userPredicted;
  String uid;
  String documentID;
  String date;

  PreviousResult(this._image, this.mlPredicted, this.confidence,
      this.userPredicted, this.uid, this.documentID, this.date);

  @override
  PreviousResultState createState() => PreviousResultState(
      _image, mlPredicted, confidence, userPredicted, uid, documentID, date);
}

class PreviousResultState extends State<PreviousResult> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference predictionsDB = FirebaseFirestore.instance.collection('predictionsDB');
  final String _image;
  String mlPredicted;
  String confidence;
  String userPredicted;
  String uid;
  String documentID;
  String date;
  String? userPredictedDropdown;

  PreviousResultState(this._image, this.mlPredicted, this.confidence,
      this.userPredicted, this.uid, this.documentID, this.date);

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
    predictionsDB.doc(documentID).update({'userPredicted': userPredictedDropdown});
  }

  Future deleteResultFromFeed() async {
    predictionsDB.doc(documentID).update({'showOnFeed': false});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final predictionOptions = ['Unknown',
      'Diazi (Mexican Duck)',
      'Platyrhynchos (Mallard Duck)',
      'Other'];
    return Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Previous Result',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 0.8),
            )
        ),
        body: Container(
            color: Colors.black.withOpacity(0.9),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Color(0xFF2A363B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                    children: [
                      Text(
                        mlPredicted,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        confidence + "% confident",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                          date,
                          style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                          //child: Image(image: Image.memory(base64Decode(_image)).image)),
                          //child: Image(image: Image.network(_image)),
                         child: Image.network(_image)),
                      SizedBox(height: 20),
                      const Text(
                          'Test Result',
                          textAlign: TextAlign.center,
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
                            value: userPredictedDropdown,
                            items: predictionOptions.map(buildMenuItem).toList(),
                            onChanged: (value) => setState(() => this.userPredictedDropdown = value!)
                        ),
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0),
                        child: GestureDetector(
                          onTap: changePrediction,
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.lightBlue,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: const Center(
                              child: Text(
                                "Change user prediction",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: deleteResultFromFeed,
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.lightBlue,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: const Center(
                              child: Text(
                                "Delete result",
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
