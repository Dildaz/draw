import 'package:flutter/material.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final p = app.profile;
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIdx = DateTime.now().weekday - 1;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: Text(app.t('Streak'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.coral, Color(0xFFFF8E53)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 62, color: Colors.white),
                const SizedBox(height: 6),
                Text(
                  '${p.streakDays}',
                  style: const TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  app.t('Day streak'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  app.t('Your best: {0}', [p.bestStreak]),
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.t('Week'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final active = i == todayIdx;
                    return Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active ? AppColors.coral : AppColors.bgCream,
                            shape: BoxShape.circle,
                          ),
                          child: active
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                              : Text(days[i], style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 4),
                        Text(days[i], style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.ac_unit_rounded, color: AppColors.sky, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p.freezesLeft} ${app.t("freezes left")}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${app.t('Your streak goal')}: ${p.streakGoal} ${app.t("days drawing")}',
                        style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
