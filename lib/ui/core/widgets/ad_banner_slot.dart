import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../data/services/ad_service.dart';
import '../app_state.dart';
import '../app_theme.dart';

/// Policy-compliant adaptive AdMob banner container.
///
/// - Renders with clear separation and hairline border to prevent accidental clicks.
/// - Never placed on the active drawing canvas.
/// - Gracefully collapses to zero height on web/desktop or when no ad is available.
class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({super.key});

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  bool _startedLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_startedLoading) {
      _startedLoading = true;
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    final app = AppStateScope.of(context);
    final adService = app.adService;
    if (!adService.isMobilePlatform || !adService.canRequestAds) return;

    final width = MediaQuery.of(context).size.width.truncate();
    if (width <= 0) return;

    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;

    final banner = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: size,
      request: adService.buildAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
        },
      ),
    );
    await banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.bgCream,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      padding: const EdgeInsets.only(top: 4),
      alignment: Alignment.center,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
