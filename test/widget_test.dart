import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:draw_together/data/repositories/app_repository.dart';
import 'package:draw_together/data/services/lesson_service.dart';
import 'package:draw_together/data/services/loc_service.dart';
import 'package:draw_together/data/services/storage_service.dart';
import 'package:draw_together/main.dart';
import 'package:draw_together/ui/core/app_state.dart';

void main() {
  testWidgets('DrawTogetherApp loads all 111 lessons and transitions from splash', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(
      repository: AppRepository(
        locService: LocService(),
        lessonService: LessonService(),
        storageService: StorageService(),
      ),
    );
    await controller.init();
    expect(controller.lessons.length, 111);

    await tester.pumpWidget(DrawTogetherApp(controller: controller));
    expect(find.text('Drawing Together Neon'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.text('Pick a language'), findsOneWidget);
  });
}
