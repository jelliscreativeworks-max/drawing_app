import 'package:drawing_app/config/provider.dart';
import 'package:drawing_app/router/routes.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
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

        return ChangeNotifierProvider<DrawScreenViewModel>(
          // 🟢 FIXED: Move the bootstrap initialization directly into the ViewModel's creation lifecycle block.
          // This guarantees it executes exactly ONCE when entering the screen, and NEVER runs on a Hot Reload.
          create: (context) {
            final vm = DrawScreenViewModel(
              layerDataRepository: context.read(), 
              canvasDataRepository: context.read(),
            );
            
            // Execute the initial data load safely exactly once
            if (projectId == 'new') {
              vm.initProject.execute();
            } else {
              vm.loadProject.execute(projectId);
            }
            return vm;
          },
          child: Consumer<DrawScreenViewModel>(
            builder: (context, viewModel, child) {
              // 🟢 FIXED: Listen to the initProject command state declaratively inside your view tree builder.
              // If a new project successfully resolves its true UUID, redirect smoothly without breaking memory tracks.
              if (projectId == 'new' && 
                  viewModel.currentCanvas != null && 
                  viewModel.currentCanvas!.id != 'temp' &&
                  !viewModel.initProject.running) {
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Use pushReplacementName or go without rebuilding the active view model context state
                  context.go('/canvas/${viewModel.currentCanvas!.id}');
                });
              }

              return DrawScreen(viewModel: viewModel);
            },
          ),
        );
      },
    ),
  ],
);
