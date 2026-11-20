import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/player_profile.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/avatar_badge.dart';
import '../../../core/widgets/cozy_button.dart';
import '../../drawing/views/join_room_page.dart';
import '../../drawing/views/preview_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _inviteBuddy(BuddyInfo buddy) {
    final app = AppStateScope.of(context);
    final twoP = app.lessons.where((l) => l.isTwoPlayer).toList();
    if (twoP.isEmpty) return;
    final pick = twoP[Random().nextInt(twoP.length)];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewPage(summary: pick, preselectedPartner: buddy),
      ),
    );
  }

  void _addFriendDialog() {
    final app = AppStateScope.of(context);
    _codeCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(app.t('Add friend')),
        content: TextField(
          controller: _codeCtrl,
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: app.t("Type your friend's code"),
            filled: true,
            fillColor: AppColors.bgCream,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(app.t('Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              app.addBuddyByCode(_codeCtrl.text);
              Navigator.pop(ctx);
            },
            child: Text(app.t('Add friend')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final buddies = app.buddies;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.t('Buddies'),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
                      ),
                      Text(
                        app.t('Draw with friends and new pals'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppColors.coral),
                  onPressed: _addFriendDialog,
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Friend Code + Join Room Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.t('Your friend code: {0}', [app.profile.friendCode]),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              app.t('Share my code'),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: app.profile.friendCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                app.t('Your code was copied: {0}', [app.profile.friendCode]),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, color: AppColors.coral, size: 18),
                        label: const Text('Copy', style: TextStyle(color: AppColors.coral)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CozyButton(
                    label: app.t('Join with code'),
                    icon: Icons.vpn_key_rounded,
                    color: AppColors.sky,
                    height: 46,
                    fontSize: 15,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const JoinRoomPage()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...buddies.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder, width: 1.4),
                    ),
                    child: Row(
                      children: [
                        AvatarBadge(
                          avatarIndex: b.avatarIndex,
                          size: 48,
                          frameIndex: b.avatarIndex % 5,
                          showOnlineDot: true,
                          isOnline: b.isOnline,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.isBot ? '${b.name}${app.t(" (bot)")}' : b.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                b.isOnline
                                    ? app.t('Active now')
                                    : app.t('Active {0} min ago', [b.lastActiveMinutes]),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: b.isOnline ? AppColors.green : AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CozyButton(
                          label: app.t('Draw'),
                          color: AppColors.coral,
                          expanded: false,
                          height: 38,
                          fontSize: 14,
                          onPressed: () => _inviteBuddy(b),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
