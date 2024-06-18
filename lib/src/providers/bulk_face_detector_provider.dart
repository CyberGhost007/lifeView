import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import '../models/face_detect_image_model.dart';
import '../services/helpers/face_detector_painter.dart';
import '../services/helpers/face_image_painter.dart';
import '../utils/constants.dart';
import 'dart:ui' as ui;

class BulkFaceDetectorProvider with ChangeNotifier {
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

  final List<FaceDetectImageModel> _images = [];
  List<FaceDetectImageModel> get images => _images;

  void addImages(List<XFile> images) {
    _images.clear();
    for (var image in images) {
      _images.add(FaceDetectImageModel(imagePath: image.path));
    }

    notifyListeners();

    _processImage();
  }

  void _processImage() async {
    for (var image in _images) {
      reset();
      final inputImage = InputImage.fromFilePath(image.imagePath!);
      await processImage(inputImage);
      image.hasFace = _hasFace;
      image.imageWidget = _customPaint;
      image.imgSize = _imgSize;

      if (!image.hasFace!) {
        log("No Face");
      }
    }

    notifyListeners();
  }

  void setCameraLens(CameraLensDirection lens) {
    _cameraLensDirection = lens;
    notifyListeners();
  }

  void setCanProcess(bool cp) {
    _canProcess = cp;
    notifyListeners();
  }

  Future<void> processImage(InputImage inputImage,
      {Set<FaceContourType>? featuresToDraw}) async {
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
      final painter = FacePainter(img, faces, featuresToDraw ?? {});
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

  void changeContourMap(
      InputImage inputImage, Set<FaceContourType> featuresToDraw) {
    processImage(inputImage, featuresToDraw: featuresToDraw);
  }

  static BulkFaceDetectorProvider of({bool listen = false}) =>
      Provider.of<BulkFaceDetectorProvider>(
        Constants.navigatorKey.currentContext!,
        listen: listen,
      );
}
