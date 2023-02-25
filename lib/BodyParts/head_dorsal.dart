import 'dart:io';
import 'package:birdbrain/login_page.dart';
import 'package:birdbrain/results_screen.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdbrain/BodyParts/head_dorsal_result.dart';
import 'package:birdbrain/nav_bar.dart';
import 'package:birdbrain/camera_screen.dart';

class HeadDorsal extends StatefulWidget {
  @override
  _HeadDorsalState createState() => _HeadDorsalState();
}

class _HeadDorsalState extends State<HeadDorsal> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late File _image;
  final picker = ImagePicker(); //allows us to pick image from gallery or camera
  Map _results = {};
  //first function that is executed by default when this class is called
  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

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
                HeadDorsalResult(_image, _results)));
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
                HeadDorsalResult(_image, _results)));
  }

  //loads tflite model
  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/duck_model.tflite',
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ResultsScreen(_image,
                      output[0]['label'],
                      "${(output[0]['confidence'] * 100).toStringAsFixed(3)}")));
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
          '1 of 7',
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
                        'Back side of the head:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                    SizedBox(height: 20),
                    Image.asset('assets/Head_Dorsal.png',
                    height: 200,
                    width: 200,
                    ),
                    SizedBox(height:20),
                    GestureDetector( // take a photo button
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CameraScreen('head_dorsal', _results,
                                    'assets/Head_Dorsal.png')))
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
                    const SizedBox(height: 15),
                    GestureDetector( // pick from gallery button
                      onTap: pickGalleryImage,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 200,
                        alignment: Alignment.center,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
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