import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdbrain/BodyParts/wing_ventral_result.dart';
import 'package:birdbrain/nav_bar.dart';
import '../camera_screen.dart';

class WingVentral extends StatefulWidget {
  Map _results;
  WingVentral(this._results);
  @override
  _WingVentralState createState() => _WingVentralState(_results);
}

class _WingVentralState extends State<WingVentral> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late File _image;
  final picker = ImagePicker(); //allows us to pick image from gallery or camera
  Map _results;
  _WingVentralState(this._results);

  //this function is used to grab the image from camera
  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                WingVentralResult(_image, _results)));
  }

  //this function is used to grab the image from gallery
  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                WingVentralResult(_image, _results)));
  }


  //disposes and clears memory
  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          '7 of 7',
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
                    const Text(
                        'Stomach side of the wing:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                    SizedBox(height: 20),
                    Image.asset('assets/Wing_Ventral.png',
                      height: 200,
                      width: 200,
                    ),
                    SizedBox(height: 20),
                    GestureDetector( // take a photo button
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CameraScreen('wing_ventral', _results,
                                        'assets/Wing_Ventral.png')))
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 200,
                        alignment: Alignment.center,
                        padding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'Take A Photo',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector( // pick from gallery button
                      onTap: pickGalleryImage,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 200,
                        alignment: Alignment.center,
                        padding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'Choose from Gallery',
                          textAlign: TextAlign.center,
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