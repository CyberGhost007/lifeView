import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../widgets/chart_widget.dart';

class HeartBeatPage extends StatefulWidget {
  const HeartBeatPage({super.key});

  @override
  HeartBeatPageView createState() {
    return HeartBeatPageView();
  }
}

class HeartBeatPageView extends State<HeartBeatPage>
    with SingleTickerProviderStateMixin {
  bool _toggled = false; // toggle button value
  final List<SensorValue> _data = []; // array to store the values
  late CameraController _controller;
  final double _alpha = 0.3; // factor for the mean value
  late AnimationController _animationController;
  double _iconScale = 1;
  int _bpm = 0;
  final int _fs = 30; // sampling frequency (fps)
  final int _windowLen = 30 * 6; // window length to display - 6 seconds
  CameraImage? _image; // store the last camera image
  late double _avg; // store the average value during calculation
  late DateTime _now; // store the now Datetime
  late Timer _timer; // timer for image processing
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);

  List<Color> bgColors = [
    const Color(0xff1A2235),
    const Color(0xff0D0F1E),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animationController.addListener(() {
      setState(() {
        _iconScale = 1.0 + _animationController.value * 0.4;
      });
    });
  }

  Color getHeartRateColor(int heartRate) {
    if (heartRate < 100) {
      return Colors.green;
    } else if (heartRate >= 100 && heartRate < 160) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String getHeartRateStatus(int heartRate) {
    if (heartRate < 100) {
      return "Heart rate is low. You are in a relaxed state.";
    } else if (heartRate >= 100 && heartRate < 160) {
      return "Heart rate is elevated. You are in a moderate activity zone.";
    } else {
      return "Heart rate is high. You are in a high activity zone.";
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _toggled = false;
    _disposeController();
    WakelockPlus.disable();
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: 100,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
                child: ChartWidget(_data),
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: DashedCircularProgressBar.aspectRatio(
                    aspectRatio: 1, // width ÷ height
                    valueNotifier: _valueNotifier,
                    progress: _bpm.toDouble(),
                    maxProgress: 200,
                    startAngle: 225,
                    sweepAngle: 270,
                    foregroundColor: getHeartRateColor(_bpm),
                    backgroundColor: const Color(0xffeeeeee),
                    foregroundStrokeWidth: 15,
                    backgroundStrokeWidth: 15,
                    animation: true,
                    seekSize: 6,
                    seekColor: const Color(0xffeeeeee),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Transform.scale(
                              scale: _iconScale,
                              child: IconButton(
                                icon: Icon(
                                    _toggled ? Icons.favorite : Icons.favorite),
                                color: Colors.red,
                                iconSize: 30,
                                onPressed: () {},
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  (_bpm > 30 && _bpm < 200
                                      ? _bpm.toString()
                                      : "--"),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "BPM",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_bpm > 30)
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    getHeartRateStatus(_bpm),
                    style: TextStyle(
                      color: getHeartRateColor(_bpm),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                const Padding(padding: EdgeInsets.all(18.0)),
              const Spacer(),
              SizedBox(
                width: MediaQuery.of(context).size.width * .6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(18),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (_toggled) {
                              _untoggle();
                            } else {
                              _toggle();
                            }
                          },
                          child: Stack(
                            fit: StackFit.loose,
                            alignment: Alignment.center,
                            children: <Widget>[
                              _toggled
                                  ? SizedBox(
                                      width: 100,
                                      height: 90,
                                      child: ClipPath(
                                        clipper: HeartClipper(),
                                        child: AspectRatio(
                                          aspectRatio:
                                              _controller.value.aspectRatio,
                                          child: CameraPreview(_controller),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: 100,
                                      height: 90,
                                      child: Center(
                                        child: ClipPath(
                                          clipper: HeartClipper(),
                                          child: Container(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * .8,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  _toggled
                      ? "Cover both the camera and the flash with your finger"
                      : "Tap the heart to start measuring your heart rate",
                  style: TextStyle(
                    color: _toggled ? Colors.white : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _clearData() {
    // create array of 128 ~= 255/2
    _data.clear();
    int now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < _windowLen; i++) {
      _data.insert(
        0,
        SensorValue(
            DateTime.fromMillisecondsSinceEpoch(now - i * 1000 ~/ _fs), 128),
      );
    }
  }

  void _toggle() {
    _clearData();
    _initController().then((onValue) {
      WakelockPlus.enable();
      _animationController.repeat(reverse: true);
      setState(() {
        _toggled = true;
      });
      // after is toggled
      _initTimer();
      _updateBPM();
    });
  }

  void _untoggle() async {
    await _disposeController();
    WakelockPlus.disable();
    _animationController.stop();
    _animationController.value = 0.0;
    setState(() {
      _toggled = false;
    });
  }

  Future<void> _disposeController() async {
    await _controller.setFlashMode(FlashMode.off);
    _controller.dispose();
  }

  Future<void> _initController() async {
    try {
      List<CameraDescription> cameras = await availableCameras();
      _controller = CameraController(cameras.first, ResolutionPreset.low);
      if (!_controller.value.isInitialized) {
        await _controller.initialize();
      }
      await _controller.setFlashMode(FlashMode.torch);
      _controller.startImageStream((CameraImage image) {
        _image = image;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _initTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 1000 ~/ _fs), (timer) {
      if (_toggled) {
        if (_image != null) _scanImage(_image!);
      } else {
        timer.cancel();
      }
    });
  }

  void _scanImage(CameraImage image) {
    _now = DateTime.now();
    _avg =
        image.planes.first.bytes.reduce((value, element) => value + element) /
            image.planes.first.bytes.length;
    if (_data.length >= _windowLen) {
      _data.removeAt(0);
    }
    setState(() {
      _data.add(SensorValue(_now, 255 - _avg));
    });
  }

  void _updateBPM() async {
    List<SensorValue> values;
    double avg;
    int n;
    double m;
    double threshold;
    double bpm;
    int counter;
    int previous;
    while (_toggled) {
      values = List.from(_data); // create a copy of the current data array
      avg = 0;
      n = values.length;
      m = 0;
      for (var value in values) {
        avg += value.value / n;
        if (value.value > m) m = value.value;
      }
      threshold = (m + avg) / 2;
      bpm = 0;
      counter = 0;
      previous = 0;
      for (int i = 1; i < n; i++) {
        if (values[i - 1].value < threshold && values[i].value > threshold) {
          if (previous != 0) {
            counter++;
            bpm +=
                60 * 1000 / (values[i].time.millisecondsSinceEpoch - previous);
          }
          previous = values[i].time.millisecondsSinceEpoch;
        }
      }
      if (counter > 0) {
        bpm = bpm / counter;
        setState(() {
          _bpm = ((1 - _alpha) * _bpm + _alpha * bpm).toInt();
          _valueNotifier.value = _bpm.toDouble();
        });
      }
      await Future.delayed(Duration(
          milliseconds:
              1000 * _windowLen ~/ _fs)); // wait for a new set of _data values
    }
  }
}

class HeartShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height / 4)
      ..cubicTo(5 * size.width / 14, 0, 0, size.height / 4, size.width / 2,
          size.height)
      ..moveTo(size.width / 2, size.height / 4)
      ..cubicTo(9 * size.width / 14, 0, size.width, size.height / 4,
          size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final path = Path();

    path.moveTo(width / 2, height / 4);
    path.cubicTo(
      width * 3 / 4,
      0,
      width,
      height / 2.5,
      width / 2,
      height * 3 / 4,
    );
    path.cubicTo(
      0,
      height / 2.5,
      width / 4,
      0,
      width / 2,
      height / 4,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
