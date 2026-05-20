import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = [
      ('English', '🇬🇧'),
      ('Kiswahili', '🇹🇿'),
      ('Luganda', '🇺🇬'),
      ('Acholi', ''),
      ('Lango', ''),
      ('Runyankole', ''),
      ('Ateso', ''),
    ];

    return AuthPageScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.canPop() ? context.pop() : context.go(RouteNames.login),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppColors.textOnDark,
                ),
              ],
            ),
            Text('Choose language', style: AppTextStyles.displayHero.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'App copy will follow your selection.',
              style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: languages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final (name, flag) = languages[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {},
                      child: GlassPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        borderRadius: 14,
                        child: Row(
                          children: [
                            if (flag.isNotEmpty)
                              Text(flag, style: const TextStyle(fontSize: 22))
                            else
                              const Icon(Icons.translate_rounded, color: AppColors.textMutedOnDark),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(name, style: AppTextStyles.bodyMediumOnDark),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedOnDark),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(RouteNames.login),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
