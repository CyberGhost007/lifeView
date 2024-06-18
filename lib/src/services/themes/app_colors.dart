import 'package:flutter/material.dart';

import '../../models/theme_model.dart';

class AppColors {
  static const Color appBackgroundColor = Color(0xFFFFFFFF);
  static const Color appButtonPrimaryColor = Color(0xff007AFF);
  static const Color appButtonMainColor = Color(0xff534CCF);
  static const Color secondryTextColor = Color(0xff6C757D);
  static const Color blackColor = Color(0xff000000);
  static const Color blackBlueColor = Color(0xff030026);
  static const Color borderColor = Color(0xffDEE2E6);
  static const Color lightPinkColor = Color(0xffFF9C8D);
  static const Color subtitleGrey = Color(0xff616161);
  static const Color mainAppBlue = Color(0xff534CCF);
  static const Color lightBorder = Color(0xffF5F5F5);
  static const Color lightBorder1 = Color(0xffECECEC);

  static const List<Color> appButtonMainGradientColor = [
    Color(0xff5400C6),
    mainAppBlue,
  ];

  static List<ThemeModel> themes = [
    ThemeModel(
      gradient: [const Color(0xff5400C6), const Color(0xffB031FF)],
      solidColor: const Color(0xff6208CF),
      name: 'Nighthawk',
    ),
    ThemeModel(
      gradient: [const Color(0xffF85032), const Color(0xffEE0979)],
      solidColor: const Color(0xffF22859),
      name: 'Firewatch',
    ),
    ThemeModel(
      gradient: [const Color(0xff000000), const Color(0xff3E3D3D)],
      solidColor: const Color(0xff000000),
      name: 'KnightOwl',
    ),
    ThemeModel(
      gradient: [const Color(0xff8a2be2), const Color(0xff9966cc)],
      solidColor: const Color(0xff8a2be2),
      name: 'Lilac',
    ),
    ThemeModel(
      gradient: [const Color(0xffEF1820), const Color(0xffF36303)],
      solidColor: const Color(0xffEF1820),
      name: 'Passion',
    ),
    ThemeModel(
      gradient: [const Color(0xff09203F), const Color(0xff537895)],
      solidColor: const Color(0xff1E3957),
      name: 'Timeless',
    ),
    ThemeModel(
      gradient: [const Color(0xff6B0F1A), const Color(0xffFF0084)],
      solidColor: const Color(0xffCC055F),
      name: 'RedWine',
    ),
    ThemeModel(
      gradient: [const Color(0xffFD6100), const Color(0xffED8F03)],
      solidColor: const Color(0xffF67702),
      name: 'Kyoto',
    ),
    ThemeModel(
      gradient: [const Color(0xff1A714A), const Color(0xff00C782)],
      solidColor: const Color(0xff239C69),
      name: 'Leaf',
    ),
    ThemeModel(
      gradient: [const Color(0xff045DE9), const Color(0xff09C6F9)],
      solidColor: const Color(0xff1A8BF0),
      name: 'Ocean',
    ),
  ];
}
