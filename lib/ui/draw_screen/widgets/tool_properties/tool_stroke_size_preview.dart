
import 'package:flutter/material.dart';

class ToolStrokeSizePreview extends StatefulWidget {
  const ToolStrokeSizePreview({super.key}); 

  // final ToolPropertiesController _toolPropertiesController;

  @override
  State<ToolStrokeSizePreview> createState() => _ToolStrokeSizePreviewState();
}

class _ToolStrokeSizePreviewState extends State<ToolStrokeSizePreview> {
  @override
  Widget build(BuildContext context) {
    return Placeholder();}
  //   if(widget._toolPropertiesController.){

  //    return Container(
  //         width: 50,
  //         height: 50,
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           shape: BoxShape.circle,
  //           boxShadow: [
  //             BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
  //           ],
  //         ),
  //         child: AnimatedContainer(
  //           duration: const Duration(milliseconds: 30),
  //           width: widget._strokeProperty.value.clamp(1.0, 45.0),
  //           height: value.clamp(1.0, 45.0),
  //           decoration: BoxDecoration(
  //             color: Colors.black,
  //             shape: BoxShape.circle,
  //           ),
  //         ),
  //       );
  //       }else{
  //         return SizedBox.shrink();
  //       }
  // }
}
