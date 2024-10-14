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

    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    var nextPlayer = players[currentPlayerIndex];
    nextPlayer.isCurrentTurn = true;
    nextPlayer.enableDice = true;

    for (var token in currentPlayer.tokens) {
      token.enableToken = false;
    }

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
}
