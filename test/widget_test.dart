import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/main.dart';

void main() {
  testWidgets('App shows RentDirect branding', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RentalMgrApp()));
    await tester.pump();
    expect(find.text('RentDirect UG'), findsWidgets);
  });
}
