import 'package:drawing_app/router/router.dart';
import 'package:drawing_app/config/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {

  runApp(MultiProvider(providers: providersLocal, child: const MainApp(),));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});


  @override
  Widget build(BuildContext context) {
    return  MaterialApp.router(
      routerConfig: router(),
    );
  }
}


