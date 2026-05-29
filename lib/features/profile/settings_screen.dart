import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_theme_extension.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/theme_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometric = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.rdTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Light, dark, or match your phone (system).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.rdTheme.textMuted),
                ),
                const SizedBox(height: 16),
                const ThemeSelector(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Biometric login'),
                  value: _biometric,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (v) => setState(() => _biometric = v),
                ),
                SwitchListTile(
                  title: const Text('Push notifications'),
                  value: _notifications,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
