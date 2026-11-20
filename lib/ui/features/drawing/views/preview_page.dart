import 'package:flutter/material.dart';
import '../../../../domain/models/draw_models.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../domain/models/player_profile.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/cozy_button.dart';
import 'draw_page.dart';
import 'lobby_page.dart';
import 'matching_page.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({
    super.key,
    required this.summary,
    this.preselectedPartner,
  });

  final LessonSummary summary;
  final BuddyInfo? preselectedPartner;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  LessonDetail? _detail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final app = AppStateScope.of(context);
      final d = await app.repo.loadLessonDetail(widget.summary.id);
      if (mounted) setState(() => _detail = d);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final isNeon = widget.summary.isNeon;
    final detail = _detail;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Text(app.t('Preview')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 260,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isNeon ? AppColors.neonBg : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isNeon ? const Color(0xFF4B2B78) : AppColors.cardBorder,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          widget.summary.previewAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.summary.titleFor(app.language),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _infoPill(
                            widget.summary.isTwoPlayer
                                ? Icons.people_rounded
                                : Icons.person_rounded,
                            widget.summary.isTwoPlayer ? '2 ${app.t("players")}' : app.t('Learn solo'),
                            widget.summary.isTwoPlayer ? AppColors.coral : AppColors.sky,
                          ),
                          const SizedBox(width: 10),
                          _infoPill(
                            Icons.layers_rounded,
                            app.t('{0} steps', [widget.summary.stepCount]),
                            AppColors.purple,
                          ),
                        ],
                      ),
                      if (detail != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          app.t("Colours you'll use"),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: detail.uniqueColors.map((c) {
                            return Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.cardBorder, width: 2),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (detail == null)
                const CircularProgressIndicator(color: AppColors.coral)
              else if (widget.summary.isTwoPlayer) ...[
                CozyButton(
                  label: widget.preselectedPartner != null
                      ? '${app.t("Draw Now")} · ${widget.preselectedPartner!.name}'
                      : app.t('Quick buddy'),
                  icon: Icons.bolt_rounded,
                  color: AppColors.coral,
                  onPressed: () {
                    if (widget.preselectedPartner != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => DrawPage(
                            lesson: detail,
                            mode: DrawMode.buddyBot,
                            partner: widget.preselectedPartner,
                          ),
                        ),
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => MatchingPage(lesson: detail)),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CozyButton(
                        label: app.t('Invite a friend'),
                        icon: Icons.vpn_key_rounded,
                        color: AppColors.sky,
                        height: 48,
                        fontSize: 15,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => LobbyPage(lesson: detail)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CozyButton(
                        label: app.t('Learn solo'),
                        icon: Icons.brush_rounded,
                        color: AppColors.green,
                        height: 48,
                        fontSize: 15,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => DrawPage(
                                lesson: detail,
                                mode: DrawMode.solo,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ] else
                CozyButton(
                  label: app.t('Draw Now'),
                  icon: Icons.brush_rounded,
                  color: AppColors.green,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => DrawPage(
                          lesson: detail,
                          mode: DrawMode.solo,
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

  Widget _infoPill(IconData icon, String text, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: col),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: col),
          ),
        ],
      ),
    );
  }
}
