import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final Set<FaceContourType> contourTypesToDraw;

  FacePainter(this.image, this.faces, this.contourTypesToDraw);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // final Paint boundingBoxPaint = Paint()
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 2.0
    //   ..color = Colors.yellow;

    final Paint landmarkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;

    final Paint leftEyePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.blue;

    final Paint rightEyePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.green;

    final Paint mouthPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.orange;

    final Paint nosePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.purple;

    final Paint cheekPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.pink;

    final Paint eyebrowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.brown;

    final Paint contourPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.blueGrey;

    canvas.drawImage(image, Offset.zero, Paint());

    for (var face in faces) {
      // Draw bounding box
      // canvas.drawRect(face.boundingBox, boundingBoxPaint);

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

      // Draw contours with different colors for each component based on the provided set or if set is empty
      face.contours.forEach((type, contour) {
        if (contour != null &&
            (contourTypesToDraw.isEmpty || contourTypesToDraw.contains(type))) {
          final List<Offset> points = contour.points
              .map((point) => Offset(point.x.toDouble(), point.y.toDouble()))
              .toList();
          if (points.isNotEmpty) {
            Paint paint;
            switch (type) {
              case FaceContourType.leftEye:
                paint = leftEyePaint;
                break;
              case FaceContourType.rightEye:
                paint = rightEyePaint;
                break;
              case FaceContourType.upperLipTop:
              case FaceContourType.upperLipBottom:
              case FaceContourType.lowerLipTop:
              case FaceContourType.lowerLipBottom:
                paint = mouthPaint;
                break;
              case FaceContourType.noseBridge:
              case FaceContourType.noseBottom:
                paint = nosePaint;
                break;
              case FaceContourType.leftCheek:
              case FaceContourType.rightCheek:
                paint = cheekPaint;
                break;
              case FaceContourType.leftEyebrowTop:
              case FaceContourType.leftEyebrowBottom:
              case FaceContourType.rightEyebrowTop:
              case FaceContourType.rightEyebrowBottom:
                paint = eyebrowPaint;
                break;
              default:
                paint = contourPaint;
            }
            for (var i = 0; i < points.length - 1; i++) {
              canvas.drawLine(points[i], points[i + 1], paint);
            }
          }
        }
      });

      // Optional: Connect key facial features with lines or more dots
      // if (face.landmarks[FaceLandmarkType.leftEye] != null &&
      //     face.landmarks[FaceLandmarkType.rightEye] != null) {
      //   canvas.drawLine(
      //     Offset(
      //         face.landmarks[FaceLandmarkType.leftEye]!.position.x.toDouble(),
      //         face.landmarks[FaceLandmarkType.leftEye]!.position.y.toDouble()),
      //     Offset(
      //         face.landmarks[FaceLandmarkType.rightEye]!.position.x.toDouble(),
      //         face.landmarks[FaceLandmarkType.rightEye]!.position.y.toDouble()),
      //     contourPaint,
      //   );
      // }

      // if (face.landmarks[FaceLandmarkType.leftEar] != null &&
      //     face.landmarks[FaceLandmarkType.rightEar] != null) {
      //   canvas.drawLine(
      //     Offset(
      //         face.landmarks[FaceLandmarkType.leftEar]!.position.x.toDouble(),
      //         face.landmarks[FaceLandmarkType.leftEar]!.position.y.toDouble()),
      //     Offset(
      //         face.landmarks[FaceLandmarkType.rightEar]!.position.x.toDouble(),
      //         face.landmarks[FaceLandmarkType.rightEar]!.position.y.toDouble()),
      //     contourPaint,
      //   );
      // }

      // if (face.landmarks[FaceLandmarkType.noseBase] != null &&
      //     face.landmarks[FaceLandmarkType.bottomMouth] != null) {
      //   canvas.drawLine(
      //     Offset(
      //         face.landmarks[FaceLandmarkType.noseBase]!.position.x.toDouble(),
      //         face.landmarks[FaceLandmarkType.noseBase]!.position.y.toDouble()),
      //     Offset(
      //         face.landmarks[FaceLandmarkType.bottomMouth]!.position.x
      //             .toDouble(),
      //         face.landmarks[FaceLandmarkType.bottomMouth]!.position.y
      //             .toDouble()),
      //     contourPaint,
      //   );
      // }
    }
  }

  @override
  bool shouldRepaint(FacePainter old) {
    return image != old.image ||
        faces != old.faces ||
        contourTypesToDraw != old.contourTypesToDraw;
  }
}
