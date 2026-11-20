import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../data/services/loc_service.dart';
import '../../../../domain/models/lesson.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/avatar_badge.dart';
import '../../../core/widgets/cozy_button.dart';
import '../../shell/views/main_shell.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0; // 0: Lang, 1: Benefits, 2: Name, 3: Avatar, 4: Age, 5: Purpose, 6: Interests, 7: Personalize, 8: Gift
  int _benefitSlide = 0;
  final TextEditingController _nameCtrl = TextEditingController();
  int _avatarIndex = 0;
  String _ageGroup = '18-24';
  String _purpose = 'Relax and unwind';
  final Set<String> _interests = {'animal', 'food', 'nature'};

  static const _randomNames = [
    'SunnyBear', 'MochiDraw', 'DoodleFox', 'CrayonCat', 'PixelPup',
    'StarSketch', 'BobaBunny', 'CozyPanda', 'MintyOwl', 'BerryBee',
  ];

  static const _ageGroups = ['Under 12', '13 - 17', '18 - 24', '25 - 34', '35 - 44', '45+'];

  static const _purposes = [
    ('Relax and unwind', Icons.spa_rounded, AppColors.green),
    ('Get better at drawing', Icons.brush_rounded, AppColors.sky),
    ('Draw with other people', Icons.people_rounded, AppColors.coral),
    ('Teach my kids to draw', Icons.child_care_rounded, AppColors.amber),
    ('Recover and feel better', Icons.favorite_rounded, AppColors.pink),
    ('Something else', Icons.auto_awesome_rounded, AppColors.purple),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 1 && _benefitSlide < 2) {
      setState(() => _benefitSlide++);
      return;
    }
    if (_step == 6) {
      setState(() => _step = 7);
      Future.delayed(const Duration(milliseconds: 1700), () {
        if (mounted && _step == 7) {
          setState(() => _step = 8);
        }
      });
      return;
    }
    setState(() => _step++);
  }

  void _prevStep() {
    if (_step == 1 && _benefitSlide > 0) {
      setState(() => _benefitSlide--);
      return;
    }
    if (_step > 0 && _step < 7) {
      setState(() => _step--);
    }
  }

  Future<void> _finish() async {
    final app = AppStateScope.of(context);
    final chosenName = _nameCtrl.text.trim().isEmpty
        ? _randomNames[Random().nextInt(_randomNames.length)]
        : _nameCtrl.text.trim();
    await app.completeOnboarding(
      name: chosenName,
      avatarIndex: _avatarIndex,
      ageGroup: _ageGroup,
      purpose: _purpose,
      interests: _interests.toList(),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            if (_step > 0 && _step < 7)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _prevStep,
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_step + 1) / 8,
                          minHeight: 8,
                          backgroundColor: AppColors.cardBorder,
                          valueColor: const AlwaysStoppedAnimation(AppColors.coral),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip',
                        style: TextStyle(color: AppColors.inkMuted, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: KeyedSubtree(
                  key: ValueKey('step_${_step}_$_benefitSlide'),
                  child: _buildStep(app),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(AppController app) {
    switch (_step) {
      case 0:
        return _buildLanguageStep(app);
      case 1:
        return _buildBenefitsStep(app);
      case 2:
        return _buildNameStep(app);
      case 3:
        return _buildAvatarStep(app);
      case 4:
        return _buildAgeStep(app);
      case 5:
        return _buildPurposeStep(app);
      case 6:
        return _buildInterestsStep(app);
      case 7:
        return _buildPersonalizeStep(app);
      default:
        return _buildGiftStep(app);
    }
  }

  Widget _buildLanguageStep(AppController app) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Image.asset('assets/images/mascots/mascot_wave.png', height: 110),
          const SizedBox(height: 12),
          Text(app.t('Pick a language'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(app.t('Change it anytime in Settings'), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: kSupportedLanguages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final lang = kSupportedLanguages[i];
                final selected = app.language == lang.code;
                return GestureDetector(
                  onTap: () => app.setLanguage(lang.code),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.coral.withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? AppColors.coral : AppColors.cardBorder,
                        width: selected ? 2.2 : 1.4,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(lang.flagAsset, width: 32, height: 24, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            lang.nativeName,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle_rounded, color: AppColors.coral, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          CozyButton(label: app.t('Continue'), onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildBenefitsStep(AppController app) {
    final slides = [
      (
        'assets/images/mascots/ob_benefit_draw.png',
        app.t('Always Something\nFun to Draw'),
        app.t('Trace step by step at your own pace'),
      ),
      (
        'assets/images/mascots/ob_benefit_friends.png',
        app.t('Meet Friends\nThrough Drawing'),
        app.t('Team up on one picture,\nin real time'),
      ),
      (
        'assets/images/mascots/ob_benefit_chat.png',
        app.t('Chat, Connect,\nDraw Together.'),
        app.t('Draw with friends and new pals'),
      ),
    ];
    final slide = slides[_benefitSlide];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            height: 260,
            padding: const EdgeInsets.all(16),
            child: Image.asset(slide.$1, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          Text(
            slide.$2,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 10),
          Text(
            slide.$3,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final active = i == _benefitSlide;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.coral : AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
          const Spacer(),
          CozyButton(label: app.t('Continue'), onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildNameStep(AppController app) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Image.asset('assets/images/mascots/mascot_wave.png', height: 130),
          const SizedBox(height: 12),
          Text(
            app.t('Hi! What should\nwe call you?'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  maxLength: 18,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: app.t('Type your name'),
                    filled: true,
                    fillColor: Colors.white,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppColors.coral, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _nameCtrl.text = _randomNames[Random().nextInt(_randomNames.length)];
                  });
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: AppColors.amberDark, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Icon(Icons.casino_rounded, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
          const Spacer(),
          CozyButton(label: app.t('Continue'), onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildAvatarStep(AppController app) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            app.t('Choose your buddy face'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          AvatarBadge(avatarIndex: _avatarIndex, size: 112, frameIndex: 0),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: 16,
              itemBuilder: (_, i) {
                final selected = i == _avatarIndex;
                return GestureDetector(
                  onTap: () => setState(() => _avatarIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.coral.withValues(alpha: 0.14) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.coral : AppColors.cardBorder,
                        width: selected ? 3 : 1.5,
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
          const SizedBox(height: 14),
          CozyButton(label: app.t('Continue'), onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildAgeStep(AppController app) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(app.t('How old are you?'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(app.t('So we can pick the right pictures'), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.8,
              ),
              itemCount: _ageGroups.length,
              itemBuilder: (_, i) {
                final age = _ageGroups[i];
                final selected = _ageGroup == age;
                return GestureDetector(
                  onTap: () => setState(() => _ageGroup = age),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.coral : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.coralDark : AppColors.cardBorder,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      age,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          CozyButton(label: app.t('Continue'), onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildPurposeStep(AppController app) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(app.t('What brings you here?'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(app.t('Pick the one that fits best'), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: _purposes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final (key, icon, col) = _purposes[i];
                final selected = _purpose == key;
                return GestureDetector(
                  onTap: () => setState(() => _purpose = key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? col.withValues(alpha: 0.14) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? col : AppColors.cardBorder,
                        width: selected ? 2.2 : 1.4,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: col.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: col),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            app.t(key),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (selected) Icon(Icons.check_circle_rounded, color: col),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          CozyButton(label: app.t('Continue'), onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildInterestsStep(AppController app) {
    final cats = kLessonCategories.where((c) => c.id != 'all').toList();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(app.t('What do you love?'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(app.t('Pick at least one'), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemCount: cats.length,
              itemBuilder: (_, i) {
                final c = cats[i];
                final selected = _interests.contains(c.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected && _interests.length > 1) {
                        _interests.remove(c.id);
                      } else {
                        _interests.add(c.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected ? c.accentColor.withValues(alpha: 0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? c.accentColor : AppColors.cardBorder,
                        width: selected ? 2.4 : 1.4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(c.iconAsset, width: 42, height: 42),
                        const SizedBox(height: 6),
                        Text(
                          app.t(c.labelKey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          CozyButton(label: app.t('Continue'), onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildPersonalizeStep(AppController app) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/mascots/mascot_penguin.png', height: 150),
          const SizedBox(height: 24),
          Text(
            app.t('Setting up your Sketch Book'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            app.t("Picking lessons you'll love"),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: 28),
          const SizedBox(
            width: 220,
            child: LinearProgressIndicator(
              minHeight: 10,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation(AppColors.coral),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftStep(AppController app) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Image.asset('assets/images/mascots/mascot_gift.png', height: 180),
          const SizedBox(height: 20),
          Text(
            app.t('We have a welcome gift for you'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 10),
          Text(
            app.t('You got a new frame!'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            app.t('Wear it now, or pick it later\nin your profile.'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          CozyButton(
            label: app.t("Let's draw!"),
            color: AppColors.green,
            shadowColor: AppColors.greenDark,
            onPressed: _finish,
          ),
        ],
      ),
    );
  }
}
