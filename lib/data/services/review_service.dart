import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// iOS App Store & Google Play policy-compliant rating service.
///
/// Respects Apple App Store Review Guidelines (1.1.7 / 5.6.1) & HIG:
/// - Uses Apple's native SKStoreReviewController directly via `requestReview()`.
/// - NEVER gates the native prompt behind a custom star-filter ("review gating").
/// - NEVER incentivizes ratings with rewards or unlocks.
/// - Prompts only at natural positive milestones (e.g., after completing the 2nd drawing)
///   with a 30-day cooldown (Apple also caps prompts at 3 per 365 days).
/// - User-initiated "Rate us" button in Settings uses `openStoreListing()` directly.
class ReviewService {
  static const String iosAppStoreId = '6837367468';

  static const String _lastPromptMsKey = 'review_last_prompt_ms';
  static const int _minCompletedDrawings = 2;
  static const Duration _cooldown = Duration(days: 30);

  final InAppReview _inAppReview = InAppReview.instance;

  bool get _isSupportedMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Requests the native OS review dialog if the user has reached a natural
  /// positive milestone and the cooldown has elapsed.
  Future<void> maybeRequestReviewAfterMilestone({
    required int totalCompletedDrawings,
  }) async {
    if (!_isSupportedMobile) return;
    if (totalCompletedDrawings < _minCompletedDrawings) return;

    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_lastPromptMsKey) ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (lastMs > 0 && (nowMs - lastMs) < _cooldown.inMilliseconds) {
      return;
    }

    try {
      if (await _inAppReview.isAvailable()) {
        await prefs.setInt(_lastPromptMsKey, nowMs);
        await _inAppReview.requestReview();
      }
    } catch (_) {
      // Silently ignore on unsupported environments or simulators
    }
  }

  /// Opens the App Store / Play Store listing directly when the user taps
  /// "Rate us" in Settings (recommended by Apple HIG instead of requestReview).
  Future<bool> openStoreListing() async {
    if (!_isSupportedMobile) return false;
    try {
      await _inAppReview.openStoreListing(appStoreId: iosAppStoreId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
