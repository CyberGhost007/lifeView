import 'dart:developer';
import 'dart:io';

import 'package:ami/src/widgets/dynamic_text.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:provider/provider.dart';

import '../pages/image_view_page.dart';
import '../providers/face_detector_provider.dart';

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key,
      required this.customPaint,
      required this.onImage,
      this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.back})
      : super(key: key);

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  final bool _changingCameraLens = false;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    return Container(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _changingCameraLens
              ? const Center(
                  child: Text('Changing camera lens'),
                )
              : CameraPreview(
                  _controller!,
                  child: widget.customPaint,
                ),
          _zoomControl(),
          _exposureControl(),
          Align(
            alignment: Alignment.bottomCenter,
            child:
                Consumer<FaceDetectorProvider>(builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton.extended(
                  label: const DynamicText(text: "Capture"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  onPressed: () {
                    if (provider.hasFace) {
                      _takePicture();
                    }
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: provider.hasFace ? Colors.blue : Colors.grey,
                  icon: const Icon(Icons.camera),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _takePicture() async {
    XFile? imageFile;
    try {
      final XFile picture = await _controller!.takePicture();
      setState(() {
        imageFile = picture;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewPage(imagePath: imageFile!.path),
        ),
      );
    } catch (e) {
      log("Error taking picture: $e");
    }
  }

  Widget _zoomControl() => Positioned(
        top: 40,
        left: 8,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x Zoom',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: Slider(
                    value: _currentZoomLevel,
                    min: _minAvailableZoom,
                    max: _maxAvailableZoom,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentZoomLevel = value;
                      });
                      await _controller?.setZoomLevel(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _exposureControl() => Positioned(
        top: 40,
        right: 8,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 250,
          ),
          child: Column(children: [
            Container(
              width: 55,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    '${_currentExposureOffset.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  height: 30,
                  child: Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentExposureOffset = value;
                      });
                      await _controller?.setExposureOffset(value);
                    },
                  ),
                ),
              ),
            )
          ]),
        ),
      );

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }

        log("Loggin Face");
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // * nv21 for Android
    // * bgra8888 for iOS
    log("Camera Format nv21: $format");
    // if (format == null ||
    //     (Platform.isAndroid && format != InputImageFormat.nv21) ||
    //     (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    // if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: image.getNv21Uint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format!, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}

extension Nv21Converter on CameraImage {
  Uint8List getNv21Uint8List() {
    final width = this.width;
    final height = this.height;

    final yPlane = planes[0];
    final uPlane = planes[1];
    final vPlane = planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final numPixels = (width * height * 1.5).toInt();
    final nv21 = List<int>.filled(numPixels, 0);

    // Full size Y channel and quarter size U+V channels.
    int idY = 0;
    int idUV = width * height;
    final uvWidth = width ~/ 2;
    final uvHeight = height ~/ 2;
    // Copy Y & UV channel.
    // NV21 format is expected to have YYYYVU packaging.
    // The U/V planes are guaranteed to have the same row stride and pixel stride.
    // getRowStride analogue??
    final uvRowStride = uPlane.bytesPerRow;
    // getPixelStride analogue
    final uvPixelStride = uPlane.bytesPerPixel ?? 0;
    final yRowStride = yPlane.bytesPerRow;
    final yPixelStride = yPlane.bytesPerPixel ?? 0;

    for (int y = 0; y < height; ++y) {
      final uvOffset = y * uvRowStride;
      final yOffset = y * yRowStride;

      for (int x = 0; x < width; ++x) {
        nv21[idY++] = yBuffer[yOffset + x * yPixelStride];

        if (y < uvHeight && x < uvWidth) {
          final bufferIndex = uvOffset + (x * uvPixelStride);
          //V channel
          nv21[idUV++] = vBuffer[bufferIndex];
          //V channel
          nv21[idUV++] = uBuffer[bufferIndex];
        }
      }
    }
    return Uint8List.fromList(nv21);
  }
}
