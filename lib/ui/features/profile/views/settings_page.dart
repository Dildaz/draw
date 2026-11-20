import 'package:flutter/material.dart';
import '../../../../data/services/loc_service.dart';
import '../../../core/app_state.dart';
import '../../../core/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final p = app.profile;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: Text(app.t('Settings'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionCard([
            ListTile(
              leading: const Icon(Icons.language_rounded, color: AppColors.sky),
              title: Text(app.t('Language'), style: const TextStyle(fontWeight: FontWeight.w800)),
              trailing: DropdownButton<String>(
                value: app.language,
                underline: const SizedBox.shrink(),
                items: kSupportedLanguages
                    .map((l) => DropdownMenuItem(value: l.code, child: Text(l.nativeName)))
                    .toList(),
                onChanged: (code) {
                  if (code != null) app.setLanguage(code);
                },
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_rounded, color: AppColors.coral),
              title: Text(app.t('Sound effects'), style: const TextStyle(fontWeight: FontWeight.w800)),
              value: p.soundEnabled,
              activeThumbColor: AppColors.coral,
              onChanged: (v) => app.updateProfile(p.copyWith(soundEnabled: v)),
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.vibration_rounded, color: AppColors.purple),
              title: Text(app.t('Vibrate'), style: const TextStyle(fontWeight: FontWeight.w800)),
              value: p.vibrateEnabled,
              activeThumbColor: AppColors.coral,
              onChanged: (v) => app.updateProfile(p.copyWith(vibrateEnabled: v)),
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_rounded, color: AppColors.amberDark),
              title: Text(app.t('Notifications'), style: const TextStyle(fontWeight: FontWeight.w800)),
              value: p.notificationsEnabled,
              activeThumbColor: AppColors.coral,
              onChanged: (v) => app.updateProfile(p.copyWith(notificationsEnabled: v)),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionCard([
            ListTile(
              leading: const Icon(Icons.star_rounded, color: AppColors.amberDark),
              title: Text(app.t('Rate us'), style: const TextStyle(fontWeight: FontWeight.w800)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
              onTap: () async {
                final opened = await app.reviewService.openStoreListing();
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(app.t('Thank you! Store rating opens after launch'))),
                  );
                }
              },
            ),
            if (app.adService.isPrivacyOptionsRequired) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_rounded, color: AppColors.sky),
                title: Text(app.t('Privacy policy'), style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Manage ad consent'),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
                onTap: () => app.adService.showPrivacyOptionsForm(),
              ),
            ],
          ]),
          const SizedBox(height: 20),
          Center(
            child: Text(
              app.t('You have the latest version ({0})', ['1.0']),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Column(children: children),
    );
  }
}
