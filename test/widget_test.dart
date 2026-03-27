import 'package:flutter_test/flutter_test.dart';
import 'package:calllog_exporter/main.dart';

void main() {
  testWidgets('Call Log Exporter smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CallLogExporterApp());

    // Verify that our app title is displayed.
    expect(find.text('Call Log Exporter'), findsAtLeastNWidgets(1));

    // Verify that load button exists.
    expect(find.text('Load Call Logs'), findsOneWidget);

    // Verify that export button exists.
    expect(find.text('Export CSV'), findsOneWidget);
  });
}
