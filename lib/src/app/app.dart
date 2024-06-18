import 'package:ami/src/widgets/face_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pages/home_page.dart';
import '../utils/constants.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    return MaterialApp(
      title: 'Ami',
      navigatorKey: Constants.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
