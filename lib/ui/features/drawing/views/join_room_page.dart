import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/draw_models.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/cozy_button.dart';
import 'draw_page.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    final digits = (data?.text ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      setState(() => _ctrl.text = digits.substring(0, 4));
    } else if (mounted) {
      final app = AppStateScope.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.t('No room code in the clipboard'))),
      );
    }
  }

  Future<void> _join() async {
    final app = AppStateScope.of(context);
    if (_ctrl.text.trim().length != 4) return;
    final twoP = app.lessons.where((l) => l.isTwoPlayer).toList();
    if (twoP.isEmpty) return;
    final pick = twoP[Random().nextInt(twoP.length)];
    final detail = await app.repo.loadLessonDetail(pick.id);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DrawPage(
          lesson: detail,
          mode: DrawMode.privateRoom,
          partner: app.buddies[Random().nextInt(app.buddies.length)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final code = _ctrl.text;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: Text(app.t('Join a room'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.vpn_key_rounded, color: AppColors.amberDark, size: 42),
              ),
              const SizedBox(height: 18),
              Text(
                app.t('Type the room code'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                app.t('A friend code has 6 characters. A room code has 4 digits.'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final ch = i < code.length ? code[i] : '';
                  return Container(
                    width: 58,
                    height: 66,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: ch.isNotEmpty ? AppColors.coral : AppColors.cardBorder,
                        width: 2.2,
                      ),
                    ),
                    child: Text(
                      ch,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _ctrl,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '1234',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _paste,
                icon: const Icon(Icons.paste_rounded, color: AppColors.sky),
                label: Text(
                  app.t('Paste code'),
                  style: const TextStyle(color: AppColors.sky, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              CozyButton(
                label: app.t('Join'),
                onPressed: code.length == 4 ? _join : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
