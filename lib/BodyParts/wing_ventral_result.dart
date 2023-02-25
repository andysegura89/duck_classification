import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:birdbrain/BodyParts/confirm_images.dart';
import 'package:birdbrain/nav_bar.dart';

class WingVentralResult extends StatefulWidget {
  File _image;
  Map _results;
  WingVentralResult(this._image, this._results);

  @override
  _WingVentralResultState createState() => _WingVentralResultState(_image, _results);
}

class _WingVentralResultState extends State<WingVentralResult> {
  File _image;
  Map _results;

  _WingVentralResultState(this._image, this._results);

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
      model: 'assets/baseline.tflite',
      labels: 'assets/labels.txt',
    );
  }
  //runs image through tflite model
  classifyImage(File image) async {
    _results['wing_ventral'] = [image];
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
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 50),
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
              const Text('Stomach side of the wing:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )
              ),
              SizedBox(height:20),
              Image.file(_image,
                  width: 300,
                  height: 300),
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
                      print(_results.toString());
                      await classifyImage(_image);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ConfirmImages(_results)));
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