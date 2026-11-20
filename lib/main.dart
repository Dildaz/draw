import 'package:flutter/material.dart';
import 'data/repositories/app_repository.dart';
import 'data/services/lesson_service.dart';
import 'data/services/loc_service.dart';
import 'data/services/storage_service.dart';
import 'ui/core/app_state.dart';
import 'ui/core/app_theme.dart';
import 'ui/features/onboarding/views/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = AppRepository(
    locService: LocService(),
    lessonService: LessonService(),
    storageService: StorageService(),
  );
  final controller = AppController(repository: repo)..init();

  runApp(DrawTogetherApp(controller: controller));
}

class DrawTogetherApp extends StatelessWidget {
  const DrawTogetherApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      controller: controller,
      child: MaterialApp(
        title: 'Drawing Together Neon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const SplashPage(),
      ),
    );
  }
}
