import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ludo/main.dart';
import 'package:ludo/managers/game_state.dart';
import 'package:ludo/managers/token_manager.dart';
import 'package:ludo/models/player.dart';
import 'package:ludo/models/player_team.dart';
import 'package:ludo/models/token.dart';
import 'package:ludo/models/ludo_game_state.dart';
import 'package:ludo/ludo.dart';
import 'package:flame/components.dart';

class MockLudo extends Ludo {
  MockLudo(BuildContext context) : super([PlayerTeam.blue], context);

  @override
  void switchOffPointer() {
    // No-op for test
  }

  @override
  void blinkBaseForTeam(PlayerTeam team) {
    // No-op for test
  }
}

void main() {
  testWidgets('Lobby screen renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('LUDO ZONE'), findsOneWidget);
  });

  testWidgets('Rolling 6 with 1 token on board and 3 in base should require manual selection', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final gameState = GameState();
              gameState.game = MockLudo(context);
              return Container();
            },
          ),
        ),
      ),
    );

    final gameState = GameState();
    await gameState.clearPlayers();
    await TokenManager().clearTokens();

    TokenManager().initializeTokens(TokenManager().blueTokensBase);
    final blueTokens = TokenManager().getBlueTokens();

    expect(blueTokens.length, 4);

    final bluePlayer = Player(
      playerId: PlayerTeam.blue,
      tokens: blueTokens,
    );

    gameState.players = [bluePlayer];
    gameState.currentPlayerIndex = 0;

    for (var token in blueTokens) {
      token.state = TokenState.inBase;
    }

    // Mimic one token already opened and on board
    blueTokens[0].state = TokenState.onBoard;
    blueTokens[0].positionId = 'B04'; // Starting spot for blue

    // Now 1 token is onBoard, 3 in base
    expect(bluePlayer.tokens.where((t) => t.state == TokenState.inBase).length, 3);
    expect(bluePlayer.tokens.where((t) => t.state == TokenState.onBoard).length, 1);

    // Roll a 6
    gameState.state = LudoGameState.needRoll;
    gameState.rollDice();
    gameState.diceNumber = 6;

    // Resolve dice roll
    final world = World();
    gameState.resolveDiceRoll(world);

    // Assert that we transition to needMove (manual selection) and NOT moving (automated move)
    expect(gameState.state, LudoGameState.needMove);
  });
}
