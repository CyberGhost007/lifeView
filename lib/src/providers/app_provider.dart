import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';

class AppProvider with ChangeNotifier {
  static AppProvider of({bool listen = false}) => Provider.of<AppProvider>(
        Constants.navigatorKey.currentContext!,
        listen: listen,
      );
}
