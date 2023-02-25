import 'dart:io';
import 'package:birdbrain/login_page.dart';
import 'package:birdbrain/results_screen.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:birdbrain/previous_classifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdbrain/nav_bar.dart';

/// home page allows user to select picture from camera or gallery
/// home.dart then runs the image through the tflite
/// model and sends data to results_screen.dart.
/// User can also choose to view previous ML results

class BaselineModel extends StatefulWidget {
  @override
  _BaselineModelState createState() => _BaselineModelState();
}

class _BaselineModelState extends State<BaselineModel> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late File _image;
  final picker = ImagePicker(); //allows us to pick image from gallery or camera

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
    classifyImage(_image);
  }

  //this function is used to grab the image from gallery
  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  //loads tflite model
  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/sat1.tflite',
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
                child: Column(
                  children: [
                    GestureDetector( // take a photo button
                      onTap: pickImage,
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
                    const SizedBox(height: 15),
                    GestureDetector( // Previous Results Button
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PreviousClassifications()));
                      },
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
                          'Previous Results',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
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
