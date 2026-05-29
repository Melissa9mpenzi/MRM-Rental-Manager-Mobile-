import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/theme/app_theme_extension.dart';
import 'package:rental_mgr_mobile/core/theme/theme_mode_provider.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themeModeProvider);
    final rd = context.rdTheme;

    Widget chip(AppThemePreference mode, String label, IconData icon) {
      final selected = preference == mode;
      return Expanded(
        child: Material(
          color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => ref.read(themeModeProvider.notifier).setPreference(mode),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : rd.textMuted, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? rd.textPrimary : rd.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(AppThemePreference.system, 'System', Icons.brightness_auto_rounded),
        const SizedBox(width: 8),
        chip(AppThemePreference.light, 'Light', Icons.light_mode_rounded),
        const SizedBox(width: 8),
        chip(AppThemePreference.dark, 'Dark', Icons.dark_mode_rounded),
      ],
    );
  }
}
