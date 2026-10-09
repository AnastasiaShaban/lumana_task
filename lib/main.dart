import 'package:flutter/material.dart';
import 'package:lumana_task/core/injection_container.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDi();

  runApp(const MyApp());
}
