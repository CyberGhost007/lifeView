import 'dart:io';
import 'package:ami/src/providers/face_detector_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../pages/report_page.dart';
import 'dynamic_text.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({
    Key? key,
    this.image,
  }) : super(key: key);

  final File? image;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
    _image = null;
    _path = null;

    if (widget.image != null) {
      _image = widget.image;
      _path = widget.image?.path;
      _processFile(_path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                  const Flexible(
                    child: DynamicText(
                      text: "Face Detector",
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _galleryBody()),
          ],
        ),
      ),
    );
  }

  Widget _galleryBody() {
    return Consumer<FaceDetectorProvider>(builder: (context, provider, _) {
      return Column(
        children: [
          if (_image == null || !provider.hasFace)
            GestureDetector(
              onTap: () {
                _getImage(ImageSource.gallery);
              },
              child: Container(
                margin: const EdgeInsets.all(14),
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(width: 1, color: Colors.grey.shade200)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate,
                      size: 50,
                    ),
                    DynamicText(
                        text: (_image != null && !provider.hasFace)
                            ? "The photo does not contain any face"
                            : "Click to upload an image"),
                  ],
                ),
              ),
            )
          else
            ReportPage(
              imagePath: _path,
              text: provider.text,
            ),
        ],
      );
    });
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future _processFile(String path) async {
    setState(() {
      _image = File(path);
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    FaceDetectorProvider.of().processImage(inputImage);
  }
}
