import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/main.dart';

void main() {
  testWidgets('Lobby screen renders successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the select number of players text is displayed
    expect(find.text('Select Number of Players'), findsOneWidget);
  });
}
