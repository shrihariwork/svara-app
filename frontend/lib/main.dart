import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/calibration_screen.dart';

void main() {
  runApp(const ProviderScope(child: SvaraApp()));
}

class SvaraApp extends StatelessWidget {
  const SvaraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Svara',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const CalibrationScreen(),
    );
  }
}
