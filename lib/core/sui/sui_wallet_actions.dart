import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rental_mgr_mobile/core/sui/sui_web_links.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWebSuiSend(BuildContext context) async {
  final open = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Send SUI'),
      content: const Text(
        'Outgoing Sui transfers are signed in the web wallet. Open the secure web pay page to send or pay rent with SUI?',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Open web wallet')),
      ],
    ),
  );
  if (open != true || !context.mounted) return;

  final uri = Uri.parse(kWebSuiPayUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opened web wallet for Sui signing.'), behavior: SnackBarBehavior.floating),
      );
    }
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open browser. Visit $kWebSuiPayUrl'), behavior: SnackBarBehavior.floating),
    );
  }
}

Future<void> showSuiReceiveSheet(BuildContext context, {required String? address}) async {
  final addr = address?.trim() ?? '';
  if (addr.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No Sui address yet. Open the web app once to provision your wallet.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF0F1419),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) {
      final qrUrl =
          'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${Uri.encodeComponent(addr)}';
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Receive SUI', style: AppTextStyles.headingSmallOnDark),
            const SizedBox(height: 12),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(qrUrl, width: 180, height: 180, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text('Your address', style: AppTextStyles.caption.copyWith(color: Colors.white54)),
            const SizedBox(height: 6),
            SelectableText(addr, style: AppTextStyles.bodySmallOnDark.copyWith(fontFamily: 'monospace')),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: addr));
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Address copied.'), behavior: SnackBarBehavior.floating),
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy address'),
            ),
          ],
        ),
      );
    },
  );
}
