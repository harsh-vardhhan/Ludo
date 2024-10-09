import '../component/ui_components/token.dart';

class Player {
  String playerId;
  List<Token> tokens; // Tokens belonging to the player
  bool isActive; // Is the player still active in the game?
  bool isCurrentTurn; // Is it the player's turn right now?
  int score; // Player's current score
  int totalTokensInHome; // Number of tokens in the home position
  bool hasWon; // Has the player won the game?
  int extraTurns; // Count of extra turns granted
  bool enableDice;
  bool enableToken;

  // Constructor to initialize the player's attributes
  Player({
    required this.playerId,
    required this.tokens,
    this.isActive = true, // Default: player is active when initialized
    this.isCurrentTurn = false, // Default: not the player's turn initially
    this.score = 0, // Default: score starts at 0
    this.totalTokensInHome = 0, // Default: no tokens in home initially
    this.hasWon = false, // Default: player hasn't won yet
    this.extraTurns = 0,
    this.enableDice = false, // Default to 0 extra turns
    this.enableToken = false,
  });

  // Helper method to check if all tokens are in base
  bool allTokensInBase() {
    return tokens.every((token) => token.isInBase());
  }

  // Helper method to get the tokens that are on the board
  List<Token> getTokensOnBoard() {
    _cachedTokensOnBoard ??= tokens.where((token) => token.isOnBoard()).toList();
    return _cachedTokensOnBoard!;
  }

  // Helper method to check if only one token is on the board
  bool hasOneTokenOnBoard() {
    return getTokensOnBoard().length == 1;
  }

  // Helper method to check if there are multiple tokens on the board
  bool hasMultipleTokensOnBoard() {
    return getTokensOnBoard().length > 1;
  }

  // Method to reset extra turns (including after three consecutive sixes)
  void resetExtraTurns() {
    extraTurns = 0;
    _cachedTokensOnBoard = null; // Invalidate cache if tokens state changes
  }

  // Method to grant another turn (includes handling six rolls)
  void grantAnotherTurn() {
    extraTurns++; // Increment the count of extra turns
  }

  // Method to check if three consecutive sixes were rolled
  bool hasRolledThreeConsecutiveSixes() {
    return extraTurns == 3; // Three consecutive turns would mean 3 sixes
  }

  List<Token>? _cachedTokensOnBoard; // Define the variable
}
