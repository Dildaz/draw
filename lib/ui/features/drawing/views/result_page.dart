import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../domain/models/draw_models.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../domain/models/player_profile.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/ad_banner_slot.dart';
import '../../../core/widgets/avatar_badge.dart';
import '../../../core/widgets/cozy_button.dart';
import 'draw_page.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.lesson,
    required this.record,
    required this.mode,
    this.partner,
  });

  final LessonDetail lesson;
  final ArtworkRecord record;
  final DrawMode mode;
  final BuddyInfo? partner;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    // Request native iOS SKStoreReviewController at a natural positive milestone
    // (never review-gated, never incentivized, capped by cooldown + Apple's OS limit).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      final app = AppStateScope.of(context);
      await app.reviewService.maybeRequestReviewAfterMilestone(
        totalCompletedDrawings: app.profile.artworks.length,
      );
    });
  }

  String _praiseKey(int stars) {
    if (stars >= 5) return 'Perfect!';
    if (stars == 4) return 'Amazing!';
    if (stars == 3) return 'Great Work!';
    return 'Nice Start!';
  }

  Future<void> _goHome() async {
    if (_navigating) return;
    _navigating = true;
    final app = AppStateScope.of(context);
    await app.adService.maybeShowInterstitialAfterDrawing();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _drawAgain() async {
    if (_navigating) return;
    _navigating = true;
    final app = AppStateScope.of(context);
    await app.adService.maybeShowInterstitialAfterDrawing();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DrawPage(
          lesson: widget.lesson,
          mode: widget.mode,
          partner: widget.partner,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final record = widget.record;
    final pngBytes = record.pngBase64 != null ? base64Decode(record.pngBase64!) : null;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _goHome,
                          icon: const Icon(Icons.home_rounded, size: 28, color: AppColors.ink),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            app.t(_praiseKey(record.stars)),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.amberDark,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final filled = i < record.stars;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            filled ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 38,
                            color: filled ? AppColors.amber : AppColors.cardBorder,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (record.isTwoPlayer && widget.partner != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AvatarBadge(avatarIndex: app.profile.avatarIndex, size: 36),
                          const SizedBox(width: 6),
                          AvatarBadge(avatarIndex: widget.partner!.avatarIndex, size: 36, frameIndex: 2),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              app.t('You drew {0} together', [record.lessonTitle]),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        record.lessonTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppColors.amber, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: pngBytes != null
                                  ? Image.memory(pngBytes, fit: BoxFit.contain)
                                  : Image.asset(widget.lesson.summary.previewAsset, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      app.t('Saved to your gallery'),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CozyButton(
                            label: app.t('Draw again'),
                            color: AppColors.sky,
                            shadowColor: AppColors.skyDark,
                            onPressed: _drawAgain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CozyButton(
                            label: app.t('Home'),
                            color: AppColors.coral,
                            shadowColor: AppColors.coralDark,
                            onPressed: _goHome,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const AdBannerSlot(),
          ],
        ),
      ),
    );
  }
}
