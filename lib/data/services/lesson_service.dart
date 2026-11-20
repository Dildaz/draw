import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/lesson.dart';

class LessonService {
  List<LessonSummary>? _cachedIndex;
  final Map<String, LessonDetail> _detailCache = {};

  Future<List<LessonSummary>> loadAllSummaries() async {
    if (_cachedIndex != null) return _cachedIndex!;
    final raw = await rootBundle.loadString('assets/lessons/index.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    _cachedIndex = decoded
        .map((e) => LessonSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cachedIndex!;
  }

  Future<LessonDetail> loadDetail(String lessonId) async {
    final existing = _detailCache[lessonId];
    if (existing != null) return existing;
    final raw = await rootBundle.loadString('assets/lessons/$lessonId/lesson.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final detail = LessonDetail.fromJson(decoded);
    _detailCache[lessonId] = detail;
    return detail;
  }
}
