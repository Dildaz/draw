import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/draw_models.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../domain/models/player_profile.dart';

class StepMaskData {
  StepMaskData({
    required this.image,
    required this.gridSize,
    required this.maskCells,
    required this.maskPoints,
  });

  final ui.Image image;
  final int gridSize;
  final Set<int> maskCells; // y * gridSize + x
  final List<Offset> maskPoints; // normalized 0..1 centers of mask cells
}

class DrawViewModel extends ChangeNotifier {
  DrawViewModel({
    required this.lesson,
    required this.mode,
    this.partner,
  }) {
    _isTwoPlayerSession = lesson.summary.isTwoPlayer && mode != DrawMode.solo;
    _myStepIndices = [];
    _partnerStepIndices = [];
    for (var i = 0; i < lesson.steps.length; i++) {
      if (_isTwoPlayerSession && lesson.steps[i].lane == 1) {
        _partnerStepIndices.add(i);
      } else {
        _myStepIndices.add(i);
      }
    }
    if (_myStepIndices.isEmpty) {
      _myStepIndices = List.generate(lesson.steps.length, (i) => i);
      _partnerStepIndices = [];
    }
    _startedAt = DateTime.now();
    _applyStepDefaults();
  }

  final LessonDetail lesson;
  final DrawMode mode;
  final BuddyInfo? partner;

  late final bool _isTwoPlayerSession;
  late List<int> _myStepIndices;
  late List<int> _partnerStepIndices;
  late final DateTime _startedAt;

  bool get isTwoPlayerSession => _isTwoPlayerSession;
  bool get isNeonCanvas => lesson.summary.isNeon;

  int _myCursor = 0;
  int _partnerCursor = 0;
  bool _myDone = false;
  bool _partnerDone = false;
  bool _isCompleted = false;

  bool get myDone => _myDone;
  bool get partnerDone => _partnerDone;
  bool get isCompleted => _isCompleted;

  int get myStepNumber => (_myCursor + 1).clamp(1, _myStepIndices.length);
  int get myTotalSteps => _myStepIndices.length;
  int get currentGlobalStepIndex =>
      _myStepIndices[_myCursor.clamp(0, _myStepIndices.length - 1)];
  LessonStep get currentStep => lesson.steps[currentGlobalStepIndex];

  double get overallProgress {
    final total = _myStepIndices.length + _partnerStepIndices.length;
    if (total == 0) return 1.0;
    final done = (_myDone ? _myStepIndices.length : _myCursor) +
        (_partnerDone ? _partnerStepIndices.length : _partnerCursor);
    return (done / total).clamp(0.0, 1.0);
  }

  // Loaded masks
  final Map<int, StepMaskData> _masks = {};
  ui.Image? get currentMaskImage => _masks[currentGlobalStepIndex]?.image;

  // Coverage tracking per step
  final Set<int> _hitMaskCells = {};
  int _totalStrokePoints = 0;
  int _insideMaskPoints = 0;
  final List<double> _stepScores = [];

  double get currentStepCoverage {
    final mask = _masks[currentGlobalStepIndex];
    if (mask == null || mask.maskCells.isEmpty) return 0;
    return (_hitMaskCells.length / mask.maskCells.length).clamp(0.0, 1.0);
  }

  // Drawing tools & state
  BrushTool _tool = BrushTool.brush;
  Color _color = const Color(0xFF202020);
  double _brushSize = 0.028; // normalized
  bool _showGuide = true;
  bool _showPreviewHint = false;
  bool _zoomMode = false;

  BrushTool get tool => _tool;
  Color get color => _color;
  double get brushSize => _brushSize;
  bool get showGuide => _showGuide;
  bool get showPreviewHint => _showPreviewHint;
  bool get zoomMode => _zoomMode;

  final List<DrawStroke> _strokes = [];
  final List<DrawStroke> _redoStack = [];
  DrawStroke? _activeStroke;

