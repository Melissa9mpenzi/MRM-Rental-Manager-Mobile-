import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:rental_mgr_mobile/core/routing/route_names.dart';

import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

import 'package:rental_mgr_mobile/core/widgets/settings_panel.dart';

import 'package:rental_mgr_mobile/features/auth/server_settings_sheet.dart';



class SettingsScreen extends ConsumerWidget {

  const SettingsScreen({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

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

                  'CONFIGURATION',

                  style: AppTextStyles.caption.copyWith(

                    color: Colors.white38,

                    letterSpacing: 1.2,

                    fontWeight: FontWeight.w700,

                    fontSize: 10,

                  ),

                ),

                const SizedBox(height: 6),

                Text(

                  'Account & system',

                  style: AppTextStyles.headingSmallOnDark.copyWith(fontWeight: FontWeight.w800),

                ),

                const SizedBox(height: 4),

                Text(

                  'Profile, payments, and listings sync from your live RentDirect account.',

                  style: AppTextStyles.caption.copyWith(color: Colors.white54, height: 1.45),

                ),

              ],

            ),

          ),

          const SizedBox(height: 12),

          SettingsSectionPanel(

            title: 'Account',

            subtitle: 'Identity and profile data from the API.',

            badge: const SettingsStatusChip(label: 'Live sync', ok: true),

            child: Column(

              children: [

                const SettingsFieldRow(label: 'Data source', value: 'RentDirect API'),

                const SettingsFieldRow(label: 'Profile editor', value: 'Profile screen'),

                SettingsNavTile(

                  icon: Icons.person_outline_rounded,

                  title: 'Open profile',

                  subtitle: 'Name, phone, and role details',

                  onTap: () => context.push(RouteNames.profile),

                ),

              ],

            ),

          ),

          const SizedBox(height: 12),

          SettingsSectionPanel(

            title: 'Connectivity',

            subtitle: 'API host used by this device.',

            accent: const Color(0xFF22D3EE),

            child: Column(

              children: [

                const SettingsFieldRow(label: 'Environment', value: 'Configurable'),

                SettingsNavTile(

                  icon: Icons.dns_outlined,

                  title: 'Server settings',

                  subtitle: 'API URL for dev, staging, or production',

                  onTap: () => showServerSettingsSheet(context, ref),

                ),

              ],

            ),

          ),

          const SizedBox(height: 12),

          SettingsSectionPanel(

            title: 'Payments & Sui',

            subtitle: 'Hybrid fiat and on-chain rent settlement.',

            accent: const Color(0xFFA78BFA),

            child: Column(

              children: [

                const SettingsFieldRow(label: 'MoMo / Airtel', value: 'In-app checkout'),

                const SettingsFieldRow(label: 'Sui signing', value: 'Web wallet bridge'),

                SettingsNavTile(

                  icon: Icons.account_balance_wallet_outlined,

                  title: 'Sui wallet',

                  subtitle: 'Balance, receive address, send via web',

                  onTap: () => context.push(RouteNames.suiWallet),

                ),

              ],

            ),

          ),

          const SizedBox(height: 12),

          SettingsSectionPanel(

            title: 'Preferences',

            subtitle: 'Features not yet available on mobile.',

            accent: const Color(0xFFF59E0B),

            badge: const SettingsStatusChip(label: 'Roadmap', ok: false),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SettingsFieldRow(label: 'Biometric login', value: 'Not available'),

                const SettingsFieldRow(label: 'Push notifications', value: 'Not available'),

                const SizedBox(height: 4),

                Text(

                  'Use the web app for full security settings including two-factor authentication and data export.',

                  style: AppTextStyles.caption.copyWith(color: Colors.white54, height: 1.45),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}


