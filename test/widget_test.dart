import 'package:flutter_test/flutter_test.dart';
import 'package:morrowly/app/morrowly_app.dart';

void main() {
  testWidgets('Morrowly opens on tomorrow compass', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MorrowlyApp());
    await tester.pump();

    expect(find.text('Morrowly'), findsOneWidget);
    expect(find.text('Tomorrow commitments'), findsOneWidget);
  });
}
