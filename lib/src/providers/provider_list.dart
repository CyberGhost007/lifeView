// Package imports:
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'face_detector_provider.dart';

class ProviderList {
  static List<SingleChildWidget> getProviders() {
    return <SingleChildWidget>[
      ChangeNotifierProvider.value(value: FaceDetectorProvider()),
    ];
  }
}
