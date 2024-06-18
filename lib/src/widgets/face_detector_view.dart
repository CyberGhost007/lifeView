import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'detector_view.dart';
import '../services/helpers/face_detector_painter.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key});

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      onCameraFeedReady: () {
        if (mounted) {
          setState(() {});
        }
      },
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    log('Faces found: ${faces.length}');
    for (var face in faces) {
      log('Face bounding box: ${face.boundingBox}');
      log(face.headEulerAngleY.toString());
      log(face.headEulerAngleZ.toString());
      log(face.headEulerAngleX.toString());
      log(face.leftEyeOpenProbability.toString());
      log(face.rightEyeOpenProbability.toString());
      log(face.smilingProbability.toString());
      log(face.trackingId.toString());
      log(face.landmarks.toString());
      for (var l in face.landmarks.entries) {
        var key = l.key;
        FaceLandmark landmark = l.value as FaceLandmark;
        log('Landmark: $key, ${landmark.position}');
      }
      log(face.contours.toString());
    }
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

class BoundingRectPainter extends CustomPainter {
  final Rect boundingRect;

  BoundingRectPainter(this.boundingRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawRect(boundingRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}