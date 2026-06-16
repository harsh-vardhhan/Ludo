import 'player_team.dart';
import 'game_state.dart';

enum TokenState {
  inBase,
  onBoard,
  inHome,
}

class Token {
  final String tokenId; // Mandatory unique ID for the token
  PlayerTeam playerId; // Store only the player ID
  bool enableToken; // Store the enableToken state directly
  String positionId; // Mandatory position ID for the token
  TokenState state; // Current state of the token

  Token({
    required this.tokenId,
    required this.positionId,
    required this.playerId,
    this.enableToken = false,
    this.state = TokenState.inBase,
  });

  bool isInBase() => state == TokenState.inBase;
  bool isOnBoard() => state == TokenState.onBoard;
  bool isInHome() => state == TokenState.inHome;

  bool spaceToMove() {
    final tokenPath = GameState().getTokenPath(playerId);
    final index = tokenPath.indexOf(positionId);
    final newIndex = index + GameState().diceNumber;

    return newIndex < tokenPath.length;
  }
}
