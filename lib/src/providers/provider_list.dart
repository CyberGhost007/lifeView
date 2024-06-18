// Package imports:

import 'package:ami/src/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ProviderList {
  static List<SingleChildWidget> getProviders() {
    return <SingleChildWidget>[
      ChangeNotifierProvider.value(value: AppProvider()),
    ];
  }
}
