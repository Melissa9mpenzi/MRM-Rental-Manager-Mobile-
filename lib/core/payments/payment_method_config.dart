/// Backend `PaymentMethod` values — no cash.
enum AppPaymentMethod {
  mtnMomo('mtn_momo', 'MTN MoMo', 'mtn'),
  airtel('airtel', 'Airtel Money', 'airtel'),
  pesapal('pesapal', 'Card / Pesapal', 'visa'),
  bank('bank', 'Bank transfer', 'bank'),
  sui('sui', 'Sui Wallet', 'sui');

  const AppPaymentMethod(this.apiValue, this.label, this.logoAsset);

  final String apiValue;
  final String label;
  final String logoAsset;

  static const String logoBase = 'assets/icons/payments';

  String get logoPath => '$logoBase/$logoAsset.svg';

  static AppPaymentMethod? fromApi(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final k = raw.toLowerCase().replaceAll('-', '_');
    for (final m in AppPaymentMethod.values) {
      if (m.apiValue == k || m.name == k) return m;
    }
    return switch (k) {
      'mtn' || 'momo_mtn' || 'mobile_money' => AppPaymentMethod.mtnMomo,
      'momo_airtel' => AppPaymentMethod.airtel,
      'bank_transfer' => AppPaymentMethod.bank,
      'card' || 'visa' || 'mastercard' || 'other' => AppPaymentMethod.pesapal,
      'cash' => null,
      _ => AppPaymentMethod.mtnMomo,
    };
  }

  /// Tenant checkout: MoMo, Airtel, Pesapal, Sui.
  static const tenantCheckout = [
    AppPaymentMethod.mtnMomo,
    AppPaymentMethod.airtel,
    AppPaymentMethod.pesapal,
    AppPaymentMethod.sui,
  ];

  /// Landlord record-payment options.
  static const recordPayment = [
    AppPaymentMethod.mtnMomo,
    AppPaymentMethod.airtel,
    AppPaymentMethod.pesapal,
    AppPaymentMethod.bank,
    AppPaymentMethod.sui,
  ];
}

String paymentMethodLabelFromApi(String? raw) {
  return AppPaymentMethod.fromApi(raw)?.label ??
      (raw?.replaceAll('_', ' ').trim().isEmpty ?? true ? '—' : raw!.replaceAll('_', ' '));
}
