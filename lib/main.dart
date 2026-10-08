import 'package:flutter/material.dart';
import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/core/injection_container.dart';
import 'package:lumana_task/features/search/presentation/search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDi();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dummy Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const SearchScreen(),
    );
  }
}
