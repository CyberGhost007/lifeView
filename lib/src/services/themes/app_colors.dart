import 'package:flutter/material.dart';

import '../../models/theme_model.dart';

class AppColors {
  static const Color appButtonPrimaryColor = Color(0xff007AFF);
  static const Color mainAppBlue = Color(0xff534CCF);

  static const List<Color> appButtonMainGradientColor = [
    Color(0xff5400C6),
    mainAppBlue,
  ];

  static List<ThemeModel> themes = [
    ThemeModel(
      gradient: [const Color(0xff045DE9), const Color(0xff09C6F9)],
      solidColor: const Color(0xff1A8BF0),
      name: 'Ocean',
    ),
  ];
}
