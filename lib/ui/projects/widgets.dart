import 'package:drawing_app/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(child: Center(child: FilledButton.icon(onPressed: () => context.go(Routes.canvasNew), label: Text('Create New')),),);
  }
}