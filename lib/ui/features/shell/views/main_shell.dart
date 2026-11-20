import 'package:flutter/material.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/ad_banner_slot.dart';
import '../../friends/views/friends_page.dart';
import '../../home/views/home_page.dart';
import '../../learn/views/learn_page.dart';
import '../../profile/views/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = [
    HomePage(),
    LearnPage(),
    FriendsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: IndexedStack(index: _index, children: _pages)),
          const AdBannerSlot(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1.5)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _tabItem(0, Icons.home_rounded, app.t('Home')),
                _tabItem(1, Icons.menu_book_rounded, app.t('Learn')),
                _tabItem(2, Icons.people_rounded, app.t('Buddies')),
                _tabItem(3, Icons.person_rounded, app.t('Me')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabItem(int idx, IconData icon, String label) {
    final active = _index == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _index = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.coral.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: active ? AppColors.coral : AppColors.inkMuted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: active ? AppColors.coral : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
