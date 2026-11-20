import 'package:flutter/material.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/services/ad_service.dart';
import '../../data/services/review_service.dart';
import '../../domain/models/lesson.dart';
import '../../domain/models/player_profile.dart';

class AppController extends ChangeNotifier {
  AppController({
    required AppRepository repository,
    AdService? adService,
    ReviewService? reviewService,
  })  : _repo = repository,
        adService = adService ?? AdService(),
        reviewService = reviewService ?? ReviewService();

  final AppRepository _repo;
  final AdService adService;
  final ReviewService reviewService;

  bool _initialized = false;
  bool get initialized => _initialized;

  PlayerProfile _profile = const PlayerProfile();
  PlayerProfile get profile => _profile;

  List<LessonSummary> _lessons = const [];
  List<LessonSummary> get lessons => _lessons;

  List<BuddyInfo> _buddies = const [];
  List<BuddyInfo> get buddies => _buddies;

  AppRepository get repo => _repo;
  String t(String key, [List<Object>? args]) => _repo.t(key, args);
  String get language => _repo.language;

  Future<void> init() async {
    if (_initialized) return;
    _profile = await _repo.loadProfile();
    await _repo.setLanguage(_profile.language);
    _lessons = await _repo.loadLessons();
    _buddies = List<BuddyInfo>.from(_repo.getDefaultBuddies());
    _initialized = true;
    notifyListeners();
    if (_profile.onboardingDone) {
      // Initialize ads/UMP/ATT after knowing the user's age group
      adService.initialize(ageGroup: _profile.ageGroup).then((_) {
        notifyListeners();
      });
    }
  }

  Future<void> setLanguage(String code) async {
    await _repo.setLanguage(code);
    _profile = _profile.copyWith(language: code);
    await _repo.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> updateProfile(PlayerProfile updated) async {
    _profile = updated;
    await _repo.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    required int avatarIndex,
    required String ageGroup,
    required String purpose,
    required List<String> interests,
  }) async {
    _profile = _profile.copyWith(
      onboardingDone: true,
      name: name.trim().isEmpty ? 'Artist' : name.trim(),
      avatarIndex: avatarIndex,
      ageGroup: ageGroup,
      purpose: purpose,
      interests: interests,
      unlockedFrames: const [0, 1],
    );
    await _repo.saveProfile(_profile);
    notifyListeners();
    adService.initialize(ageGroup: _profile.ageGroup).then((_) {
      notifyListeners();
    });
  }

  Future<void> recordCompletedArtwork(ArtworkRecord record) async {
    final completed = List<String>.from(_profile.completedLessonIds);
    if (!completed.contains(record.lessonId)) {
      completed.add(record.lessonId);
    }
    final artworks = [record, ..._profile.artworks];
    final frames = List<int>.from(_profile.unlockedFrames);
    if (completed.length >= 2 && !frames.contains(2)) frames.add(2);
    if (completed.length >= 5 && !frames.contains(3)) frames.add(3);
    if (completed.length >= 10 && !frames.contains(4)) frames.add(4);

    _profile = _profile.copyWith(
      completedLessonIds: completed,
      artworks: artworks.take(60).toList(),
      totalDrawingSeconds: _profile.totalDrawingSeconds + record.durationSeconds,
      bestStreak: _profile.streakDays > _profile.bestStreak
          ? _profile.streakDays
          : _profile.bestStreak,
      unlockedFrames: frames,
    );
    await _repo.saveProfile(_profile);
    notifyListeners();
  }

  int achievementProgress(AchievementDef def) {
    switch (def.id) {
      case 'first_stroke':
      case 'art_lover':
      case 'master_painter':
        return _profile.completedLessonIds.length;
      case 'better_together':
        return _profile.artworks.where((a) => a.isTwoPlayer).length;
      case 'on_fire':
      case 'unstoppable':
        return _profile.bestStreak;
      case 'explorer':
        final doneSet = _profile.completedLessonIds.toSet();
        final cats = _lessons
            .where((l) => doneSet.contains(l.id))
            .map((l) => l.category)
            .toSet();
        return cats.length;
      case 'neon_artist':
        final doneSet = _profile.completedLessonIds.toSet();
        return _lessons
            .where((l) => l.category == 'neon' && doneSet.contains(l.id))
            .length;
      case 'perfect':
        return _profile.artworks.where((a) => a.stars >= 5).length;
      default:
        return 0;
    }
  }

  void addBuddyByCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean.length != 6 || clean == _profile.friendCode) return;
    if (_buddies.any((b) => b.friendCode == clean)) return;
    final idx = clean.codeUnits.fold<int>(0, (a, b) => a + b) % 16;
    _buddies = [
      BuddyInfo(
        id: 'friend_$clean',
        name: 'Buddy $clean',
        avatarIndex: idx,
        friendCode: clean,
        isOnline: true,
        isBot: false,
      ),
      ..._buddies,
    ];
    notifyListeners();
  }

  void removeBuddy(String id) {
    _buddies = _buddies.where((b) => b.id != id).toList();
    notifyListeners();
  }

  Future<void> resetAll() async {
    await _repo.resetProfile();
    _profile = await _repo.loadProfile();
    await _repo.setLanguage(_profile.language);
    notifyListeners();
  }

  @override
  void dispose() {
    adService.dispose();
    super.dispose();
  }
}

class AppStateScope extends InheritedNotifier<AppController> {
  const AppStateScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }
}
