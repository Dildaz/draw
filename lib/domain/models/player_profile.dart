import 'dart:convert';
import 'package:flutter/material.dart';

class ArtworkRecord {
  const ArtworkRecord({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    required this.stars,
    required this.timestampMs,
    required this.isTwoPlayer,
    this.partnerName,
    this.partnerAvatarIndex,
    this.pngBase64,
    this.durationSeconds = 45,
  });

  final String id;
  final String lessonId;
  final String lessonTitle;
  final int stars;
  final int timestampMs;
  final bool isTwoPlayer;
  final String? partnerName;
  final int? partnerAvatarIndex;
  final String? pngBase64;
  final int durationSeconds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'lessonTitle': lessonTitle,
        'stars': stars,
        'timestampMs': timestampMs,
        'isTwoPlayer': isTwoPlayer,
        'partnerName': partnerName,
        'partnerAvatarIndex': partnerAvatarIndex,
        'pngBase64': pngBase64,
        'durationSeconds': durationSeconds,
      };

  factory ArtworkRecord.fromJson(Map<String, dynamic> json) => ArtworkRecord(
        id: json['id'] as String,
        lessonId: json['lessonId'] as String,
        lessonTitle: (json['lessonTitle'] as String?) ?? '',
        stars: (json['stars'] as num?)?.toInt() ?? 5,
        timestampMs: (json['timestampMs'] as num?)?.toInt() ?? 0,
        isTwoPlayer: (json['isTwoPlayer'] as bool?) ?? false,
        partnerName: json['partnerName'] as String?,
        partnerAvatarIndex: (json['partnerAvatarIndex'] as num?)?.toInt(),
        pngBase64: json['pngBase64'] as String?,
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 45,
      );
}

class BuddyInfo {
  const BuddyInfo({
    required this.id,
    required this.name,
    required this.avatarIndex,
    required this.friendCode,
    required this.isOnline,
    this.isBot = true,
    this.lastActiveMinutes = 0,
    this.drawingsTogether = 0,
  });

  final String id;
  final String name;
  final int avatarIndex;
  final String friendCode;
  final bool isOnline;
  final bool isBot;
  final int lastActiveMinutes;
  final int drawingsTogether;

  String get avatarAsset =>
      'assets/images/avatars/avatar_${avatarIndex.clamp(0, 15).toString().padLeft(2, '0')}.png';
}

class LevelDef {
  const LevelDef({
    required this.level,
    required this.titleKey,
    required this.requiredLessons,
    required this.accentColor,
  });

  final int level;
  final String titleKey;
  final int requiredLessons;
  final Color accentColor;
}

const List<LevelDef> kArtistLevels = [
  LevelDef(level: 1, titleKey: 'Beginner', requiredLessons: 0, accentColor: Color(0xFF6BCB77)),
  LevelDef(level: 2, titleKey: 'Novice', requiredLessons: 1, accentColor: Color(0xFF4D96FF)),
  LevelDef(level: 3, titleKey: 'Budding', requiredLessons: 3, accentColor: Color(0xFF9B5DE5)),
  LevelDef(level: 4, titleKey: 'Apprentice', requiredLessons: 6, accentColor: Color(0xFFFF9F43)),
  LevelDef(level: 5, titleKey: 'Emerging', requiredLessons: 10, accentColor: Color(0xFFF05D5E)),
  LevelDef(level: 6, titleKey: 'Developing', requiredLessons: 15, accentColor: Color(0xFF00BBF9)),
  LevelDef(level: 7, titleKey: 'Skilled', requiredLessons: 22, accentColor: Color(0xFFFF6B9D)),
  LevelDef(level: 8, titleKey: 'Proficient', requiredLessons: 30, accentColor: Color(0xFFF15BB5)),
  LevelDef(level: 9, titleKey: 'Accomplished', requiredLessons: 42, accentColor: Color(0xFFFFB703)),
  LevelDef(level: 10, titleKey: 'Expert', requiredLessons: 55, accentColor: Color(0xFF7B5BF2)),
  LevelDef(level: 11, titleKey: 'Virtuoso', requiredLessons: 75, accentColor: Color(0xFFFF595E)),
  LevelDef(level: 12, titleKey: 'Master', requiredLessons: 95, accentColor: Color(0xFFFFCA3A)),
  LevelDef(level: 13, titleKey: 'Legendary', requiredLessons: 111, accentColor: Color(0xFFE040FB)),
];

