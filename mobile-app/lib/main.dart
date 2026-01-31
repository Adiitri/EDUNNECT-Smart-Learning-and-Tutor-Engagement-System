import 'package:flutter/material.dart';
import 'presentation/common/splash_screen.dart';

void main() {
  runApp(const EdunnectApp());
}

class EdunnectApp extends StatelessWidget {
  const EdunnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edunnect',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      // This tells the app to start with the Splash Screen
      home: const SplashScreen(),
    );
  }
}
