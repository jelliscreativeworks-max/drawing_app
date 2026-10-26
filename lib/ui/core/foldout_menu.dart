import 'package:flutter/material.dart';

class FoldoutMenu extends StatefulWidget {
  const FoldoutMenu({super.key});

  @override
  State<FoldoutMenu> createState() => _FoldoutMenuState();
}

class _FoldoutMenuState extends State<FoldoutMenu> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        IconButton(
        onPressed: () => setState(() {
          _isOpen = !_isOpen;
        }),
        icon: Icon(Icons.arrow_back_ios_new_rounded),
      ),
        IconButton(onPressed: (){}, icon: Icon(Icons.abc))
      ],),
    
    );
  }
}
