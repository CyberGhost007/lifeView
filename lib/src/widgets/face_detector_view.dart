import 'package:ami/src/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/face_detector_provider.dart';
import 'detector_view.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key});

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  @override
  void dispose() {
    FaceDetectorProvider.of().setCanProcess(false);
    FaceDetectorProvider.of().faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Consumer<FaceDetectorProvider>(builder: (context, provider, _) {
          return Column(
            children: [
              Container(
                height: 60,
                width: size.width,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: provider.hasFace ? Colors.green : Colors.blue,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: DynamicText(
                                text: provider.hasFace
                                    ? "Face Detected "
                                    : "Detecting Face.. ",
                                color: Colors.white,
                              ),
                            ),
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DetectorView(
                  title: 'Face Detector',
                  customPaint: provider.customPaint,
                  text: provider.text,
                  onImage: provider.processImage,
                  onCameraFeedReady: () {
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  initialCameraLensDirection: provider.cameraLensDirection,
                  onCameraLensDirectionChanged: (value) =>
                      provider.setCameraLens,
                ),
              ),
            ],
          );
        }),
      ),
    );
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
