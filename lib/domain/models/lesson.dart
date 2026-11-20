import 'package:flutter/material.dart';

class LessonSummary {
  const LessonSummary({
    required this.id,
    required this.titles,
    required this.category,
    required this.players,
    required this.size,
    required this.stepCount,
  });

  final String id;
  final Map<String, String> titles;
  final String category;
  final int players;
  final int size;
  final int stepCount;

  bool get isTwoPlayer => players >= 2;
  bool get isNeon => category == 'neon';

  String titleFor(String lang) => titles[lang] ?? titles['en'] ?? id;
  String get previewAsset => 'assets/lessons/$id/preview.png';

  factory LessonSummary.fromJson(Map<String, dynamic> json) {
    final rawTitle = (json['title'] as Map<String, dynamic>? ?? {});
    return LessonSummary(
      id: json['id'] as String,
      titles: rawTitle.map((k, v) => MapEntry(k, v.toString())),
      category: (json['category'] as String?) ?? 'nature',
      players: (json['players'] as num?)?.toInt() ?? 1,
      size: (json['size'] as num?)?.toInt() ?? 768,
      stepCount: (json['stepCount'] as num?)?.toInt() ?? 6,
    );
  }
}

class LessonStep {
  const LessonStep({
    required this.mask,
    required this.colorHex,
    required this.type,
    required this.brush,
    required this.lane,
  });

  final String mask;
  final String colorHex;
  final String type; // 'stroke' or 'fill'
  final double brush; // normalized 0..1 relative to canvas size
  final int lane; // 0 = player 1, 1 = player 2

  bool get isFill => type == 'fill';

  Color get color {
    final cleaned = colorHex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return const Color(0xFF202020);
    if (cleaned.length == 6) return Color(0xFF000000 | value);
    return Color(value);
  }

  factory LessonStep.fromJson(Map<String, dynamic> json) {
    return LessonStep(
      mask: (json['mask'] as String?) ?? 'step_01',
      colorHex: (json['color'] as String?) ?? '#202020',
      type: (json['type'] as String?) ?? 'stroke',
      brush: (json['brush'] as num?)?.toDouble() ?? 0.025,
      lane: (json['lane'] as num?)?.toInt() ?? 0,
    );
  }
}

class LessonDetail {
  const LessonDetail({
    required this.summary,
    required this.steps,
  });

  final LessonSummary summary;
  final List<LessonStep> steps;

  String maskAsset(LessonStep step) => 'assets/lessons/${summary.id}/${step.mask}.png';

  List<Color> get uniqueColors {
    final seen = <int>{};
    final out = <Color>[];
    for (final s in steps) {
      final c = s.color;
      if (seen.add(c.toARGB32())) {
        out.add(c);
      }
    }
    return out;
  }

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    final stepsRaw = (json['steps'] as List<dynamic>? ?? []);
    final steps = stepsRaw
        .map((e) => LessonStep.fromJson(e as Map<String, dynamic>))
        .toList();
    final summary = LessonSummary.fromJson({
      ...json,
      'stepCount': steps.length,
    });
    return LessonDetail(summary: summary, steps: steps);
  }
}

class CategoryInfo {
  const CategoryInfo({
    required this.id,
    required this.labelKey,
    required this.iconAsset,
    required this.accentColor,
  });

  final String id;
  final String labelKey;
  final String iconAsset;
  final Color accentColor;
}

const List<CategoryInfo> kLessonCategories = [
  CategoryInfo(id: 'all', labelKey: 'Popular', iconAsset: 'assets/images/categories/sunflower.png', accentColor: Color(0xFFF05D5E)),
  CategoryInfo(id: 'animal', labelKey: 'Animal', iconAsset: 'assets/images/categories/paw.png', accentColor: Color(0xFFFF9F43)),
  CategoryInfo(id: 'food', labelKey: 'Food', iconAsset: 'assets/images/categories/donut.png', accentColor: Color(0xFFFF6B9D)),
  CategoryInfo(id: 'nature', labelKey: 'Nature', iconAsset: 'assets/images/categories/sunflower.png', accentColor: Color(0xFF4BB543)),
  CategoryInfo(id: 'sea', labelKey: 'Sea', iconAsset: 'assets/images/categories/water_wave.png', accentColor: Color(0xFF2E9AFE)),
  CategoryInfo(id: 'vehicle', labelKey: 'Vehicle', iconAsset: 'assets/images/categories/car.png', accentColor: Color(0xFF54A0FF)),
  CategoryInfo(id: 'hellokitty', labelKey: 'Hello Kitty', iconAsset: 'assets/images/categories/hellokitty_head.png', accentColor: Color(0xFFFF7EB3)),
  CategoryInfo(id: 'kuromi', labelKey: 'Kuromi', iconAsset: 'assets/images/categories/kuromi_head.png', accentColor: Color(0xFF7B5BF2)),
  CategoryInfo(id: 'mymelody', labelKey: 'My Melody', iconAsset: 'assets/images/categories/mymelody_head.png', accentColor: Color(0xFFFF85A2)),
  CategoryInfo(id: 'labubu', labelKey: 'Labubu', iconAsset: 'assets/images/categories/labubu_head.png', accentColor: Color(0xFFA569BD)),
  CategoryInfo(id: 'hero', labelKey: 'Hero', iconAsset: 'assets/images/categories/bolt.png', accentColor: Color(0xFFFFB703)),
  CategoryInfo(id: 'space', labelKey: 'Space', iconAsset: 'assets/images/categories/rocket.png', accentColor: Color(0xFF4C6EF5)),
  CategoryInfo(id: 'neon', labelKey: 'Neon', iconAsset: 'assets/images/categories/neon_heart.png', accentColor: Color(0xFFE040FB)),
  CategoryInfo(id: 'fantasy', labelKey: 'Fantasy', iconAsset: 'assets/images/categories/unicorn.png', accentColor: Color(0xFF9B5DE5)),
];
