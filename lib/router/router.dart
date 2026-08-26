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
  path: '/canvas/:projectId',
  builder: (context, state) {
    final projectId = state.pathParameters['projectId']!;

    return ChangeNotifierProvider<DrawScreenViewModel>(
      // 1. Inject the data layer repositories down into the ViewModel constructor cleanly
      create: (context) => DrawScreenViewModel(
        layerDataRepository: context.read(), 
        canvasDataRepository: context.read(),
      ),
      child: Builder(
        builder: (innerContext) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final viewModel = innerContext.read<DrawScreenViewModel>();
            
            // FIX 1: Add execution guard rails to ensure bootstrap actions never run twice on frame shifts
            if (viewModel.loadProject.running || viewModel.initProject.running) return;
            
            // Check if the current canvas data instance already matches the loaded data state
            if (viewModel.currentCanvas != null && viewModel.currentCanvas!.id == projectId) return;
            print(projectId);
            if (projectId == 'new') {
              // 2. Initialize the project file structure models asynchronously
              await viewModel.initProject.execute();
              // 3. FIX 2: Replace path parameters cleanly *without* rebuilding or re-mounting the view tree
              if (!viewModel.initProject.error && innerContext.mounted) {
                // Using go() forces a hard reset. Using state updates keeps your ViewModel context perfectly preserved.
                GoRouter.of(innerContext).go('/canvas/${viewModel.currentCanvas!.id}');
              }
            } else {
              // Trigger project loading sequentially using your Command architecture pattern
              viewModel.loadProject.execute(projectId);
            }
          });

          // FIX 3: Read from 'innerContext' so the view safely extracts the injected ViewModel instance
          return DrawScreen(viewModel: innerContext.read<DrawScreenViewModel>());
        },
      ),
    );
  },
),


  ]);