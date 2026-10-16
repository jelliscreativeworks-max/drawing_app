
import 'package:drawing_app/router/routes.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/canvases_screen/view_models/canvases_screen_view_model.dart';
import 'package:drawing_app/ui/canvases_screen/widgets/canvases_screen.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_properties_controller.dart';
import 'package:drawing_app/ui/draw_screen/widgets/draw_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
GoRouter router() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home, 
      builder: (context, state) {
        final viewModel = CanvasesScreenViewModel(
          canvasDataRepository: context.read(),
          layerDataRepository: context.read()
        );
        return ChangeNotifierProvider<CanvasesScreenViewModel>.value(
          value: viewModel,
          child: ProjectScreen(projectScreenViewModel: viewModel),
        );
      },
    ),

  GoRoute(
  path: '/canvas/:projectId',
  builder: (context, state) {
    final projectId = state.pathParameters['projectId']!;

    return 
        ChangeNotifierProvider<DrawScreenViewModel>(
          create: (context) {
            final vm = DrawScreenViewModel(
              layerDataRepository: context.read(), 
              canvasDataRepository: context.read(),
              logger: context.read<Logger>()
            );
            
            vm.loadProject.execute(projectId);
            
            return vm;
          },
        
      child: Consumer<DrawScreenViewModel>(
        builder: (context, viewModel, child) {

          // 3. Extract the initialized Tool Controller from the active provider block
          final toolController = viewModel.toolController;
          final toolPropertiesController = ToolPropertiesController(toolController: toolController);

          // 4. Safe Execution: DrawScreen is built ONLY when currentCanvas is 100% ready.
          return DrawScreen(
            viewModel: viewModel,
            toolController: toolController,
            toolPropertiesController: toolPropertiesController,
          );
        },
      ),
    );
  },
),

  ],
);