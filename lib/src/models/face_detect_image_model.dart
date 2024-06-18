import 'package:flutter/material.dart';

class FaceDetectImageModel {
  CustomPaint? imageWidget;
  bool? hasFace;
  String? imagePath;
  Size? imgSize;

  FaceDetectImageModel({
    this.imagePath,
    this.hasFace,
    this.imageWidget,
    this.imgSize,
  });
}
