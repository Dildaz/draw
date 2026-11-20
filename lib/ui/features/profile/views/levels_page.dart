import 'package:flutter/material.dart';
import '../../../../domain/models/player_profile.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';

class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final done = app.profile.lessonsDone;
    final cur = app.profile.currentLevel;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: Text(app.t('Your levels'))),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: kArtistLevels.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final lv = kArtistLevels[i];
          final reached = done >= lv.requiredLessons;
          final isCurrent = lv.level == cur.level;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrent ? lv.accentColor.withValues(alpha: 0.14) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrent ? lv.accentColor : AppColors.cardBorder,
                width: isCurrent ? 2.2 : 1.4,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: reached ? lv.accentColor : AppColors.cardBorder,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${lv.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.t(lv.titleKey),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        app.t('{0} lessons', [lv.requiredLessons]),
                        style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
                Icon(
                  reached ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                  color: reached ? AppColors.green : AppColors.inkMuted,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
