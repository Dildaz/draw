import 'package:flutter/material.dart';
import '../../../../domain/models/lesson.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/lesson_card.dart';
import '../../drawing/views/preview_page.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  String _selectedCat = 'all';

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final soloLessons = app.lessons.where((l) => !l.isTwoPlayer).toList();
    final filtered = _selectedCat == 'all'
        ? soloLessons
        : soloLessons.where((l) => l.category == _selectedCat).toList();
    final pickOfDay = soloLessons.isNotEmpty
        ? soloLessons[DateTime.now().day % soloLessons.length]
        : null;
    final doneSet = app.profile.completedLessonIds.toSet();

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.t('Learn'),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
                    ),
                    Text(
                      app.t('Trace step by step at your own pace'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (pickOfDay != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PreviewPage(summary: pickOfDay)),
                    ),
                    child: Container(
                      height: 136,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/banners/banner_bg_2.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    app.t("TODAY'S PICK"),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  pickOfDay.titleFor(app.language),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  app.t('{0} steps', [pickOfDay.stepCount]),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 92,
                            height: 92,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Image.asset(pickOfDay.previewAsset, fit: BoxFit.contain),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 0, 12),
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: kLessonCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = kLessonCategories[i];
                      final selected = _selectedCat == cat.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCat = cat.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? cat.accentColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? cat.accentColor : AppColors.cardBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(cat.iconAsset, width: 20, height: 20),
                              const SizedBox(width: 6),
                              Text(
                                app.t(cat.labelKey),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: selected ? Colors.white : AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.84,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final lesson = filtered[index];
                    return LessonCard(
                      lesson: lesson,
                      language: app.language,
                      isCompleted: doneSet.contains(lesson.id),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PreviewPage(summary: lesson)),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