class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.badgeAsset,
    required this.target,
  });

  final String id;
  final String titleKey;
  final String descKey;
  final String badgeAsset;
  final int target;
}

const List<AchievementDef> kAchievements = [
  AchievementDef(
    id: 'first_stroke',
    titleKey: 'First Stroke',
    descKey: 'Finish your first drawing',
    badgeAsset: 'assets/images/badges/first_stroke.png',
    target: 1,
  ),
  AchievementDef(
    id: 'art_lover',
    titleKey: 'Art Lover',
    descKey: 'Finish 10 drawings',
    badgeAsset: 'assets/images/badges/art_lover.png',
    target: 10,
  ),
  AchievementDef(
    id: 'master_painter',
    titleKey: 'Master Painter',
    descKey: 'Finish 50 drawings',
    badgeAsset: 'assets/images/badges/master_painter.png',
    target: 50,
  ),
  AchievementDef(
    id: 'better_together',
    titleKey: 'Better Together',
    descKey: 'Finish a drawing with a real player',
    badgeAsset: 'assets/images/badges/better_together.png',
    target: 1,
  ),
  AchievementDef(
    id: 'on_fire',
    titleKey: 'On Fire',
    descKey: 'Keep a 7-day streak',
    badgeAsset: 'assets/images/badges/on_fire.png',
    target: 7,
  ),
  AchievementDef(
    id: 'unstoppable',
    titleKey: 'Unstoppable',
    descKey: 'Keep a 30-day streak',
    badgeAsset: 'assets/images/badges/unstoppable.png',
    target: 30,
  ),
  AchievementDef(
    id: 'explorer',
    titleKey: 'Explorer',
    descKey: 'Draw one picture from every topic',
    badgeAsset: 'assets/images/badges/explorer.png',
    target: 13,
  ),
  AchievementDef(
    id: 'neon_artist',
    titleKey: 'Neon Artist',
    descKey: 'Draw every neon picture',
    badgeAsset: 'assets/images/badges/neon_artist.png',
    target: 8,
  ),
  AchievementDef(
    id: 'perfect',
    titleKey: 'Perfect Drawing',
    descKey: 'Get 5 stars on a drawing',
    badgeAsset: 'assets/images/badges/perfect.png',
    target: 1,
  ),
];

class PlayerProfile {
  const PlayerProfile({
    this.onboardingDone = false,
    this.language = 'en',
    this.name = 'Artist',
    this.avatarIndex = 0,
    this.frameIndex = 0,
    this.ageGroup = '',
    this.purpose = '',
    this.interests = const [],
    this.friendCode = 'DRW429',
    this.streakDays = 1,
    this.bestStreak = 1,
    this.streakGoal = 3,
    this.freezesLeft = 3,
    this.totalDrawingSeconds = 0,
    this.soundEnabled = true,
    this.vibrateEnabled = true,
    this.notificationsEnabled = true,
    this.completedLessonIds = const [],
    this.artworks = const [],
    this.unlockedFrames = const [0, 1],
  });

  final bool onboardingDone;
  final String language;
  final String name;
  final int avatarIndex;
  final int frameIndex;
  final String ageGroup;
  final String purpose;
  final List<String> interests;
  final String friendCode;
  final int streakDays;
  final int bestStreak;
  final int streakGoal;
  final int freezesLeft;
  final int totalDrawingSeconds;
  final bool soundEnabled;
  final bool vibrateEnabled;
  final bool notificationsEnabled;
  final List<String> completedLessonIds;
  final List<ArtworkRecord> artworks;
  final List<int> unlockedFrames;

  String get avatarAsset =>
      'assets/images/avatars/avatar_${avatarIndex.clamp(0, 15).toString().padLeft(2, '0')}.png';

  int get lessonsDone => completedLessonIds.length;

  LevelDef get currentLevel {
    LevelDef cur = kArtistLevels.first;
    for (final lv in kArtistLevels) {
      if (lessonsDone >= lv.requiredLessons) {
        cur = lv;
      }
    }
    return cur;
  }

