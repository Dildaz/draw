import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../domain/models/draw_models.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../domain/models/player_profile.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/avatar_badge.dart';
import '../../../core/widgets/cozy_button.dart';
import 'draw_page.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key, required this.lesson});

  final LessonDetail lesson;

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  BuddyInfo? _found;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _findBuddy();
  }

  Future<void> _findBuddy() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final app = AppStateScope.of(context);
    final pool = app.buddies;
    final chosen = pool[Random().nextInt(pool.length)];
    setState(() => _found = chosen);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DrawPage(
          lesson: widget.lesson,
          mode: DrawMode.quickMatch,
          partner: chosen,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: Text(app.t('Quick buddy'))),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_found == null) ...[
                  RotationTransition(
                    turns: Tween(begin: -0.04, end: 0.04).animate(
                      CurvedAnimation(parent: _spin, curve: Curves.easeInOut),
                    ),
                    child: Image.asset('assets/images/mascots/mascot_search.png', height: 160),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    app.t('Finding a buddy...'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lesson.summary.titleFor(app.language),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AvatarBadge(avatarIndex: app.profile.avatarIndex, size: 78),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(Icons.favorite_rounded, color: AppColors.coral, size: 32),
                      ),
                      AvatarBadge(avatarIndex: _found!.avatarIndex, size: 78, frameIndex: 2),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    app.t('Buddy found!'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.green),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_found!.name} ${app.t(" (bot)")}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
                const SizedBox(height: 36),
                if (_found == null)
                  CozyButton(
                    label: app.t('Cancel'),
                    color: const Color(0xFFD5C8BE),
                    textColor: AppColors.ink,
                    expanded: false,
                    height: 46,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
