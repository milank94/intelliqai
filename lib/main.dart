import 'package:atomsbox/atomsbox.dart';
import 'package:flutter/material.dart';

import 'chrome_popup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntelliQAi',
      theme: AppTheme.theme,
      home: const ChromePopup(),
    );
  }
}
