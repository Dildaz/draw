import 'package:flutter/material.dart';
import '../../../../domain/models/lesson.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/avatar_badge.dart';
import '../../../core/widgets/lesson_card.dart';
import '../../drawing/views/join_room_page.dart';
import '../../drawing/views/preview_page.dart';
import '../../profile/views/levels_page.dart';
import '../../profile/views/streak_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCat = 'all';

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final profile = app.profile;
    final twoPlayerLessons = app.lessons.where((l) => l.isTwoPlayer).toList();
    final filtered = _selectedCat == 'all'
        ? twoPlayerLessons
        : twoPlayerLessons.where((l) => l.category == _selectedCat).toList();
    final featured = twoPlayerLessons.isNotEmpty ? twoPlayerLessons.first : null;
    final doneSet = profile.completedLessonIds.toSet();

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                child: Row(
                  children: [
                    AvatarBadge(
                      avatarIndex: profile.avatarIndex,
                      frameIndex: profile.frameIndex,
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.t('Hi, {0}!', [profile.name]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                          Text(
                            app.t('Ready to draw today?'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    _statPill(
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.coral,
                      label: '${profile.streakDays}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StreakPage()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statPill(
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.amberDark,
                      label: 'Lv.${profile.currentLevel.level}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LevelsPage()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Banner + Join Room Card
            SliverToBoxAdapter(
              child: SizedBox(
                height: 158,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  children: [
                    if (featured != null)
                      _bannerCard(
                        bgAsset: 'assets/images/banners/banner_bg_0.png',
                        tag: app.t('FEATURED'),
                        title: featured.titleFor(app.language),
                        subtitle: app.t('Draw with a buddy'),
                        previewAsset: featured.previewAsset,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PreviewPage(summary: featured)),
                        ),
                      ),
                    const SizedBox(width: 12),
                    _bannerCard(
                      bgAsset: 'assets/images/banners/banner_bg_1.png',
                      tag: app.t('ROOM CODE'),
                      title: app.t('Join a room'),
                      subtitle: app.t('Type the room code'),
                      previewAsset: 'assets/images/mascots/ob_buddies.png',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const JoinRoomPage()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: kLessonCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = kLessonCategories[i];
                      final selected = _selectedCat == cat.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCat = cat.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? cat.accentColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? cat.accentColor : AppColors.cardBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(cat.iconAsset, width: 20, height: 20),
                              const SizedBox(width: 6),
                              Text(
                                app.t(cat.labelKey),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: selected ? Colors.white : AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // 2-Player Lessons Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.84,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final lesson = filtered[index];
                    return LessonCard(
                      lesson: lesson,
                      language: app.language,
                      isCompleted: doneSet.contains(lesson.id),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PreviewPage(summary: lesson)),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerCard({
    required String bgAsset,
    required String tag,
    required String title,
    required String subtitle,
    required String previewAsset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 286,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(image: AssetImage(bgAsset), fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(previewAsset, fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }
}
