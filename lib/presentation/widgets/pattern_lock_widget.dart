import 'package:flutter/material.dart';

/// Custom pattern lock widget for drawing unlock patterns
class PatternLockWidget extends StatefulWidget {
  final Function(List<int>) onPatternComplete;
  final int gridSize;
  final Color dotColor;
  final Color selectedDotColor;
  final Color lineColor;
  final double dotSize;
  final bool enabled;

  const PatternLockWidget({
    super.key,
    required this.onPatternComplete,
    this.gridSize = 3,
    this.dotColor = Colors.grey,
    this.selectedDotColor = Colors.blue,
    this.lineColor = Colors.blue,
    this.dotSize = 20.0,
    this.enabled = true,
  });

  @override
  State<PatternLockWidget> createState() => _PatternLockWidgetState();
}

class _PatternLockWidgetState extends State<PatternLockWidget> {
  final List<int> _pattern = [];
  final List<Offset> _dotPositions = [];
  Offset? _currentDragPosition;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateDotPositions();
    });
  }

  void _calculateDotPositions() {
    if (!mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final cellWidth = size.width / widget.gridSize;
    final cellHeight = size.height / widget.gridSize;

    _dotPositions.clear();
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        final x = (j + 0.5) * cellWidth;
        final y = (i + 0.5) * cellHeight;
        _dotPositions.add(Offset(x, y));
      }
    }
    setState(() {});
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled) return;

    setState(() {
      _isDragging = true;
      _pattern.clear();
      _currentDragPosition = details.localPosition;
      _checkDotHit(details.localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || !_isDragging) return;

    setState(() {
      _currentDragPosition = details.localPosition;
      _checkDotHit(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled || !_isDragging) return;

    setState(() {
      _isDragging = false;
      _currentDragPosition = null;
    });

    if (_pattern.isNotEmpty) {
      widget.onPatternComplete(_pattern);
    }
  }

  void _checkDotHit(Offset position) {
    for (int i = 0; i < _dotPositions.length; i++) {
      final distance = (position - _dotPositions[i]).distance;
      if (distance <= widget.dotSize && !_pattern.contains(i)) {
        _pattern.add(i);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_dotPositions.isEmpty) {
          Future.microtask(() => _calculateDotPositions());
        }

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _PatternPainter(
              dotPositions: _dotPositions,
              pattern: _pattern,
              currentDragPosition: _currentDragPosition,
              dotColor: widget.dotColor,
              selectedDotColor: widget.selectedDotColor,
              lineColor: widget.lineColor,
              dotSize: widget.dotSize,
            ),
          ),
        );
      },
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<Offset> dotPositions;
  final List<int> pattern;
  final Offset? currentDragPosition;
  final Color dotColor;
  final Color selectedDotColor;
  final Color lineColor;
  final double dotSize;

  _PatternPainter({
    required this.dotPositions,
    required this.pattern,
    this.currentDragPosition,
    required this.dotColor,
    required this.selectedDotColor,
    required this.lineColor,
    required this.dotSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw lines connecting selected dots
    if (pattern.length > 1) {
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < pattern.length - 1; i++) {
        final start = dotPositions[pattern[i]];
        final end = dotPositions[pattern[i + 1]];
        canvas.drawLine(start, end, linePaint);
      }

      // Draw line from last dot to current drag position
      if (currentDragPosition != null && pattern.isNotEmpty) {
        final lastDot = dotPositions[pattern.last];
        canvas.drawLine(lastDot, currentDragPosition!, linePaint);
      }
    }

    // Draw dots
    for (int i = 0; i < dotPositions.length; i++) {
      final isSelected = pattern.contains(i);
      final paint = Paint()
        ..color = isSelected ? selectedDotColor : dotColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(dotPositions[i], dotSize, paint);

      // Draw outer ring for selected dots
      if (isSelected) {
        final ringPaint = Paint()
          ..color = selectedDotColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(dotPositions[i], dotSize + 5, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.currentDragPosition != currentDragPosition;
  }
}

/// Helper class to convert pattern to string
class PatternHelper {
  static String patternToString(List<int> pattern) {
    return pattern.join(',');
  }

  static List<int> stringToPattern(String patternString) {
    return patternString.split(',').map((e) => int.parse(e)).toList();
  }
}
