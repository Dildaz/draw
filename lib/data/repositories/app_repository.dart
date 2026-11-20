import '../../domain/models/lesson.dart';
import '../../domain/models/player_profile.dart';
import '../services/lesson_service.dart';
import '../services/loc_service.dart';
import '../services/storage_service.dart';

class AppRepository {
  AppRepository({
    required this._locService,
    required this._lessonService,
    required this._storageService,
  });

  final LocService _locService;
  final LessonService _lessonService;
  final StorageService _storageService;

  String t(String key, [List<Object>? args]) => _locService.t(key, args);
  String get language => _locService.language;

  Future<void> setLanguage(String code) => _locService.setLanguage(code);

  Future<PlayerProfile> loadProfile() => _storageService.loadProfile();
  Future<void> saveProfile(PlayerProfile profile) => _storageService.saveProfile(profile);
  Future<void> resetProfile() => _storageService.clearProfile();

  Future<List<LessonSummary>> loadLessons() => _lessonService.loadAllSummaries();
  Future<LessonDetail> loadLessonDetail(String id) => _lessonService.loadDetail(id);

  List<BuddyInfo> getDefaultBuddies() => const [
        BuddyInfo(
          id: 'bot_milo',
          name: 'Milo',
          avatarIndex: 2,
          friendCode: 'MILO88',
          isOnline: true,
          isBot: true,
          lastActiveMinutes: 0,
          drawingsTogether: 3,
        ),
        BuddyInfo(
          id: 'bot_luna',
          name: 'Luna',
          avatarIndex: 5,
          friendCode: 'LUNA42',
          isOnline: true,
          isBot: true,
          lastActiveMinutes: 0,
          drawingsTogether: 5,
        ),
        BuddyInfo(
          id: 'bot_koko',
          name: 'Koko',
          avatarIndex: 9,
          friendCode: 'KOKO17',
          isOnline: false,
          isBot: true,
          lastActiveMinutes: 14,
          drawingsTogether: 1,
        ),
        BuddyInfo(
          id: 'bot_sunny',
          name: 'Sunny',
          avatarIndex: 12,
          friendCode: 'SUNY99',
          isOnline: true,
          isBot: true,
          lastActiveMinutes: 0,
          drawingsTogether: 2,
        ),
        BuddyInfo(
          id: 'bot_mochi',
          name: 'Mochi',
          avatarIndex: 14,
          friendCode: 'MOCH23',
          isOnline: false,
          isBot: true,
          lastActiveMinutes: 65,
          drawingsTogether: 0,
        ),
      ];
}
