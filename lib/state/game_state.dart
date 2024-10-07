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
    currentPlayer.isCurrentTurn = false;
    currentPlayer.enableDice = false;
    currentPlayer.enableToken = false;

    currentPlayer.resetExtraTurns(); // Reset extra turns when switching turns
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;

    players[currentPlayerIndex].isCurrentTurn = true;
    players[currentPlayerIndex].enableDice = true;

    if (players[currentPlayerIndex].playerId == 'GP') {
      EventBus().emit(BlinkGreenBaseEvent());
    } else if (players[currentPlayerIndex].playerId == 'BP') {
      EventBus().emit(BlinkBlueBaseEvent());
    }
  }

  // Get the current player
  Player get currentPlayer => players[currentPlayerIndex];
}
