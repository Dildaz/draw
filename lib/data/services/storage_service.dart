import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/player_profile.dart';

class StorageService {
  static const _profileKey = 'draw_together_profile_v1';

  Future<PlayerProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return PlayerProfile(friendCode: _generateFriendCode());
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PlayerProfile.fromJson(map);
    } catch (_) {
      return PlayerProfile(friendCode: _generateFriendCode());
    }
  }

  Future<void> saveProfile(PlayerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, profile.toJsonString());
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  String _generateFriendCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
