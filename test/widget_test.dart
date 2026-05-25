// This is a placeholder test file for Yangon Taxi Driver App
// TODO: Add proper widget tests

import 'package:flutter_test/flutter_test.dart';
import 'package:yangon_taxi_driver/main.dart' as app;

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const app.YangonTaxiDriverApp());

    // Verify the app starts
    expect(find.text('Yangon Taxi Driver'), findsOneWidget);
  });
}
