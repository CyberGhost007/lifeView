import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app/app.dart';
import 'src/providers/provider_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: ProviderList.getProviders(),
      child: const App(),
    ),
  );
}
