import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/avatar_badge.dart';
import 'achievements_page.dart';
import 'leaderboard_page.dart';
import 'levels_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _tab = 0; // 0: Artwork, 1: Frames

  void _editProfileDialog() {
    final app = AppStateScope.of(context);
    final nameCtrl = TextEditingController(text: app.profile.name);
    var avatarIdx = app.profile.avatarIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            18,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(app.t('Edit profile'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                maxLength: 18,
                decoration: InputDecoration(
                  hintText: app.t('Type your name'),
                  filled: true,
                  fillColor: AppColors.bgCream,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 16,
                  itemBuilder: (_, i) {
                    final sel = i == avatarIdx;
                    return GestureDetector(
                      onTap: () => setModalState(() => avatarIdx = i),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: sel ? AppColors.coral : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/avatars/avatar_${i.toString().padLeft(2, '0')}.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  app.updateProfile(
                    app.profile.copyWith(
                      name: nameCtrl.text.trim().isEmpty ? app.profile.name : nameCtrl.text.trim(),
                      avatarIndex: avatarIdx,
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: Text(app.t('Done'), style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final profile = app.profile;
    final mins = (profile.totalDrawingSeconds / 60).ceil();

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Row(
              children: [
                Text(
                  app.t('Me'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _editProfileDialog,
                  icon: const Icon(Icons.edit_rounded, color: AppColors.ink),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ),
                  icon: const Icon(Icons.settings_rounded, color: AppColors.ink),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Profile Hero Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
              ),
              child: Column(
                children: [
                  AvatarBadge(
                    avatarIndex: profile.avatarIndex,
                    frameIndex: profile.frameIndex,
                    size: 86,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    profile.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LevelsPage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: profile.currentLevel.accentColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${app.t("Level {0}", [profile.currentLevel.level])} · ${app.t(profile.currentLevel.titleKey)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: profile.currentLevel.accentColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _miniStat(
                          Icons.brush_rounded,
                          AppColors.coral,
                          '${profile.lessonsDone}',
                          app.t('Lessons done'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _miniStat(
                          Icons.timer_rounded,
                          AppColors.sky,
                          '${mins}m',
                          app.t('Time drawing'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _actionTile(
                    Icons.military_tech_rounded,
                    AppColors.amberDark,
                    app.t('Achievements'),
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AchievementsPage()),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionTile(
                    Icons.leaderboard_rounded,
                    AppColors.purple,
                    app.t('Top artists'),
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Segmented Tabs: Artwork vs Frames
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(child: _segBtn(0, app.t('Artwork'))),
                  Expanded(child: _segBtn(1, app.t('Frames'))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_tab == 0)
              _buildArtworkGrid(app)
            else
              _buildFramesGrid(app),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, Color col, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: col, size: 22),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, Color col, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: col, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segBtn(int idx, String label) {
    final active = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.coral : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColors.inkMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildArtworkGrid(AppController app) {
    final arts = app.profile.artworks;
    if (arts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Image.asset('assets/images/mascots/mascot_penguin.png', height: 90),
            const SizedBox(height: 10),
            Text(
              app.t('Your drawings will appear here.'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: arts.length,
      itemBuilder: (_, i) {
        final a = arts[i];
        final bytes = a.pngBase64 != null ? base64Decode(a.pngBase64!) : null;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder, width: 1.5),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: bytes != null
                        ? Image.memory(bytes, fit: BoxFit.contain)
                        : Image.asset('assets/lessons/${a.lessonId}/preview.png', fit: BoxFit.contain),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        a.lessonTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const Icon(Icons.star_rounded, color: AppColors.amber, size: 16),
                    Text('${a.stars}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFramesGrid(AppController app) {
    final unlocked = app.profile.unlockedFrames.toSet();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: kFrameColors.length,
      itemBuilder: (_, i) {
        final isUnlocked = unlocked.contains(i);
        final isEquipped = app.profile.frameIndex == i;
        return GestureDetector(
          onTap: isUnlocked
              ? () => app.updateProfile(app.profile.copyWith(frameIndex: i))
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isEquipped ? AppColors.coral : AppColors.cardBorder,
                width: isEquipped ? 2.5 : 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarBadge(
                  avatarIndex: app.profile.avatarIndex,
                  frameIndex: i,
                  size: 52,
                ),
                const SizedBox(height: 6),
                Text(
                  isEquipped ? app.t('Use') : (isUnlocked ? 'Frame ${i + 1}' : 'Locked'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isUnlocked ? AppColors.ink : AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
