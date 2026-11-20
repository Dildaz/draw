import 'package:flutter/material.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../shell/views/main_shell.dart';
import 'onboarding_flow.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _navigated) return;
    final app = AppStateScope.of(context);
    if (app.initialized) {
      _goNext(app);
    } else {
      void onReady() {
        if (!mounted || _navigated) {
          app.removeListener(onReady);
          return;
        }
        if (app.initialized) {
          app.removeListener(onReady);
          _goNext(app);
        }
      }

      app.addListener(onReady);
    }
  }

  void _goNext(AppController app) {
    if (!mounted || _navigated) return;
    _navigated = true;
    final next = app.profile.onboardingDone
        ? const MainShell()
        : const OnboardingFlow();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => next,
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                ScaleTransition(
                  scale: CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: AppColors.cardBorder, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coral.withValues(alpha: 0.2),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.asset('assets/images/mascots/app_icon.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Drawing Together Neon',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 30,
                        color: AppColors.ink,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  app.t('draw together, anywhere'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.inkMuted,
                        fontSize: 16,
                      ),
                ),
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, _) => Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: _anim.value,
                          minHeight: 10,
                          backgroundColor: AppColors.cardBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.coral),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        app.t('warming up the crayons...'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
