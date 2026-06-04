import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_error.dart';
import 'package:rental_mgr_mobile/core/api/payments_api.dart';
import 'package:rental_mgr_mobile/core/payments/payment_method_config.dart';
import 'package:rental_mgr_mobile/core/widgets/payment_method_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rental_mgr_mobile/core/sui/sui_web_links.dart';

String apiMethodFromApp(AppPaymentMethod method) {
  return switch (method) {
    AppPaymentMethod.mtnMomo => 'mtn_momo',
    AppPaymentMethod.airtel => 'airtel',
    AppPaymentMethod.pesapal => 'pesapal',
    AppPaymentMethod.sui => 'sui',
    AppPaymentMethod.bank => 'bank',
  };
}

Future<void> runTenantCheckoutFlow({
  required WidgetRef ref,
  required BuildContext context,
  required Map<String, dynamic> invoice,
  String? defaultPhone,
}) async {
  final api = ref.read(paymentsApiProvider);

  try {
    final gw = await api.gatewayStatus();
    if (gw['mock_enabled'] == true) {
      _snack(context, 'Server is in mock mode. Configure MTN MoMo or Pesapal on the API.');
      return;
    }
    if (gw['configured'] != true) {
      _snack(
        context,
        'Payments not configured. Add MTN MoMo or Pesapal keys on the API server.',
      );
      return;
    }
  } catch (e) {
    _snack(context, apiErrorMessage(e, 'Could not reach payment service.'));
    return;
  }

  final method = await showPaymentMethodSheet(context);
  if (method == null || !context.mounted) return;

  try {
    final gw = await ref.read(paymentsApiProvider).gatewayStatus();
    final supports = gw['supports'] as Map<String, dynamic>? ?? {};
    final methodApi = apiMethodFromApp(method);
    if (methodApi == 'sui') {
      await _openWebSuiPay(context);
      return;
    }
    if (methodApi == 'airtel' && supports['airtel'] != true) {
      _snack(context, 'Airtel needs Pesapal on the server. Use MTN MoMo or ask your landlord.');
      return;
    }
  } catch (_) {
    /* proceed if status check fails */
  }

  final phoneCtrl = TextEditingController(text: defaultPhone ?? '');
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Pay with ${method.label}'),
      content: TextField(
        controller: phoneCtrl,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Phone (256…)',
          hintText: '256700000000',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
      ],
    ),
  );
  final phone = phoneCtrl.text.trim();
  phoneCtrl.dispose();
  if (confirmed != true || !context.mounted) return;

  final invoiceId = (invoice['id'] as num?)?.toInt();
  if (invoiceId == null) {
    _snack(context, 'Invalid invoice.');
    return;
  }

  try {
    final checkout = await api.initiateCheckout(
      invoiceId: invoiceId,
      paymentMethod: apiMethodFromApp(method),
      phone: phone,
    );
    if (!context.mounted) return;

    final reference = checkout['reference'] as String? ?? '';
    final next = checkout['next_action'] as Map<String, dynamic>? ?? {};
    final link = next['payment_link'] as String?;

    if (link != null && link.isNotEmpty) {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      _snack(context, 'Complete payment on the secure page (MTN, Airtel, or card).', long: true);
    } else {
      final msg = next['message'] as String? ??
          'Check your MTN phone and approve the MoMo prompt.';
      _snack(context, msg, long: true);
    }

    if (reference.isEmpty) return;

    for (var i = 0; i < 40; i++) {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (!context.mounted) return;
      final status = await api.getCheckout(reference);
      final st = '${status['status'] ?? ''}'.toLowerCase();
      if (st == 'completed') {
        _snack(context, 'Payment confirmed and recorded.');
        return;
      }
      if (st == 'failed') {
        _snack(context, status['failure_reason']?.toString() ?? 'Payment failed.');
        return;
      }
    }
    if (context.mounted) {
      _snack(context, 'Still processing. Check Wallet shortly.');
    }
  } catch (e) {
    if (!context.mounted) return;
    _snack(context, apiErrorMessage(e, 'Could not start payment.'));
  }
}

void _snack(BuildContext context, String msg, {bool long = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      duration: Duration(seconds: long ? 6 : 4),
    ),
  );
}

Future<void> _openWebSuiPay(BuildContext context) async {
  final open = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sui wallet payment'),
      content: const Text(
        'Sui wallet signing is currently available on the web app. Open the secure web pay page now?',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Open web pay')),
      ],
    ),
  );

  if (open != true || !context.mounted) return;

  final uri = Uri.parse(kWebSuiPayUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    _snack(context, 'Opened web pay page for Sui wallet checkout.');
  } else {
    _snack(context, 'Could not open web pay page. Open $kWebSuiPayUrl manually.');
  }
}
