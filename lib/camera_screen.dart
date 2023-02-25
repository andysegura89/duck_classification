import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';
import 'BodyParts/head_dorsal_result.dart';
import 'BodyParts/head_side_result.dart';
import 'BodyParts/head_ventral_result.dart';
import 'BodyParts/body_dorsal_result.dart';
import 'BodyParts/body_ventral_result.dart';
import 'BodyParts/wing_dorsal_result.dart';
import 'BodyParts/wing_ventral_result.dart';

class CameraScreen extends StatefulWidget {
  var _overlay_path; //path to overlay image in camera
  var _image_type;
  Map _results;

  CameraScreen(this._image_type, this._results, this._overlay_path);
  @override
  _CameraScreenState createState() =>
      _CameraScreenState(_image_type, _results, _overlay_path);
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  var _overlay_path;
  var _image_type;
  Map _results;
  _CameraScreenState(this._image_type, this._results, this._overlay_path);

  File? _imageFile;
  File? _videoFile;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  bool _outlineShown = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  void redirect(imageFile) {
    _currentFlashMode == FlashMode.off;
    if (_image_type == 'head_dorsal') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HeadDorsalResult(imageFile, _results)));
    }
    if (_image_type == 'head_side') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HeadSideResult(imageFile, _results)));
    }
    if (_image_type == 'head_ventral') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HeadVentralResult(imageFile, _results)));
    }
    if (_image_type == 'body_dorsal') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BodyDorsalResult(imageFile, _results)));
    }
    if (_image_type == 'body_ventral') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BodyVentralResult(imageFile, _results)));
    }
    if (_image_type == 'wing_dorsal') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WingDorsalResult(imageFile, _results)));
    }
    if (_image_type == 'wing_ventral') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WingVentralResult(imageFile, _results)));
    }
  }
  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(cameras[0]);
      //refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }



  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }


  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = FlashMode.off;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  @override
  void initState() {
    // Hide the status bar in Android
    SystemChrome.setEnabledSystemUIOverlays([]);
    getPermissionStatus();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isCameraPermissionGranted
            ? _isCameraInitialized
            ? Column(
          children: [
            AspectRatio(
              //aspectRatio: 1 / controller!.value.aspectRatio,
              aspectRatio: 1.6/1,
              child: Stack(
                children: [
                  CameraPreview(
                    controller!,
                    child: LayoutBuilder(builder:
                        (BuildContext context,
                        BoxConstraints constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) =>
                            onViewFinderTap(details, constraints),
                      );
                    }),
                  ),
                  _outlineShown? Center(
                    child: Image.asset( //image overlay in camera feed
                      _overlay_path,
                      color: Colors.white,
                      width: 400,
                      height: 400,
                    ),
                  ) : const Center(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16.0,
                      8.0,
                      16.0,
                      8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0, top: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${_currentExposureOffset
                                    .toStringAsFixed(1)}x',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              height: 30,
                              child: Slider(
                                value: _currentExposureOffset,
                                min: _minAvailableExposureOffset,
                                max: _maxAvailableExposureOffset,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    _currentExposureOffset = value;
                                  });
                                  await controller!
                                      .setExposureOffset(value);
                                },
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _currentZoomLevel,
                                min: _minAvailableZoom,
                                max: _maxAvailableZoom,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    _currentZoomLevel = value;
                                  });
                                  await controller!
                                      .setZoomLevel(value);
                                },
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(right: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${_currentZoomLevel
                                        .toStringAsFixed(1)}x',
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell( //switch cameras
                              onTap: _isRecordingInProgress
                                  ? () async {
                              }
                                  : () {
                                setState(() {
                                  _isCameraInitialized = false;
                                });
                                onNewCameraSelected(cameras[
                                _isRearCameraSelected
                                    ? 1
                                    : 0]);
                                setState(() {
                                  _isRearCameraSelected =
                                  !_isRearCameraSelected;
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.black38,
                                    size: 60,
                                  ),
                                  _isRecordingInProgress
                                      ? controller!
                                      .value.isRecordingPaused
                                      ? const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                      : const Icon(
                                    Icons.pause,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                      : Icon(
                                    _isRearCameraSelected
                                        ? Icons.camera_front
                                        : Icons.camera_rear,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                            InkWell(  //take picture button
                              onTap: () async {
                                XFile? rawImage =
                                await takePicture();
                                File imageFile =
                                File(rawImage!.path);

                                int currentUnix = DateTime.now()
                                    .millisecondsSinceEpoch;

                                final directory =
                                await getApplicationDocumentsDirectory();

                                String fileFormat = imageFile
                                    .path
                                    .split('.')
                                    .last;

                                print(fileFormat);

                                await imageFile.copy(
                                  '${directory.path}/$currentUnix.$fileFormat',
                                );
                                redirect(imageFile);
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.white38,
                                    size: 80,
                                  ),
                                  Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 65,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                ),
                                child: GestureDetector(
                                    child: const Text('Outline'),
                                    onTap: () => {
                                      setState(() {
                                        _outlineShown = !_outlineShown;
                                      })

                                    }
                                ),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          16.0, 8.0, 16.0, 8.0),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _currentFlashMode = FlashMode.off;
                              });
                              await controller!.setFlashMode(
                                FlashMode.off,
                              );
                            },
                            child: Icon(
                              Icons.flash_off,
                              color:
                              _currentFlashMode == FlashMode.off
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _currentFlashMode = FlashMode.auto;
                              });
                              await controller!.setFlashMode(
                                FlashMode.auto,
                              );
                            },
                            child: Icon(
                              Icons.flash_auto,
                              color:
                              _currentFlashMode == FlashMode.auto
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _currentFlashMode = FlashMode.always;
                              });
                              await controller!.setFlashMode(
                                FlashMode.always,
                              );
                            },
                            child: Icon(
                              Icons.flash_on,
                              color: _currentFlashMode ==
                                  FlashMode.always
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _currentFlashMode = FlashMode.torch;
                              });
                              await controller!.setFlashMode(
                                FlashMode.torch,
                              );
                            },
                            child: Icon(
                              Icons.highlight,
                              color:
                              _currentFlashMode == FlashMode.torch
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        )
            : const Center(
          child: Text(
            'LOADING',
            style: TextStyle(color: Colors.white),
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(),
            const Text(
              'Permission denied',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                getPermissionStatus();
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: const Text(
                  'Give permission',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}