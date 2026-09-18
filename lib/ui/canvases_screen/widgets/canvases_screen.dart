import 'package:drawing_app/router/routes.dart';
import 'package:drawing_app/ui/canvases_screen/view_models/canvases_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key, required CanvasesScreenViewModel projectScreenViewModel}) : _projectScreenViewModel = projectScreenViewModel;

  final CanvasesScreenViewModel _projectScreenViewModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _projectScreenViewModel.loadCanvasesList,
          _projectScreenViewModel.createNewCanvas
        ]),
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

      //TODO: Modal should popup when pressed to enter name and canvas size 
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: () => _projectScreenViewModel.createNewCanvas..execute('cool name ${_projectScreenViewModel.canvasDataList.length}', Size(2000.0, 4000.0))),
    );
  }
}