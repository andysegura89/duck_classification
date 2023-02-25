import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:birdbrain/BodyParts/body_ventral.dart';
import 'package:birdbrain/nav_bar.dart';

class BodyDorsalResult extends StatefulWidget {
  File _image;
  Map _results;
  BodyDorsalResult(this._image, this._results);

  @override
  _BodyDorsalResultState createState() => _BodyDorsalResultState(_image, _results);
}

class _BodyDorsalResultState extends State<BodyDorsalResult> {
  File _image;
  Map _results;

  _BodyDorsalResultState(this._image, this._results);

  //first function that is executed by default when this class is called
  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  //disposes and clears memory
  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/body_dorsal_model.tflite',
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
    print(output.toString());

    if (output != null) {
      _results['body_dorsal'] = [
        _image,
        output[0]['label'],
        output[0]['confidence']
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Result',
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
              const Text('Back side of the body:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )
              ),
              SizedBox(height:20),
              Image.file(_image,
              width: 300,
              height: 300
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  GestureDetector( //try again button
                    onTap: () {Navigator.pop(context);},
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: const Center(
                        child: Text(
                          "Try Again",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      await classifyImage(_image);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BodyVentral(_results)));
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: const Center(
                        child: Text(
                          "Accept",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}