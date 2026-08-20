import 'package:drawing_app/paint_screen.dart';
import 'package:drawing_app/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {

  runApp(MultiProvider(providers: providersLocal, child: const MainApp(),));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});


  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: PaintScreen()
    );
  }
}


