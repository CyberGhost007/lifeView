import 'package:ami/src/providers/bulk_face_detector_provider.dart';
import 'package:ami/src/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';

import '../providers/face_detector_provider.dart';
import 'painter_image_view.dart';

class BulkImagesPage extends StatefulWidget {
  const BulkImagesPage({super.key});

  @override
  State<BulkImagesPage> createState() => _BulkImagesPageState();
}

class _BulkImagesPageState extends State<BulkImagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Image Detection'),
      ),
      body: Consumer<BulkFaceDetectorProvider>(builder: (context, provider, _) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1.0,
          ),
          itemCount: provider.images.length,
          itemBuilder: (context, index) {
            var data = provider.images[index];
            return Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14)),
              child: data.imageWidget != null &&
                      data.hasFace != null &&
                      data.hasFace!
                  ? GestureDetector(
                      onTap: () {
                        FaceDetectorProvider.of().reset();
                        final inputImage =
                            InputImage.fromFilePath(data.imagePath!);
                        FaceDetectorProvider.of().processImage(inputImage);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PainterImageView(imagePath: data.imagePath!),
                          ),
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FittedBox(
                            child: Hero(
                              tag: "imageHero",
                              child: SizedBox(
                                width: data.imgSize!.width,
                                height: data.imgSize!.height,
                                child: data.imageWidget!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        if (data.hasFace == null)
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: CircularProgressIndicator()),
                              Center(child: DynamicText(text: "Processing")),
                            ],
                          ),
                        if ((data.hasFace != null && !data.hasFace!))
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: Icon(Icons.broken_image)),
                              Center(
                                  child: DynamicText(text: "No face detected")),
                            ],
                          ),
                      ],
                    ),
            );
          },
          padding: const EdgeInsets.all(10.0),
        );
      }),
    );
  }
}
