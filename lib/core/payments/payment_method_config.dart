/// Backend `PaymentMethod` values: mtn_momo, airtel, cash, bank, other.
enum AppPaymentMethod {
  mtnMomo('mtn_momo', 'MTN MoMo', 'mtn'),
  airtel('airtel', 'Airtel Money', 'airtel'),
  visa('other', 'Visa / Card', 'visa'),
  bank('bank', 'Bank transfer', 'bank'),
  cash('cash', 'Cash', 'cash'),
  sui('other', 'Sui Wallet', 'sui'),
  other('other', 'Other', 'other');

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
      'bank_transfer' || 'card' => AppPaymentMethod.bank,
      _ => AppPaymentMethod.other,
    };
  }

  /// Tenant checkout: MoMo + Pesapal (card). Blockchain (sui) — phase 3.
  static const tenantCheckout = [
    AppPaymentMethod.mtnMomo,
    AppPaymentMethod.airtel,
    AppPaymentMethod.visa,
  ];

  /// Landlord record-payment options.
  static const recordPayment = [
    AppPaymentMethod.mtnMomo,
    AppPaymentMethod.airtel,
    AppPaymentMethod.cash,
    AppPaymentMethod.bank,
    AppPaymentMethod.other,
  ];
}

String paymentMethodLabelFromApi(String? raw) {
  return AppPaymentMethod.fromApi(raw)?.label ??
      (raw?.replaceAll('_', ' ').trim().isEmpty ?? true ? '—' : raw!.replaceAll('_', ' '));
}
