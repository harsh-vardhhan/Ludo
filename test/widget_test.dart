import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/main.dart'; // Import your main file
import 'package:ludo/ludo.dart'; // Import your game classes if required
import 'package:flame/game.dart'; // Required for game-related testing

void main() {
  // Test the FirstScreen widget
  testWidgets('FirstScreen displays correct buttons and navigates', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(home: FirstScreen()));

    // Verify the text and buttons appear correctly
    expect(find.text('Select Number of Players'), findsOneWidget);
    expect(find.text('2 player game'), findsOneWidget);
    expect(find.text('4 player game'), findsOneWidget);

    // Tap the 2 player button and verify navigation to SecondScreen
    await tester.tap(find.text('2 player game'));
    await tester.pumpAndSettle(); // Wait for animations and navigation
    expect(find.byType(SecondScreen), findsOneWidget);

    // Tap the 4 player button and verify navigation to GameApp
    await tester.tap(find.text('4 player game'));
    await tester.pumpAndSettle(); // Wait for animations and navigation
    expect(find.byType(GameApp), findsOneWidget);
  });

  // Test the SecondScreen widget
  testWidgets('SecondScreen renders player options correctly', (WidgetTester tester) async {
    // Build the widget with 2 players
    await tester.pumpWidget(const MaterialApp(home: SecondScreen(selectedPlayerCount: 2)));

    // Verify the Player 1 and Player 2 buttons appear correctly
    expect(find.text('Player 1'), findsNWidgets(2)); // Two Player 1 buttons for two teams
    expect(find.byType(ElevatedButton), findsNWidgets(2));

    // Tap one of the team buttons and verify navigation to GameApp
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(GameApp), findsOneWidget);
  });

  // Test the TokenDisplay widget
  testWidgets('TokenDisplay renders with correct color', (WidgetTester tester) async {
    // Build the widget with a specific color
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TokenDisplay(color: Colors.red))));

    // Verify the custom painter renders a red token
    final CustomPaint paint = tester.widget(find.byType(CustomPaint));
    final TokenPainter painter = paint.painter as TokenPainter;
    expect(painter.fillPaint.color, equals(Colors.red));
  });

  // Test the GameApp widget initialization
  testWidgets('GameApp initializes correctly', (WidgetTester tester) async {
    // Prepare the teams and render the GameApp widget
    await tester.pumpWidget(const MaterialApp(home: GameApp(selectedTeams: ['BP', 'GP'])));

    // Verify the game widget is initialized and rendering properly
    expect(find.byType(GameWidget), findsOneWidget);
    final GameWidget gameWidget = tester.widget(find.byType(GameWidget));
    expect(gameWidget.game, isA<Ludo>());
  });

  // Test the exit confirmation dialog
  testWidgets('Exit confirmation dialog appears on back button', (WidgetTester tester) async {
    // Build the GameApp widget
    await tester.pumpWidget(const MaterialApp(home: GameApp(selectedTeams: ['BP', 'GP'])));

    // Simulate the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify the exit confirmation dialog appears
    expect(find.text('Exit Game'), findsOneWidget);
    expect(find.text('Do you really want to exit the game?'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });
}
