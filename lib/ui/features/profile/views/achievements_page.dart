import 'package:flutter/material.dart';
import '../../../../domain/models/player_profile.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: Text(app.t('Achievements'))),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: kAchievements.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final def = kAchievements[i];
          final prog = app.achievementProgress(def);
          final unlocked = prog >= def.target;
          final pct = (prog / def.target).clamp(0.0, 1.0);
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: unlocked ? AppColors.amber : AppColors.cardBorder,
                width: unlocked ? 2 : 1.4,
              ),
            ),
            child: Row(
              children: [
                Opacity(
                  opacity: unlocked ? 1.0 : 0.4,
                  child: Image.asset(def.badgeAsset, width: 54, height: 54),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.t(def.titleKey),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        app.t(def.descKey),
                        style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 7,
                                backgroundColor: AppColors.cardBorder,
                                valueColor: AlwaysStoppedAnimation(
                                  unlocked ? AppColors.green : AppColors.coral,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${prog.clamp(0, def.target)}/${def.target}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
