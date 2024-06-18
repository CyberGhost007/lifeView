import 'dart:developer';

import 'package:ami/src/pages/heart_beat_page.dart';
import 'package:ami/src/providers/face_detector_provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/bulk_face_detector_provider.dart';
import '../widgets/dynamic_button.dart';
import '../widgets/dynamic_text.dart';
import '../widgets/face_detector_view.dart';
import '../widgets/gallery_view.dart';
import 'bulk_images_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showButton = false;
  final ImagePicker picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const SizedBox(height: 20),
              SizedBox(
                height: size.height * 0.3,
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    repeatForever: false,
                    pause: const Duration(milliseconds: 2000),
                    animatedTexts: [
                      TyperAnimatedText("Hi, I'm Ami",
                          textAlign: TextAlign.center),
                      TyperAnimatedText(
                        "Your personal AI skincare assistant.",
                        textAlign: TextAlign.center,
                      ),
                      TyperAnimatedText(
                        "Upload a photo and I'll identify spots, blackheads, and acne.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                    onTap: () {
                      log("Tap Event");
                    },
                    onNext: (p0, p1) {
                      log(p0.toString());
                      setState(() {
                        if (p0 == 2) {
                          showButton = true;
                        }
                      });
                    },
                  ),
                ),
              ),
              const Spacer(),
              if (showButton)
                DynamicButton(
                  backgroundColor: Colors.black,
                  child: const DynamicText(
                    text: "Heart Rate Monitor",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HeartBeatPage(),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 18),
              if (showButton)
                DynamicButton(
                  backgroundColor: Colors.blue,
                  child: const DynamicText(
                    text: "Bulk Image Detection",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    final List<XFile> images =
                        await picker.pickMultiImage(limit: 10);

                    if (images.isEmpty || images.length < 10) return;
                    BulkFaceDetectorProvider.of().addImages(images);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BulkImagesPage(),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 8),
              if (showButton)
                Row(
                  children: [
                    Flexible(
                      child: DynamicButton(
                        backgroundColor: const Color(0xff645FEB),
                        child: const DynamicText(
                          text: "Upload Photo",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          FaceDetectorProvider.of().reset();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GalleryView(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: DynamicButton(
                        backgroundColor: Colors.green,
                        child: const DynamicText(
                          text: "Take Photo",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          FaceDetectorProvider.of().reset();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FaceDetectorView(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
