import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import '../services/helpers/face_detector_painter.dart';
import '../utils/constants.dart';
import 'dart:ui' as ui;

class FaceDetectorProvider with ChangeNotifier {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String _text = "";
  CameraLensDirection _cameraLensDirection = CameraLensDirection.front;
  bool _hasFace = false;

  // Expose Values
  FaceDetector get faceDetector => _faceDetector;
  bool get canProcess => _canProcess;
  bool get isBusy => _isBusy;
  CustomPaint? get customPaint => _customPaint;
  String get text => _text;
  CameraLensDirection get cameraLensDirection => _cameraLensDirection;
  bool get hasFace => _hasFace;

  // Static image landmarks
  Map<FaceLandmarkType, FaceLandmark?> _faceLandMarks = {};
  Map<FaceLandmarkType, FaceLandmark?> get faceLandMarks => _faceLandMarks;

  Size? _imgSize;
  Size? get imgSize => _imgSize;

  void setCameraLens(CameraLensDirection lens) {
    _cameraLensDirection = lens;
    notifyListeners();
  }

  void setCanProcess(bool cp) {
    _canProcess = cp;
    notifyListeners();
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    _text = '';

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      _hasFace = false;
    } else {
      _hasFace = true;
    }
    notifyListeners();
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
      _faceLandMarks = face.landmarks;
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
      ui.Image img = await decodeImageFromList(
          File(inputImage.filePath!).readAsBytesSync());

      _imgSize = Size(img.width.toDouble(), img.height.toDouble());
      final painter = FacePainter(img, faces);
      _customPaint = CustomPaint(painter: painter);

      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
    }
    _isBusy = false;
    notifyListeners();
  }

  void reset() {
    _canProcess = true;
    _isBusy = false;
    _customPaint = null;
    _text = "";
    _hasFace = false;
    notifyListeners();
  }

  static FaceDetectorProvider of({bool listen = false}) =>
      Provider.of<FaceDetectorProvider>(
        Constants.navigatorKey.currentContext!,
        listen: listen,
      );
}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;

  FacePainter(this.image, this.faces);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint boundingBoxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.yellow;

    final Paint landmarkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;

    final Paint contourPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.blue;

    canvas.drawImage(image, Offset.zero, Paint());

    for (var face in faces) {
      // Draw bounding box
      canvas.drawRect(face.boundingBox, boundingBoxPaint);

      // Draw landmarks
      face.landmarks.forEach((type, landmark) {
        if (landmark != null) {
          final offset = Offset(
              landmark.position.x.toDouble(), landmark.position.y.toDouble());
          canvas.drawCircle(
            offset,
            2.0, // radius of the circle
            landmarkPaint,
          );
        }
      });

      // Draw contours
      face.contours.forEach((type, contour) {
        if (contour != null) {
          final List<Offset> points = contour.points
              .map((point) => Offset(point.x.toDouble(), point.y.toDouble()))
              .toList();
          if (points.isNotEmpty) {
            for (var i = 0; i < points.length - 1; i++) {
              canvas.drawLine(points[i], points[i + 1], contourPaint);
            }
          }
        }
      });

      // Optional: Connect key facial features with lines or more dots
      if (face.landmarks[FaceLandmarkType.leftEye] != null &&
          face.landmarks[FaceLandmarkType.rightEye] != null) {
        canvas.drawLine(
          Offset(
              face.landmarks[FaceLandmarkType.leftEye]!.position.x.toDouble(),
              face.landmarks[FaceLandmarkType.leftEye]!.position.y.toDouble()),
          Offset(
              face.landmarks[FaceLandmarkType.rightEye]!.position.x.toDouble(),
              face.landmarks[FaceLandmarkType.rightEye]!.position.y.toDouble()),
          contourPaint,
        );
      }

      if (face.landmarks[FaceLandmarkType.leftEar] != null &&
          face.landmarks[FaceLandmarkType.rightEar] != null) {
        canvas.drawLine(
          Offset(
              face.landmarks[FaceLandmarkType.leftEar]!.position.x.toDouble(),
              face.landmarks[FaceLandmarkType.leftEar]!.position.y.toDouble()),
          Offset(
              face.landmarks[FaceLandmarkType.rightEar]!.position.x.toDouble(),
              face.landmarks[FaceLandmarkType.rightEar]!.position.y.toDouble()),
          contourPaint,
        );
      }

      if (face.landmarks[FaceLandmarkType.noseBase] != null &&
          face.landmarks[FaceLandmarkType.bottomMouth] != null) {
        canvas.drawLine(
          Offset(
              face.landmarks[FaceLandmarkType.noseBase]!.position.x.toDouble(),
              face.landmarks[FaceLandmarkType.noseBase]!.position.y.toDouble()),
          Offset(
              face.landmarks[FaceLandmarkType.bottomMouth]!.position.x
                  .toDouble(),
              face.landmarks[FaceLandmarkType.bottomMouth]!.position.y
                  .toDouble()),
          contourPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FacePainter old) {
    return image != old.image || faces != old.faces;
  }
}