  List<DrawStroke> get strokes => _strokes;
  DrawStroke? get activeStroke => _activeStroke;
  bool get canUndo => _strokes.any((s) => !s.isPartner);
  bool get canRedo => _redoStack.isNotEmpty;

  // Filled steps (for Magic Fill tool or bot fill)
  final Map<int, Color> _filledSteps = {};
  Map<int, Color> get filledSteps => _filledSteps;
  Map<int, StepMaskData> get loadedMasks => _masks;

  // Reactions & quick chat
  final List<QuickReaction> _reactions = [];
  List<QuickReaction> get reactions => _reactions;

  Timer? _botTimer;
  List<Offset> _botQueue = [];
  DrawStroke? _botActiveStroke;

  int get elapsedSeconds =>
      DateTime.now().difference(_startedAt).inSeconds.clamp(5, 3600);

  int get earnedStars {
    if (_stepScores.isEmpty) return 4;
    final avg = _stepScores.reduce((a, b) => a + b) / _stepScores.length;
    if (avg >= 0.72) return 5;
    if (avg >= 0.50) return 4;
    if (avg >= 0.30) return 3;
    return 4;
  }

  Future<void> init() async {
    await _ensureMaskLoaded(currentGlobalStepIndex);
    // Preload next few masks in background
    for (var i = 0; i < lesson.steps.length; i++) {
      _ensureMaskLoaded(i);
    }
    if (_isTwoPlayerSession && _partnerStepIndices.isNotEmpty) {
      _startBotPartner();
    } else {
      _partnerDone = true;
    }
    notifyListeners();
  }

