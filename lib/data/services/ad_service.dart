import 'dart:async';
import 'dart:io' show Platform;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Replace the production ad unit IDs below with your real AdMob IDs
/// before submitting to the App Store / Google Play.
/// Debug builds ALWAYS use Google's official test ad unit IDs to protect
/// your AdMob account from invalid-traffic policy violations.
class AdConfig {
  static const String _iosTestBanner = 'ca-app-pub-3940256099942544/2435281174';
  static const String _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const String _androidTestBanner = 'ca-app-pub-3940256099942544/9214589741';
  static const String _androidTestInterstitial = 'ca-app-pub-3940256099942544/1033173712';

  // Production AdMob unit IDs (used automatically in release builds via kReleaseMode).
  static const String _iosProdBanner = 'ca-app-pub-6687779687898901/4890047670';
  static const String _iosProdInterstitial = 'ca-app-pub-6687779687898901/2263884339';
  static const String _androidProdBanner = _androidTestBanner;
  static const String _androidProdInterstitial = _androidTestInterstitial;

  static String get bannerUnitId {
    if (!kReleaseMode) {
      return Platform.isIOS ? _iosTestBanner : _androidTestBanner;
    }
    return Platform.isIOS ? _iosProdBanner : _androidProdBanner;
  }

  static String get interstitialUnitId {
    if (!kReleaseMode) {
      return Platform.isIOS ? _iosTestInterstitial : _androidTestInterstitial;
    }
    return Platform.isIOS ? _iosProdInterstitial : _androidProdInterstitial;
  }
}

/// Policy-compliant Google AdMob & UMP/ATT manager.
///
/// Respects:
/// - Apple App Tracking Transparency (ATT) — never requests tracking for children under 13.
/// - Google UMP Consent (GDPR/CCPA) — requests consent form before loading ads, and exposes
///   privacy options entry point in Settings.
/// - Age-appropriate ads (COPPA / Apple Kids / under-age consent) based on onboarding age.
/// - AdMob Interstitial frequency capping (min 2-minute cooldown & only every 3rd completed
///   drawing at a natural transition point; never on launch or mid-drawing).
class AdService {
  bool _initialized = false;
  bool _canRequestAds = false;
  bool _nonPersonalizedAds = true;
  bool _privacyOptionsRequired = false;

  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;
  DateTime? _lastInterstitialShownAt;
  int _completedDrawingsSinceAd = 0;

  static const int _drawingsBetweenInterstitials = 3;
  static const Duration _interstitialCooldown = Duration(minutes: 2);

  bool get isMobilePlatform => !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  bool get canRequestAds => _canRequestAds;
  bool get isPrivacyOptionsRequired => _privacyOptionsRequired;

  AdRequest buildAdRequest() => AdRequest(nonPersonalizedAds: _nonPersonalizedAds);

  /// Initializes UMP consent, iOS ATT (if age-appropriate), and MobileAds SDK.
  Future<void> initialize({required String ageGroup}) async {
    if (!isMobilePlatform || _initialized) return;

    final isChild = ageGroup == 'Under 12';
    final isTeen = ageGroup == '13 - 17';

    // 1. Gather Google UMP consent (GDPR/CCPA)
    await _gatherConsent(tagForUnderAgeOfConsent: isChild || isTeen);

    // 2. Request iOS App Tracking Transparency ONLY for non-children (Apple Kids policy)
    if (Platform.isIOS && !isChild) {
      try {
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          // Apple requires a brief delay after app becomes active before showing ATT
          await Future.delayed(const Duration(milliseconds: 500));
          final result = await AppTrackingTransparency.requestTrackingAuthorization();
          _nonPersonalizedAds = result != TrackingStatus.authorized;
        } else {
          _nonPersonalizedAds = status != TrackingStatus.authorized;
        }
      } catch (_) {
        _nonPersonalizedAds = true;
      }
    } else if (isChild) {
      _nonPersonalizedAds = true;
    }

    // 3. Configure age-appropriate AdMob RequestConfiguration before initializing
    final config = RequestConfiguration(
      ageRestrictedTreatment: isChild
          ? AgeRestrictedTreatment.child
          : (isTeen ? AgeRestrictedTreatment.teen : AgeRestrictedTreatment.unspecified),
      maxAdContentRating: isChild
          ? MaxAdContentRating.g
          : (isTeen ? MaxAdContentRating.pg : MaxAdContentRating.t),
    );
    await MobileAds.instance.updateRequestConfiguration(config);

    // 4. Initialize Google Mobile Ads SDK if consent allows
    if (_canRequestAds) {
      await MobileAds.instance.initialize();
      _initialized = true;
      _preloadInterstitial();
    }
  }

  Future<void> _gatherConsent({required bool tagForUnderAgeOfConsent}) async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters(
      tagForUnderAgeOfConsent: tagForUnderAgeOfConsent,
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        try {
          ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
            await _refreshConsentFlags();
            if (!completer.isCompleted) completer.complete();
          });
        } catch (_) {
          await _refreshConsentFlags();
          if (!completer.isCompleted) completer.complete();
        }
      },
      (error) async {
        // Fallback: check cached consent status
        await _refreshConsentFlags();
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () {
        _canRequestAds = true;
      },
    );
  }

  Future<void> _refreshConsentFlags() async {
    try {
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      final privacyStatus =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      _privacyOptionsRequired =
          privacyStatus == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      _canRequestAds = true;
      _privacyOptionsRequired = false;
    }
  }

  /// Opens the Google UMP privacy options form (required in Settings for GDPR users).
  Future<void> showPrivacyOptionsForm() async {
    if (!isMobilePlatform) return;
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((formError) async {
      await _refreshConsentFlags();
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }

  void _preloadInterstitial() {
    if (!isMobilePlatform || !_initialized || !_canRequestAds) return;
    if (_isLoadingInterstitial || _interstitialAd != null) return;
    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: buildAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _interstitialAd = ad;
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (_) {
          _isLoadingInterstitial = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Call at a natural transition AFTER completing a drawing (e.g., tapping Home
  /// or Draw Again on ResultPage). Never interrupts active drawing.
  Future<void> maybeShowInterstitialAfterDrawing() async {
    if (!isMobilePlatform || !_initialized || !_canRequestAds) return;

    _completedDrawingsSinceAd++;
    if (_completedDrawingsSinceAd < _drawingsBetweenInterstitials) {
      _preloadInterstitial();
      return;
    }

    final now = DateTime.now();
    if (_lastInterstitialShownAt != null &&
        now.difference(_lastInterstitialShownAt!) < _interstitialCooldown) {
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }

    final completer = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
    );

    _completedDrawingsSinceAd = 0;
    _lastInterstitialShownAt = now;
    _interstitialAd = null;
    await ad.show();
    await completer.future;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
