import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../domain/models/draw_models.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../domain/models/player_profile.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/avatar_badge.dart';
import '../../../core/widgets/cozy_button.dart';
import '../view_models/draw_view_model.dart';
import 'result_page.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({
    super.key,
    required this.lesson,
    required this.mode,
    this.partner,
  });

  final LessonDetail lesson;
  final DrawMode mode;
  final BuddyInfo? partner;

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> with TickerProviderStateMixin {
  late final DrawViewModel _vm;
  final GlobalKey _canvasBoundaryKey = GlobalKey();
  final TransformationController _transformCtrl = TransformationController();
  late final AnimationController _pulseAnim;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _vm = DrawViewModel(
      lesson: widget.lesson,
      mode: widget.mode,
      partner: widget.partner,
    );
    _vm.addListener(_onVmChanged);
    _vm.init();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  void _onVmChanged() {
    if (_vm.isCompleted && !_finishing) {
      _finishing = true;
      _completeAndNavigate();
    }
  }

  Future<void> _completeAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    String? pngBase64;
    try {
      final boundary = _canvasBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 1.5);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (bytes != null) {
          pngBase64 = base64Encode(bytes.buffer.asUint8List());
        }
      }
    } catch (_) {}

    if (!mounted) return;
    final app = AppStateScope.of(context);
    final record = ArtworkRecord(
      id: 'art_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: widget.lesson.summary.id,
      lessonTitle: widget.lesson.summary.titleFor(app.language),
      stars: _vm.earnedStars,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      isTwoPlayer: _vm.isTwoPlayerSession,
      partnerName: widget.partner?.name,
      partnerAvatarIndex: widget.partner?.avatarIndex,
      pngBase64: pngBase64,
      durationSeconds: _vm.elapsedSeconds,
    );
    await app.recordCompletedArtwork(record);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultPage(
          lesson: widget.lesson,
          record: record,
          mode: widget.mode,
          partner: widget.partner,
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    final app = AppStateScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(app.t('Do you want to leave?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(app.t('Stay')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(app.t('Leave drawing')),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _openColorWheel() {
    var hsv = HSVColor.fromColor(_vm.color);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: hsv.toColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardBorder, width: 2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    AppStateScope.of(context).t('More colours'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Align(alignment: Alignment.centerLeft, child: Text('Hue')),
              Slider(
                value: hsv.hue,
                min: 0,
                max: 360,
                activeColor: hsv.toColor(),
                onChanged: (v) {
                  setModalState(() => hsv = hsv.withHue(v));
                  _vm.setColor(hsv.toColor());
                },
              ),
              const Align(alignment: Alignment.centerLeft, child: Text('Saturation')),
              Slider(
                value: hsv.saturation,
                min: 0,
                max: 1,
                activeColor: hsv.toColor(),
                onChanged: (v) {
                  setModalState(() => hsv = hsv.withSaturation(v));
                  _vm.setColor(hsv.toColor());
                },
              ),
              const Align(alignment: Alignment.centerLeft, child: Text('Brightness')),
              Slider(
                value: hsv.value,
                min: 0.05,
                max: 1,
                activeColor: hsv.toColor(),
                onChanged: (v) {
                  setModalState(() => hsv = hsv.withValue(v));
                  _vm.setColor(hsv.toColor());
                },
              ),
              const SizedBox(height: 8),
              CozyButton(
                label: AppStateScope.of(context).t('Done'),
                height: 46,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    _transformCtrl.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final isNeon = _vm.isNeonCanvas;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _confirmExit();
          },
          child: Scaffold(
            backgroundColor: isNeon ? const Color(0xFF0E0B1A) : AppColors.bgCream,
            body: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(app, isNeon),
                  _buildProgressStrip(app, isNeon),
                  Expanded(
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _buildCanvasArea(isNeon),
                            ),
                          ),
                        ),
                        if (_vm.reactions.isNotEmpty)
                          Positioned(
                            top: 12,
                            left: 16,
                            right: 16,
                            child: IgnorePointer(
                              child: Wrap(
                                spacing: 8,
                                alignment: WrapAlignment.center,
                                children: _vm.reactions.reversed.take(2).map((r) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: r.fromPartner ? AppColors.purple : AppColors.coral,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.14),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${r.fromPartner ? "${widget.partner?.name ?? "Buddy"}: " : ""}${r.emoji} ${r.label}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        if (_vm.myDone && !_vm.isCompleted)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.35),
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  app.t('Your part is done!\nWaiting for your buddy...'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildBottomDock(app, isNeon),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(AppController app, bool isNeon) {
    final fg = isNeon ? Colors.white : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: _confirmExit,
            icon: Icon(Icons.close_rounded, color: fg, size: 28),
          ),
          // Players strip
          Expanded(
            child: Row(
              children: [
                AvatarBadge(
                  avatarIndex: app.profile.avatarIndex,
                  frameIndex: app.profile.frameIndex,
                  size: 34,
                ),
                if (_vm.isTwoPlayerSession && widget.partner != null) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.add_rounded, size: 16, color: fg.withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  AvatarBadge(
                    avatarIndex: widget.partner!.avatarIndex,
                    frameIndex: 2,
                    size: 34,
                    showOnlineDot: true,
                    isOnline: true,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.partner!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: fg,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.lesson.summary.titleFor(app.language),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: fg),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Guide',
            onPressed: _vm.toggleGuide,
            icon: Icon(
              _vm.showGuide ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: _vm.showGuide ? AppColors.coral : fg.withValues(alpha: 0.5),
            ),
          ),
          IconButton(
            tooltip: 'Reference',
            onPressed: _vm.togglePreviewHint,
            icon: Icon(
              Icons.image_outlined,
              color: _vm.showPreviewHint ? AppColors.sky : fg.withValues(alpha: 0.6),
            ),
          ),
          IconButton(
            tooltip: 'Zoom / Pan',
            onPressed: () {
              if (_vm.zoomMode) {
                _transformCtrl.value = Matrix4.identity();
              }
              _vm.toggleZoomMode();
            },
            icon: Icon(
              _vm.zoomMode ? Icons.zoom_out_map_rounded : Icons.search_rounded,
              color: _vm.zoomMode ? AppColors.amber : fg.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStrip(AppController app, bool isNeon) {
    final covPct = (_vm.currentStepCoverage * 100).round();
    final stepReady = _vm.currentStepCoverage >= 0.45 || _vm.strokes.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _vm.currentStep.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _vm.currentStep.color, width: 1.4),
            ),
            child: Text(
              app.t('Step {0}/{1}', [_vm.myStepNumber, _vm.myTotalSteps]),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isNeon ? Colors.white : AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _vm.overallProgress.clamp(0.05, 1.0),
                    minHeight: 8,
                    backgroundColor: isNeon ? Colors.white12 : AppColors.cardBorder,
                    valueColor: const AlwaysStoppedAnimation(AppColors.green),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$covPct% · ${_vm.currentStep.isFill ? "Fill area" : "Trace lines"}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isNeon ? Colors.white70 : AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CozyButton(
            label: _vm.myStepNumber == _vm.myTotalSteps ? app.t('Done') : 'Next',
            icon: Icons.arrow_forward_rounded,
            expanded: false,
            height: 40,
            fontSize: 15,
            color: stepReady ? AppColors.green : AppColors.coral,
            onPressed: _vm.myDone ? null : _vm.nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasArea(bool isNeon) {
    return Container(
      decoration: BoxDecoration(
        color: isNeon ? AppColors.neonBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isNeon ? const Color(0xFF4B2B78) : AppColors.cardBorder,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isNeon ? 0.45 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: InteractiveViewer(
          transformationController: _transformCtrl,
          panEnabled: _vm.zoomMode,
          scaleEnabled: _vm.zoomMode,
          minScale: 1.0,
          maxScale: 3.5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _vm.zoomMode
                    ? null
                    : (d) => _vm.startStroke(_toNorm(d.localPosition, size)),
                onPanUpdate: _vm.zoomMode
                    ? null
                    : (d) => _vm.updateStroke(_toNorm(d.localPosition, size)),
                onPanEnd: _vm.zoomMode ? null : (_) => _vm.endStroke(),
                onTapDown: _vm.zoomMode
                    ? null
                    : (d) {
                        _vm.startStroke(_toNorm(d.localPosition, size));
                        _vm.endStroke();
                      },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RepaintBoundary(
                      key: _canvasBoundaryKey,
                      child: CustomPaint(
                        painter: _DrawingCanvasPainter(
                          isNeon: isNeon,
                          strokes: _vm.strokes,
                          activeStroke: _vm.activeStroke,
                          filledSteps: _vm.filledSteps,
                          loadedMasks: _vm.loadedMasks,
                        ),
                      ),
                    ),
                    if (_vm.showPreviewHint)
                      IgnorePointer(
                        child: Opacity(
                          opacity: 0.22,
                          child: Image.asset(
                            widget.lesson.summary.previewAsset,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    if (_vm.showGuide && !_vm.myDone && _vm.currentMaskImage != null)
                      IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, _) => CustomPaint(
                            painter: _StepGuidePainter(
                              mask: _vm.currentMaskImage!,
                              tint: _vm.currentStep.color,
                              opacity: 0.20 + _pulseAnim.value * 0.16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Offset _toNorm(Offset local, Size size) {
    final x = (local.dx / size.width).clamp(0.0, 1.0);
    final y = (local.dy / size.height).clamp(0.0, 1.0);
    return Offset(x, y);
  }

  Widget _buildBottomDock(AppController app, bool isNeon) {
    final palette = widget.lesson.uniqueColors;
    final dockBg = isNeon ? const Color(0xFF1E1933) : Colors.white;
    final borderCol = isNeon ? const Color(0xFF3E2F63) : AppColors.cardBorder;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: dockBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: borderCol, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color swatches + wheel
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: _openColorWheel,
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.cyan,
                          Colors.blue,
                          Colors.purple,
                          Colors.red,
                        ],
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.colorize_rounded, color: Colors.white, size: 18),
                  ),
                ),
                ...palette.map((c) {
                  final selected = _vm.color.toARGB32() == c.toARGB32() &&
                      _vm.tool != BrushTool.eraser;
                  final isStepSuggested = _vm.currentStep.color.toARGB32() == c.toARGB32();
                  return GestureDetector(
                    onTap: () => _vm.setColor(c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: selected ? 38 : 32,
                      height: selected ? 38 : 32,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.coral
                              : (isStepSuggested ? AppColors.amber : Colors.grey.shade300),
                          width: selected ? 3.5 : (isStepSuggested ? 2.5 : 1.5),
                        ),
                      ),
                      child: isStepSuggested && !selected
                          ? const Icon(Icons.star_rounded, size: 14, color: Colors.white)
                          : null,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tools + brush size + undo/redo
          Row(
            children: [
              _toolBtn(Icons.brush_rounded, BrushTool.brush, isNeon),
              const SizedBox(width: 6),
              _toolBtn(Icons.auto_fix_high_rounded, BrushTool.neon, isNeon),
              const SizedBox(width: 6),
              _toolBtn(Icons.format_color_fill_rounded, BrushTool.fill, isNeon),
              const SizedBox(width: 6),
              _toolBtn(Icons.cleaning_services_rounded, BrushTool.eraser, isNeon),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _vm.brushSize.clamp(0.008, 0.10),
                    min: 0.008,
                    max: 0.10,
                    activeColor: AppColors.coral,
                    onChanged: _vm.setBrushSize,
                  ),
                ),
              ),
              IconButton(
                onPressed: _vm.canUndo ? _vm.undo : null,
                icon: Icon(
                  Icons.undo_rounded,
                  color: _vm.canUndo
                      ? (isNeon ? Colors.white : AppColors.ink)
                      : Colors.grey.shade400,
                ),
              ),
              IconButton(
                onPressed: _vm.canRedo ? _vm.redo : null,
                icon: Icon(
                  Icons.redo_rounded,
                  color: _vm.canRedo
                      ? (isNeon ? Colors.white : AppColors.ink)
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
          if (_vm.isTwoPlayerSession) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _reactionChip(Icons.waving_hand_rounded, AppColors.amberDark, '👋', app.t('Hi!')),
                _reactionChip(Icons.thumb_up_rounded, AppColors.sky, '👏', app.t('Nice!')),
                _reactionChip(Icons.favorite_rounded, AppColors.coral, '❤️', app.t('So good!')),
                _reactionChip(Icons.local_fire_department_rounded, AppColors.purple, '🔥', app.t('Wow!')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, BrushTool tool, bool isNeon) {
    final active = _vm.tool == tool;
    return GestureDetector(
      onTap: () => _vm.setTool(tool),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: active
              ? AppColors.coral
              : (isNeon ? Colors.white10 : AppColors.bgCream),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? Colors.white : (isNeon ? Colors.white70 : AppColors.ink),
        ),
      ),
    );
  }

  Widget _reactionChip(IconData icon, Color iconColor, String emoji, String label) {
    return GestureDetector(
      onTap: () => _vm.sendReaction(emoji, label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawingCanvasPainter extends CustomPainter {
  _DrawingCanvasPainter({
    required this.isNeon,
    required this.strokes,
    required this.activeStroke,
    required this.filledSteps,
    required this.loadedMasks,
  });

  final bool isNeon;
  final List<DrawStroke> strokes;
  final DrawStroke? activeStroke;
  final Map<int, Color> filledSteps;
  final Map<int, StepMaskData> loadedMasks;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = isNeon ? AppColors.neonBg : Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw filled step masks first
    for (final entry in filledSteps.entries) {
      final mask = loadedMasks[entry.key]?.image;
      if (mask == null) continue;
      final rect = Offset.zero & size;
      canvas.saveLayer(rect, Paint());
      canvas.drawImageRect(
        mask,
        Rect.fromLTWH(0, 0, mask.width.toDouble(), mask.height.toDouble()),
        rect,
        Paint(),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = entry.value
          ..blendMode = BlendMode.srcIn,
      );
      canvas.restore();
    }

    // Draw all strokes
    for (final s in strokes) {
      _paintStroke(canvas, size, s);
    }
    if (activeStroke != null) {
      _paintStroke(canvas, size, activeStroke!);
    }
  }

  void _paintStroke(Canvas canvas, Size size, DrawStroke stroke) {
    if (stroke.points.isEmpty) return;
    final w = max(2.0, stroke.strokeWidth * size.width);

    if (stroke.tool == BrushTool.neon) {
      final glowPaint = Paint()
        ..color = stroke.color.withValues(alpha: 0.45)
        ..strokeWidth = w * 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      _drawPath(canvas, size, stroke.points, glowPaint);

      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.92)
        ..strokeWidth = w * 0.55
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      _drawPath(canvas, size, stroke.points, corePaint);
      return;
    }

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    _drawPath(canvas, size, stroke.points, paint);
  }

  void _drawPath(Canvas canvas, Size size, List<Offset> pts, Paint paint) {
    if (pts.length == 1) {
      final p = Offset(pts[0].dx * size.width, pts[0].dy * size.height);
      canvas.drawCircle(p, paint.strokeWidth / 2, paint..style = PaintingStyle.fill);
      return;
    }
    final path = Path()
      ..moveTo(pts[0].dx * size.width, pts[0].dy * size.height);
    for (var i = 1; i < pts.length; i++) {
      final prev = Offset(pts[i - 1].dx * size.width, pts[i - 1].dy * size.height);
      final cur = Offset(pts[i].dx * size.width, pts[i].dy * size.height);
      final mid = Offset((prev.dx + cur.dx) / 2, (prev.dy + cur.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    final last = pts.last;
    path.lineTo(last.dx * size.width, last.dy * size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DrawingCanvasPainter oldDelegate) => true;
}

class _StepGuidePainter extends CustomPainter {
  _StepGuidePainter({
    required this.mask,
    required this.tint,
    required this.opacity,
  });

  final ui.Image mask;
  final Color tint;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());
    canvas.drawImageRect(
      mask,
      Rect.fromLTWH(0, 0, mask.width.toDouble(), mask.height.toDouble()),
      rect,
      Paint(),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = tint.withValues(alpha: opacity)
        ..blendMode = BlendMode.srcIn,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StepGuidePainter oldDelegate) =>
      oldDelegate.mask != mask ||
      oldDelegate.tint != tint ||
      oldDelegate.opacity != opacity;
}
