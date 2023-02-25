import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdbrain/BodyParts/head_dorsal.dart';
import 'package:birdbrain/nav_bar.dart';

class BodyStart extends StatefulWidget {
  @override
  _BodyStartState createState() => _BodyStartState();
}

class _BodyStartState extends State<BodyStart> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final picker = ImagePicker(); //allows us to pick image from gallery or camera

  //disposes and clears memory
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Body Parts Model',
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
                child: Column(
                  children: [
                    Text("You will now be instructed to upload 7 "
                        "images based on the duck's bodypart",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            )
                    ),
                    SizedBox(height: 30),
                    GestureDetector( // take a photo button
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HeadDorsal()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 200,
                        alignment: Alignment.center,
                        padding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Get Started',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
