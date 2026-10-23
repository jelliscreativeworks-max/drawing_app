// import 'package:drawing_app/domain/models/draw_layer/draw_layer.dart';
// import 'package:drawing_app/painter_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';


// class MenuEntry{

//   final Widget child;
//   final VoidCallback? onPressed;
//   final List<MenuEntry>? children;

//   const MenuEntry({
//     required this.child,
//     this.onPressed,
//     this.children
//   });


//   static List<Widget> build(
//     List<MenuEntry> selections, [
//     Duration hoverOpenDelay = .zero,
//   ]) {
//     Widget buildSelection(MenuEntry selection) {
//       if (selection.children != null) {
//         return SubmenuButton(
//           menuChildren: MenuEntry.build(
//             selection.children!,
//             const Duration(milliseconds: 150),
//           ),
//           child: selection.child,
//         );
//       }
//       return MenuItemButton(
//         onPressed: selection.onPressed,
//         child: selection.child,
//       );
//     }

//     return selections.map<Widget>(buildSelection).toList();
//   }

// }


// class IconButtonMenuBar extends StatelessWidget {
//   const IconButtonMenuBar({super.key});

  
//   @override
//   Widget build(BuildContext context) {

//     return Row(
//           mainAxisSize: .min,
//           children: <Widget>[
            
//             Expanded(child: MenuBar(children: MenuEntry.build(_getMenus(context)))),
//           ],
//         );
//   }
// }
  
//   List<MenuEntry> _getMenus(BuildContext context){
//     context.select<PainterController?, List<DrawLayer>>((controller) => controller?.paintLayers);
//     final List<MenuEntry> entries = <MenuEntry>[
//       MenuEntry(
//         child: Icon(Icons.layers), 
//         children: context.read<PainterController>().paintLayers.map((layer) => 
//               MenuEntry(
                
//                 onPressed: () => {},
//                 child: Text(layer.name))).toList())];

//     return entries;
//   }