  Future<void> _ensureMaskLoaded(int stepIndex) async {
    if (_masks.containsKey(stepIndex)) return;
    try {
      final step = lesson.steps[stepIndex];
      final data = await rootBundle.load(lesson.maskAsset(step));
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);

      const grid = 48;
      final cells = <int>{};
      final pts = <Offset>[];
      if (byteData != null) {
        final w = img.width;
        final h = img.height;
        for (var gy = 0; gy < grid; gy++) {
          final py = ((gy + 0.5) * h / grid).floor().clamp(0, h - 1);
          for (var gx = 0; gx < grid; gx++) {
            final px = ((gx + 0.5) * w / grid).floor().clamp(0, w - 1);
            final off = (py * w + px) * 4;
            final r = byteData.getUint8(off);
            final a = byteData.getUint8(off + 3);
            if (r > 90 && a > 90) {
              cells.add(gy * grid + gx);
              pts.add(Offset((gx + 0.5) / grid, (gy + 0.5) / grid));
            }
          }
        }
      }

      _masks[stepIndex] = StepMaskData(
        image: img,
        gridSize: grid,
        maskCells: cells,
        maskPoints: pts,
      );
      if (stepIndex == currentGlobalStepIndex) {
        notifyListeners();
      }
    } catch (_) {}
  }

  void _applyStepDefaults() {
    final step = currentStep;
    _color = step.color;
    _brushSize = step.brush.clamp(0.012, 0.085);
    if (isNeonCanvas) {
      _tool = BrushTool.neon;
    } else if (step.isFill) {
      _tool = BrushTool.brush;
    } else {
      _tool = BrushTool.brush;
    }
    _hitMaskCells.clear();
  }

  void setTool(BrushTool t) {
    _tool = t;
    _zoomMode = false;
    notifyListeners();
  }

  void setColor(Color c) {
    _color = c;
    if (_tool == BrushTool.eraser) {
      _tool = isNeonCanvas ? BrushTool.neon : BrushTool.brush;
    }
    notifyListeners();
  }

  void setBrushSize(double s) {
    _brushSize = s.clamp(0.008, 0.10);
    notifyListeners();
  }

  void toggleGuide() {
    _showGuide = !_showGuide;
    notifyListeners();
  }

  void togglePreviewHint() {
    _showPreviewHint = !_showPreviewHint;
    notifyListeners();
  }

  void toggleZoomMode() {
    _zoomMode = !_zoomMode;
    notifyListeners();
  }

  void startStroke(Offset normPoint) {
    if (_myDone || _zoomMode) return;
    if (_tool == BrushTool.fill) {
      _filledSteps[currentGlobalStepIndex] = _color;
      final mask = _masks[currentGlobalStepIndex];
      if (mask != null) {
        _hitMaskCells.addAll(mask.maskCells);
      }
      notifyListeners();
      return;
    }
    _redoStack.clear();
    _activeStroke = DrawStroke(
      points: [normPoint],
      color: _tool == BrushTool.eraser
          ? (isNeonCanvas ? const Color(0xFF161326) : Colors.white)
          : _color,
      strokeWidth: _brushSize,
      tool: _tool,
      stepIndex: currentGlobalStepIndex,
      isPartner: false,
    );
    _recordMaskHit(normPoint);
    notifyListeners();
  }

  void updateStroke(Offset normPoint) {
    if (_activeStroke == null || _myDone || _zoomMode) return;
    final pts = _activeStroke!.points;
    if (pts.isNotEmpty && (pts.last - normPoint).distance < 0.003) return;
    pts.add(normPoint);
    _recordMaskHit(normPoint);
    notifyListeners();
  }

  void endStroke() {
    if (_activeStroke == null) return;
    _strokes.add(_activeStroke!);
    _activeStroke = null;
    notifyListeners();
  }

  void _recordMaskHit(Offset normPoint) {
    if (_tool == BrushTool.eraser) return;
    final mask = _masks[currentGlobalStepIndex];
    if (mask == null) return;
    final g = mask.gridSize;
    final cx = (normPoint.dx * g).floor().clamp(0, g - 1);
    final cy = (normPoint.dy * g).floor().clamp(0, g - 1);
    final radiusCells = ((_brushSize * g) * 0.65).ceil().clamp(1, 5);
    var hitAny = false;
    for (var dy = -radiusCells; dy <= radiusCells; dy++) {
      for (var dx = -radiusCells; dx <= radiusCells; dx++) {
        final nx = cx + dx;
        final ny = cy + dy;
        if (nx >= 0 && nx < g && ny >= 0 && ny < g) {
          final key = ny * g + nx;
          if (mask.maskCells.contains(key)) {
            _hitMaskCells.add(key);
            hitAny = true;
          }
        }
      }
    }
    _totalStrokePoints++;
    if (hitAny) _insideMaskPoints++;
  }

  void undo() {
    for (var i = _strokes.length - 1; i >= 0; i--) {
      if (!_strokes[i].isPartner) {
        _redoStack.add(_strokes.removeAt(i));
        notifyListeners();
        return;
      }
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _strokes.add(_redoStack.removeLast());
    notifyListeners();
  }

  void nextStep() {
    if (_myDone) return;
    final cov = currentStepCoverage;
    final acc = _totalStrokePoints > 0 ? (_insideMaskPoints / _totalStrokePoints) : 0.8;
    _stepScores.add((cov * 0.7 + acc * 0.3).clamp(0.2, 1.0));

    // Snap-polish: if user painted nicely (>45%), gently fill the mask underneath if it's a fill step
    if (currentStep.isFill && cov >= 0.45 && !_filledSteps.containsKey(currentGlobalStepIndex)) {
      _filledSteps[currentGlobalStepIndex] = _color;
    }

    if (_myCursor + 1 < _myStepIndices.length) {
      _myCursor++;
      _applyStepDefaults();
      _ensureMaskLoaded(currentGlobalStepIndex);
      if (_isTwoPlayerSession && Random().nextDouble() < 0.45) {
        _emitBotReaction();
      }
    } else {
      _myDone = true;
      _checkFinish();
    }
    notifyListeners();
  }

  void sendReaction(String emoji, String label) {
    _reactions.add(QuickReaction(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      emoji: emoji,
      label: label,
      fromPartner: false,
      timestamp: DateTime.now(),
    ));
    if (_reactions.length > 6) _reactions.removeAt(0);
    notifyListeners();

    if (_isTwoPlayerSession) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!_isCompleted) _emitBotReaction();
      });
    }
  }

  void _emitBotReaction() {
    const replies = [
      ('🎨', 'Nice!'),
      ('✨', 'So good!'),
      ('👏', 'Awesome!'),
      ('❤️', 'Wow!'),
      ('🔥', 'Super!'),
    ];
    final pick = replies[Random().nextInt(replies.length)];
    _reactions.add(QuickReaction(
      id: 'bot_${DateTime.now().microsecondsSinceEpoch}',
      emoji: pick.$1,
      label: pick.$2,
      fromPartner: true,
      timestamp: DateTime.now(),
    ));
    if (_reactions.length > 6) _reactions.removeAt(0);
    notifyListeners();
  }

  void _startBotPartner() {
    _botTimer = Timer.periodic(const Duration(milliseconds: 110), (_) {
      if (_partnerDone || _isCompleted) {
        _botTimer?.cancel();
        return;
      }
      final stepIdx = _partnerStepIndices[_partnerCursor];
      final mask = _masks[stepIdx];
      if (mask == null) return;

      final step = lesson.steps[stepIdx];
      if (_botQueue.isEmpty) {
        if (mask.maskPoints.isEmpty) {
          _advanceBotStep();
          return;
        }
        // Sample points in sweeping order to look like real hand-drawing
        final pts = List<Offset>.from(mask.maskPoints);
        final stride = (pts.length / 26).ceil().clamp(1, 8);
        _botQueue = [
          for (var i = 0; i < pts.length; i += stride) pts[i],
        ];
        _botActiveStroke = DrawStroke(
          points: [],
          color: step.color,
          strokeWidth: (step.brush * 1.15).clamp(0.018, 0.08),
          tool: isNeonCanvas ? BrushTool.neon : BrushTool.brush,
          stepIndex: stepIdx,
          isPartner: true,
        );
        _strokes.add(_botActiveStroke!);
      }

      final nextPt = _botQueue.removeAt(0);
      // Break stroke if jumping far
      if (_botActiveStroke!.points.isNotEmpty &&
          (_botActiveStroke!.points.last - nextPt).distance > 0.14) {
        _botActiveStroke = DrawStroke(
          points: [nextPt],
          color: step.color,
          strokeWidth: (step.brush * 1.15).clamp(0.018, 0.08),
          tool: isNeonCanvas ? BrushTool.neon : BrushTool.brush,
          stepIndex: stepIdx,
          isPartner: true,
        );
        _strokes.add(_botActiveStroke!);
      } else {
        _botActiveStroke!.points.add(nextPt);
      }

      if (_botQueue.isEmpty) {
        if (step.isFill) {
          _filledSteps[stepIdx] = step.color;
        }
        _advanceBotStep();
      }
      notifyListeners();
    });
  }

  void _advanceBotStep() {
    if (_partnerCursor + 1 < _partnerStepIndices.length) {
      _partnerCursor++;
    } else {
      _partnerDone = true;
      _botTimer?.cancel();
      _checkFinish();
    }
  }

  void _checkFinish() {
    if (_myDone && _partnerDone) {
      _isCompleted = true;
      notifyListeners();
    } else if (_myDone && !_partnerDone) {
      // Speed up bot so user doesn't wait long!
      _botTimer?.cancel();
      _botTimer = Timer.periodic(const Duration(milliseconds: 35), (_) {
        if (_partnerDone) {
          _botTimer?.cancel();
          return;
        }
        final stepIdx = _partnerStepIndices[_partnerCursor];
        final step = lesson.steps[stepIdx];
        _filledSteps[stepIdx] = step.color;
        _advanceBotStep();
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    super.dispose();
  }
}
