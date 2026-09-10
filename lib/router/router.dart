import 'package:drawing_app/config/provider.dart';
import 'package:drawing_app/router/routes.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/ui/projects/view_models/project_screen_view_model.dart';
import 'package:drawing_app/ui/projects/widgets/project_screen.dart';
import 'package:drawing_app/ui/draw_screen/widgets/draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
GoRouter router() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home, 
      builder: (context, state) {
        final viewModel = ProjectScreenViewModel(
          canvasDataRepository: context.read(),
        );
        return ChangeNotifierProvider<ProjectScreenViewModel>.value(
          value: viewModel,
          child: ProjectScreen(projectScreenViewModel: viewModel),
        );
      },
    ),

   GoRoute(
      path: '/canvas/:projectId',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;

        // 1. We wrap everything inside a MultiProvider block to instantiate
        // and manage the lifecycles of both specialized View Models cleanly.
        return MultiProvider(
          providers: [
            // Step A: Instantiate the primary Canvas Data engine first
            ChangeNotifierProvider<DrawScreenViewModel>(
              create: (context) {
                final vm = DrawScreenViewModel(
                  layerDataRepository: context.read(), 
                  canvasDataRepository: context.read(),
                );
                
                // Execute the initial data load safely exactly once down the timeline
                if (projectId == 'new') {
                  vm.initProject.execute();
                } else {
                  vm.loadProject.execute(projectId);
                }
                return vm;
              },
            ),

            // Step B: Instantiate your interaction Tool configuration coordinator second.
            // Using context.read<DrawScreenViewModel>() extracts the sibling dependency 
            // instance safely right as it becomes active in the provider memory space!
            ChangeNotifierProvider<ToolController>(
              create: (context) => ToolController(
                viewModel: context.read<DrawScreenViewModel>(),
              ),
            ),
          ],
          child: Consumer<DrawScreenViewModel>(
            builder: (context, viewModel, child) {
              // 2. Continuous Project Identifier Redirection Guard
              if (projectId == 'new' && 
                  viewModel.currentCanvas != null && 
                  viewModel.currentCanvas!.id != 'temp' &&
                  !viewModel.initProject.running) {
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go('/canvas/${viewModel.currentCanvas!.id}');
                });
              }

              // 3. Extract the initialized Tool Controller from the active provider block
              final toolController = context.read<ToolController>();

              // 4. Pass both finalized controller dependencies directly down the 
              // constructor pipeline of your explicit, package-free DrawScreen widget view!
              return DrawScreen(
                viewModel: viewModel,
                toolController: toolController,
              );
            },
          ),
        );
      },
    ),
  ],
);