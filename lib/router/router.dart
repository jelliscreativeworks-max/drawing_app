import 'package:drawing_app/config/provider.dart';
import 'package:drawing_app/router/routes.dart';
import 'package:drawing_app/ui/draw_page/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/projects/widgets.dart';
import 'package:drawing_app/ui/screens/draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    // HomeScreen Route
    GoRoute(
      path: Routes.home, 
      builder: (context, state) => const ProjectScreen()
    ),

    GoRoute(
  path: '/draw/:projectId',
  builder: (context, state) {
    final projectId = state.pathParameters['projectId']!;

    return ChangeNotifierProvider<DrawScreenViewModel>(
      create: (context) => DrawScreenViewModel(layerDataRepository: context.read(), canvasDataRepository: context.read()),
      child: Builder(
        builder: (innerContext) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final viewModel = innerContext.read<DrawScreenViewModel>();
            
            if (projectId == 'new') {
              // 1. Initialize the new project layout structure
              await viewModel.initProject.execute();

              // 2. If successful, update the router path seamlessly in place
              if (!viewModel.initProject.error && innerContext.mounted) {
                innerContext.go('/draw/${viewModel.currentCanvas!.id}');
              }
            } else {
              viewModel.loadProject.execute(projectId);
            }
          });

          return DrawScreen(viewModel: context.read());
        },
      ),
    );
  },
),

  ]);