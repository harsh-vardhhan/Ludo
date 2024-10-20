import 'package:flame/components.dart';

import 'player.dart';
import 'event_bus.dart';

class GameState {
  // Private constructor
  GameState._();

  // Singleton instance
  static final GameState _instance = GameState._();

  List<int> diceChances =
      List.filled(3, 0, growable: false); // Track consecutive 6s
  var diceNumber = 5;

  List<Player> players = [];
  int currentPlayerIndex = 0;

  bool canMoveTokenFromBase = false;
  bool canMoveTokenOnBoard = false;

  Vector2 ludoBoardAbsolutePosition = Vector2.zero();

  // Factory method to access the instance
  factory GameState() {
    return _instance;
  }

  void enableMoveFromBase() {
    canMoveTokenFromBase = true;
    canMoveTokenOnBoard = false;
  }

  void enableMoveOnBoard() {
    canMoveTokenFromBase = false;
    canMoveTokenOnBoard = true;
  }

  void enableMoveFromBoth() {
    canMoveTokenFromBase = true;
    canMoveTokenOnBoard = true;
  }

  void resetTokenMovement() {
    canMoveTokenFromBase = false;
    canMoveTokenOnBoard = false;
  }

  void switchToNextPlayer() {
    var current = currentPlayer;
    current.isCurrentTurn = false;
    current.enableDice = false;
    current.resetExtraTurns();

    // Loop to find the next player who hasn't won
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } while (players[currentPlayerIndex].hasWon);

    var nextPlayer = players[currentPlayerIndex];
    nextPlayer.isCurrentTurn = true;
    nextPlayer.enableDice = true;

    // Disable tokens of the current player
    for (var token in currentPlayer.tokens) {
      token.enableToken = false;
    }

    // Emit events based on the next player's ID
    switch (nextPlayer.playerId) {
      case 'GP':
        EventBus().emit(BlinkGreenBaseEvent());
        break;
      case 'BP':
        EventBus().emit(BlinkBlueBaseEvent());
        break;
      case 'RP':
        EventBus().emit(BlinkRedBaseEvent());
        break;
      case 'YP':
        EventBus().emit(BlinkYellowBaseEvent());
        break;
    }
  }

  // Get the current player
  Player get currentPlayer => players[currentPlayerIndex];

  Future<void> clearPlayers() async {
    players.clear();
    currentPlayerIndex = 0;
    diceNumber = 5;
    resetTokenMovement();
    return Future.value();
  }
}
