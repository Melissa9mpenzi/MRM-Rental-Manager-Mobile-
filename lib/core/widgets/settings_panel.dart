import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

class SettingsSectionPanel extends StatelessWidget {
  const SettingsSectionPanel({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    required this.child,
    this.accent,
  });

  final String title;
  final String? subtitle;
  final Widget? badge;
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent ?? AppColors.primary;
    return GlassPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(color: accentColor.withValues(alpha: 0.7), width: 3)),
              color: AppColors.pageBg,
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(title,
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w700)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle!,
                            style: AppTextStyles.caption.copyWith(height: 1.4)),
                      ],
                    ],
                  ),
                ),
                if (badge != null) badge!,
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class SettingsStatusChip extends StatelessWidget {
  const SettingsStatusChip({super.key, required this.label, this.ok = true});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.success : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 9,
                letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

class SettingsFieldRow extends StatelessWidget {
  const SettingsFieldRow(
      {super.key,
      required this.label,
      required this.value,
      this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                  fontSize: 10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: (mono ? AppTextStyles.caption : AppTextStyles.bodyMedium)
                  .copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: mono ? 'monospace' : null,
                fontSize: mono ? 11 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsNavTile extends StatelessWidget {
  const SettingsNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
