import 'package:flutter/material.dart';

import 'game_screen.dart';

void main() {
  runApp(const SixteenApp());
}

class SixteenApp extends StatelessWidget {
  const SixteenApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SixteenApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}