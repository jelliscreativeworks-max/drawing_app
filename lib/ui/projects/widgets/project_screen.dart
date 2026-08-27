import 'package:drawing_app/router/routes.dart';
import 'package:drawing_app/ui/projects/view_models/project_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key, required ProjectScreenViewModel projectScreenViewModel}) : _projectScreenViewModel = projectScreenViewModel;

  final ProjectScreenViewModel _projectScreenViewModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _projectScreenViewModel.loadProjectList, 
        builder: (context, child) {
        return ListView.builder(
          itemCount: _projectScreenViewModel.canvasDataList.length,
          itemBuilder: (context, index){
            return ListTile(
              title: Text(_projectScreenViewModel.canvasDataList[index].name),
              onTap: () => context.go(Routes.canvasFromId(_projectScreenViewModel.canvasDataList[index].id)),
            );
        },);
      }
      ),
    );
  }
}