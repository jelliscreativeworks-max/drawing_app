
import 'dart:async';

import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class ToolStrokeSizePreview extends StatefulWidget {
  const ToolStrokeSizePreview({
    super.key, 
    bool alwaysActive = true, 
    int autoCloseTimer = 2
  }) : _alwaysActive = alwaysActive, _autoCloseTimer = autoCloseTimer;

  final bool _alwaysActive;
  final int _autoCloseTimer;

  @override
  State<ToolStrokeSizePreview> createState() => _ToolStrokeSizePreviewState();
}

class _ToolStrokeSizePreviewState extends State<ToolStrokeSizePreview> {
  bool _active = false;
  Timer? _timer;
  ValueNotifier<double>? _currentNotifier;

  @override
  void initState() {
    super.initState();
    _active = widget._alwaysActive;
  }

  void _onStrokeSizeChanged() {
    if (widget._alwaysActive) return;

    _timer?.cancel();

    if (!_active && mounted) {
      setState(() {
        _active = true;
      });
    }

    _timer = Timer(Duration(seconds: widget._autoCloseTimer), () {
      if (mounted) {
        setState(() {
          _active = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _currentNotifier?.removeListener(_onStrokeSizeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strokeSizeNotifier = context.select<ToolController, ValueNotifier<double>?>(
      (controller) => controller.getNotifierForProperty<double>(const StrokeSizeId()),
    );

    if (strokeSizeNotifier == null) {
      return const SizedBox.shrink();
    }

    if (_currentNotifier != strokeSizeNotifier) {
      _currentNotifier?.removeListener(_onStrokeSizeChanged);
      _currentNotifier = strokeSizeNotifier;
      _currentNotifier?.addListener(_onStrokeSizeChanged);
    }

    final isVisible = _active || widget._alwaysActive;


    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      opacity: isVisible ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), 
        curve: Curves.easeOutCubic,
        width: isVisible ? 62 : 0,
        height: isVisible ? 62 : 0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromARGB(181, 255, 255, 255),
          boxShadow: isVisible ? [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
          ] : null,
        ),
        child: ClipRect(
          child: OverflowBox(
            minWidth: 62,
            maxWidth: 62,
            minHeight: 62,
            maxHeight: 62,
            child: ValueListenableBuilder<double>(
              valueListenable: strokeSizeNotifier,
              builder: (context, currentSize, child) {
                return Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    CustomPaint(
                    size: const Size(50, 50),
                    painter: _StrokeDotPainter(
                      radius: (currentSize / 2).clamp(1.0, 22.5),
                    ),
                  ),
                  Align(
                    alignment: AlignmentGeometry.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(style: Theme.of(context).textTheme.labelSmall,(currentSize).toStringAsFixed(0)),
                    ))
                ]
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}


class _StrokeDotPainter extends CustomPainter {
  final double radius;
  const _StrokeDotPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
      
    
    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokeDotPainter oldDelegate) => 
      oldDelegate.radius != radius;
}
