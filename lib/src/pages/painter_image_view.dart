import 'package:ami/src/widgets/dynamic_text.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';

import '../providers/face_detector_provider.dart';

class PainterImageView extends StatefulWidget {
  final String? imagePath;
  const PainterImageView({super.key, this.imagePath});

  @override
  State<PainterImageView> createState() => _PainterImageViewState();
}

class _PainterImageViewState extends State<PainterImageView> {
  int selectedIndex = 2;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back)),
            ),
            Expanded(
              child: Hero(
                tag: "imageHero",
                child: Consumer<FaceDetectorProvider>(
                    builder: (context, provider, widgetChild) {
                  if (provider.imgSize != null &&
                      provider.customPaint != null) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        FittedBox(
                          child: SizedBox(
                            width: provider.imgSize!.width,
                            height: provider.imgSize!.height,
                            child: provider.customPaint!,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
              ),
            ),
            SizedBox(
              height: 100,
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              width: 3,
                              color: selectedIndex == index
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                          width: selectedIndex == index ? 70 : 50,
                          height: selectedIndex == index ? 70 : 50,
                          child: Center(
                            child: Image.asset(
                              _asset(index),
                              width: 30,
                            ),
                          ),
                        ),
                        const Spacer(),
                        DynamicText(
                          text: _getText(index),
                          fontWeight: FontWeight.bold,
                          fontSize: selectedIndex == index ? 14 : 12,
                        )
                      ],
                    ),
                  );
                },
                index: selectedIndex,
                onIndexChanged: (value) {
                  if (value == 0) {
                    FaceDetectorProvider.of().changeContourMap(
                      InputImage.fromFilePath(widget.imagePath!),
                      {FaceContourType.leftEye},
                    );
                  }
                  if (value == 1) {
                    FaceDetectorProvider.of().changeContourMap(
                      InputImage.fromFilePath(widget.imagePath!),
                      {FaceContourType.rightEye},
                    );
                  }
                  if (value == 2) {
                    FaceDetectorProvider.of().changeContourMap(
                      InputImage.fromFilePath(widget.imagePath!),
                      {},
                    );
                  }

                  if (value == 3) {
                    FaceDetectorProvider.of().changeContourMap(
                      InputImage.fromFilePath(widget.imagePath!),
                      {
                        FaceContourType.upperLipTop,
                        FaceContourType.upperLipBottom,
                        FaceContourType.lowerLipTop,
                        FaceContourType.lowerLipBottom,
                      },
                    );
                  }
                  if (value == 4) {
                    FaceDetectorProvider.of().changeContourMap(
                      InputImage.fromFilePath(widget.imagePath!),
                      {
                        FaceContourType.noseBridge,
                        FaceContourType.noseBottom,
                      },
                    );
                  }

                  if (value == 5) {
                    FaceDetectorProvider.of().changeContourMap(
                      InputImage.fromFilePath(widget.imagePath!),
                      {
                        FaceContourType.leftEyebrowTop,
                        FaceContourType.leftEyebrowBottom,
                        FaceContourType.rightEyebrowTop,
                        FaceContourType.rightEyebrowBottom,
                      },
                    );
                  }

                  setState(() {
                    selectedIndex = value;
                  });
                },
                itemCount: 6,
                viewportFraction: 0.2,
                scale: 0.9,
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  String _asset(int index) {
    if (index == 0) {
      return "assets/itchy1.png";
    }
    if (index == 1) {
      return "assets/itchy1.png";
    }
    if (index == 2) {
      return "assets/face-recognition.png";
    }
    if (index == 3) {
      return "assets/lip.png";
    }
    if (index == 4) {
      return "assets/itchy.png";
    }
    if (index == 5) {
      return "assets/closed-eyes-with-lashes-and-brows.png";
    }

    return "assets/face-recognition.png";
  }

  String _getText(int index) {
    if (index == 0) {
      return "Left Eye";
    }
    if (index == 1) {
      return "Right Eye";
    }
    if (index == 2) {
      return "Overall";
    }
    if (index == 3) {
      return "Lips";
    }
    if (index == 4) {
      return "Nose";
    }
    if (index == 5) {
      return "Eye Brows";
    }

    return "assets/face-recognition.png";
  }
}
