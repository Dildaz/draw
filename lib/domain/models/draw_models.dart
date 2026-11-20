import 'package:flutter/material.dart';

enum BrushTool {
  brush,
  neon,
  fill,
  eraser,
}

enum DrawMode {
  solo,
  buddyBot,
  quickMatch,
  privateRoom,
}

class DrawStroke {
  DrawStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.tool,
    required this.stepIndex,
    required this.isPartner,
  });

  final List<Offset> points; // normalized 0..1 coordinates
  final Color color;
  final double strokeWidth; // normalized 0..1 relative to canvas width
  final BrushTool tool;
  final int stepIndex;
  final bool isPartner;
}

class QuickReaction {
  const QuickReaction({
    required this.id,
    required this.emoji,
    required this.label,
    required this.fromPartner,
    required this.timestamp,
  });

  final String id;
  final String emoji;
  final String label;
  final bool fromPartner;
  final DateTime timestamp;
}
