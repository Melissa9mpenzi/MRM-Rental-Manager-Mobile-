/// Compact UGX display for dashboards (no decimals).
String formatUgx(num? amount) {
  final v = (amount ?? 0).round();
  final neg = v < 0;
  final s = v.abs().toString();
  final rev = s.split('').reversed.join();
  final buf = StringBuffer();
  for (var i = 0; i < rev.length; i++) {
    if (i > 0 && i % 3 == 0) buf.write(',');
    buf.write(rev[i]);
  }
  final core = buf.toString().split('').reversed.join();
  return neg ? '-UGX $core' : 'UGX $core';
}

String firstNameOrFallback(String fullName, {String fallback = 'there'}) {
  final t = fullName.trim();
  if (t.isEmpty) return fallback;
  return t.split(RegExp(r'\s+')).first;
}
