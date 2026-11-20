import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/draw_models.dart';
import '../../../../domain/models/lesson.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/avatar_badge.dart';
import '../../../core/widgets/cozy_button.dart';
import 'draw_page.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key, required this.lesson});

  final LessonDetail lesson;

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late final String _roomCode;

  @override
  void initState() {
    super.initState();
    _roomCode = (1000 + Random().nextInt(9000)).toString();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final bot = app.buddies.first;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: Text(app.t('Your room'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      app.t('ROOM CODE'),
                      style: const TextStyle(
                        fontSize: 13,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _roomCode.split('').map((digit) {
                        return Container(
                          width: 52,
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.bgCream,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.coral, width: 2),
                          ),
                          child: Text(
                            digit,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _roomCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(app.t('Room code copied. Send it to your friend!'))),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, color: AppColors.coral),
                      label: Text(
                        app.t('Share the room code with a friend'),
                        style: const TextStyle(color: AppColors.coral, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _seatCard(
                      avatarIndex: app.profile.avatarIndex,
                      label: app.t('You · host'),
                      ready: true,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _seatCard(
                      avatarIndex: bot.avatarIndex,
                      label: '${bot.name} ${app.t(" (bot)")}',
                      ready: true,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              CozyButton(
                label: app.t("Let's draw!"),
                icon: Icons.brush_rounded,
                color: AppColors.green,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => DrawPage(
                        lesson: widget.lesson,
                        mode: DrawMode.privateRoom,
                        partner: bot,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seatCard({
    required int avatarIndex,
    required String label,
    required bool ready,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: ready ? AppColors.green : AppColors.cardBorder,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          AvatarBadge(avatarIndex: avatarIndex, size: 64),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            ready ? 'Ready' : 'Waiting...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ready ? AppColors.green : AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
