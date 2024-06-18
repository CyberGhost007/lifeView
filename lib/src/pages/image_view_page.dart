import 'dart:io';

import 'package:flutter/material.dart';

import '../providers/face_detector_provider.dart';
import '../widgets/dynamic_button.dart';
import '../widgets/dynamic_text.dart';
import '../widgets/gallery_view.dart';

class ImageViewPage extends StatefulWidget {
  final String imagePath;
  const ImageViewPage({super.key, required this.imagePath});

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Image'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(widget.imagePath), fit: BoxFit.cover),
          Positioned(
            bottom: 19,
            left: 18,
            right: 18,
            child: DynamicButton(
              height: 60,
              backgroundColor: Colors.black,
              child: const DynamicText(
                text: "Analyse Image",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              onPressed: () {
                FaceDetectorProvider.of().reset();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GalleryView(
                      image: File(widget.imagePath),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
