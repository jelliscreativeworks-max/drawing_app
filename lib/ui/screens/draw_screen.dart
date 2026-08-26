import 'package:drawing_app/ui/draw_page/view_models/draw_screen_view_model.dart';
import 'package:flutter/material.dart';

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key, required DrawScreenViewModel viewModel}) : _viewModel = viewModel;

  final DrawScreenViewModel _viewModel;

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

