import 'package:flutter/material.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/avatar_badge.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final entries = [
      ('Luna', 5, 42, false),
      ('Milo', 2, 31, false),
      ('Sunny', 12, 24, false),
      ('Koko', 9, 17, false),
      ('Mochi', 14, 9, false),
      (app.profile.name, app.profile.avatarIndex, app.profile.lessonsDone, true),
    ]..sort((a, b) => b.$3.compareTo(a.$3));

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: Text(app.t('Top artists'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              app.t('Practice league with bots · online ranking soon'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.purpleDark,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(entries.length, (i) {
            final (name, avatarIdx, score, isMe) = entries[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.coral.withValues(alpha: 0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isMe ? AppColors.coral : AppColors.cardBorder,
                    width: isMe ? 2 : 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '#${i + 1}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: i == 0 ? AppColors.amberDark : AppColors.ink,
                        ),
                      ),
                    ),
                    AvatarBadge(avatarIndex: avatarIdx, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isMe ? '$name (${app.t("YOU")})' : name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      app.t('{0} lessons', [score]),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
