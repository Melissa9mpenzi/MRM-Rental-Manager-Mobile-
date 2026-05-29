import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

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
              children: [
                SwitchListTile(
                  title: Text('Biometric login', style: AppTextStyles.bodyMediumOnDark),
                  value: _biometric,
                  activeColor: AppColors.accentGreen,
                  onChanged: (v) => setState(() => _biometric = v),
                ),
                SwitchListTile(
                  title: Text('Push notifications', style: AppTextStyles.bodyMediumOnDark),
                  value: _notifications,
                  activeColor: AppColors.accentGreen,
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