  LevelDef? get nextLevel {
    final idx = kArtistLevels.indexOf(currentLevel);
    if (idx < 0 || idx + 1 >= kArtistLevels.length) return null;
    return kArtistLevels[idx + 1];
  }

  PlayerProfile copyWith({
    bool? onboardingDone,
    String? language,
    String? name,
    int? avatarIndex,
    int? frameIndex,
    String? ageGroup,
    String? purpose,
    List<String>? interests,
    String? friendCode,
    int? streakDays,
    int? bestStreak,
    int? streakGoal,
    int? freezesLeft,
    int? totalDrawingSeconds,
    bool? soundEnabled,
    bool? vibrateEnabled,
    bool? notificationsEnabled,
    List<String>? completedLessonIds,
    List<ArtworkRecord>? artworks,
    List<int>? unlockedFrames,
  }) {
    return PlayerProfile(
      onboardingDone: onboardingDone ?? this.onboardingDone,
      language: language ?? this.language,
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      frameIndex: frameIndex ?? this.frameIndex,
      ageGroup: ageGroup ?? this.ageGroup,
      purpose: purpose ?? this.purpose,
      interests: interests ?? this.interests,
      friendCode: friendCode ?? this.friendCode,
      streakDays: streakDays ?? this.streakDays,
      bestStreak: bestStreak ?? this.bestStreak,
      streakGoal: streakGoal ?? this.streakGoal,
      freezesLeft: freezesLeft ?? this.freezesLeft,
      totalDrawingSeconds: totalDrawingSeconds ?? this.totalDrawingSeconds,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrateEnabled: vibrateEnabled ?? this.vibrateEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      artworks: artworks ?? this.artworks,
      unlockedFrames: unlockedFrames ?? this.unlockedFrames,
    );
  }

  Map<String, dynamic> toJson() => {
        'onboardingDone': onboardingDone,
        'language': language,
        'name': name,
        'avatarIndex': avatarIndex,
        'frameIndex': frameIndex,
        'ageGroup': ageGroup,
        'purpose': purpose,
        'interests': interests,
        'friendCode': friendCode,
        'streakDays': streakDays,
        'bestStreak': bestStreak,
        'streakGoal': streakGoal,
        'freezesLeft': freezesLeft,
        'totalDrawingSeconds': totalDrawingSeconds,
        'soundEnabled': soundEnabled,
        'vibrateEnabled': vibrateEnabled,
        'notificationsEnabled': notificationsEnabled,
        'completedLessonIds': completedLessonIds,
        'artworks': artworks.map((a) => a.toJson()).toList(),
        'unlockedFrames': unlockedFrames,
      };

  String toJsonString() => jsonEncode(toJson());

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      onboardingDone: (json['onboardingDone'] as bool?) ?? false,
      language: (json['language'] as String?) ?? 'en',
      name: (json['name'] as String?) ?? 'Artist',
      avatarIndex: (json['avatarIndex'] as num?)?.toInt() ?? 0,
      frameIndex: (json['frameIndex'] as num?)?.toInt() ?? 0,
      ageGroup: (json['ageGroup'] as String?) ?? '',
      purpose: (json['purpose'] as String?) ?? '',
      interests: (json['interests'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      friendCode: (json['friendCode'] as String?) ?? 'DRW429',
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 1,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 1,
      streakGoal: (json['streakGoal'] as num?)?.toInt() ?? 3,
      freezesLeft: (json['freezesLeft'] as num?)?.toInt() ?? 3,
      totalDrawingSeconds: (json['totalDrawingSeconds'] as num?)?.toInt() ?? 0,
      soundEnabled: (json['soundEnabled'] as bool?) ?? true,
      vibrateEnabled: (json['vibrateEnabled'] as bool?) ?? true,
      notificationsEnabled: (json['notificationsEnabled'] as bool?) ?? true,
      completedLessonIds: (json['completedLessonIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      artworks: (json['artworks'] as List<dynamic>? ?? [])
          .map((e) => ArtworkRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      unlockedFrames: (json['unlockedFrames'] as List<dynamic>? ?? [0, 1])
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }
}
