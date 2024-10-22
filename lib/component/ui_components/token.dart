import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../state/game_state.dart';
import '../../ludo.dart';

// Enum to define token states
enum TokenState {
  inBase,
  onBoard,
  inHome,
}

class Token extends PositionComponent with TapCallbacks {
  final String tokenId; // Mandatory unique ID for the token
  String playerId; // Store only the player ID
  bool enableToken; // Store the enableToken state directly
  String positionId; // Mandatory position ID for the token
  TokenState state; // Current state of the token
  // final gameState = GameState();

  final Paint borderPaint; // Paint for the token's border
  final Paint fillPaint; // Paint for filling the token
  final Paint dropletFillPaint; // Paint for filling the droplet

  Token({
    required this.tokenId, // Mandatory unique ID for the token
    required this.positionId, // Mandatory position ID for the token
    required Vector2 position, // Initial position of the token
    required Vector2 size, // Size of the token
    required Color innerCircleColor, // Mandatory inner fill color
    required this.playerId, // Initialize playerId
    this.enableToken = false, // Initialize enableToken
    Color borderColor = Colors.black, // Default border color
    Color dropletFillColor = Colors.white, // Default droplet fill color
    this.state = TokenState.inBase, // Default state
  })  : borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.04
          ..color = borderColor,
        fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = innerCircleColor,
        dropletFillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = dropletFillColor,
        super(position: position, size: size);

  bool isInBase() => state == TokenState.inBase;
  bool isOnBoard() => state == TokenState.onBoard;
  bool isInHome() => state == TokenState.inHome;

  // Setter for innerCircleColor, updates the fillPaint color
  set innerCircleColor(Color color) {
    fillPaint.color = color; // Update the paint color when the color changes
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Define the radius of the outer circle
    final outerRadius = size.x / 2;
    // Define the radius of the smaller inner circle
    final smallerCircleRadius =
        outerRadius / 1.7; // Radius of the smaller circle

    // Define the center of the circles
    final center = Offset(size.x / 2, size.y / 2);

    // Draw the outer circle with white fill
    canvas.drawCircle(center, outerRadius,
        Paint()..color = Colors.white); // Draw outer circle
    canvas.drawCircle(center, outerRadius, borderPaint); // Draw border

    // Draw the smaller inner circle with the specified innerCircleColor
    canvas.drawCircle(center, smallerCircleRadius, fillPaint);
  }

  @override
  void onTapDown(TapDownEvent event) async {
    super.onTapDown(event);

    final world = parent?.parent;

    if (!spaceToMove() ||
        !enableToken ||
        world is! World ||
        (isInBase() && GameState().diceNumber != 6) ||
        isInHome()) return;

    enableToken = false;

    if (GameState().currentPlayer.playerId != playerId) return;

    if (GameState().diceNumber == 6) {
      // Handle movement logic
      if (state == TokenState.inBase && GameState().canMoveTokenFromBase) {
        moveOutOfBase(
            world: world,
            token: this,
            tokenPath: GameState().getTokenPath(playerId));
        // Consider reducing delay or making it conditional
      } else if (state == TokenState.onBoard && GameState().canMoveTokenOnBoard) {
        moveForward(
            world: world,
            token: this,
            tokenPath: GameState().getTokenPath(playerId),
            diceNumber: GameState().diceNumber);
      }
      return;
    }

    // Non-six logic
    if (state == TokenState.onBoard && GameState().canMoveTokenOnBoard) {
       moveForward(
          world: world,
          token: this,
          tokenPath: GameState().getTokenPath(playerId),
          diceNumber: GameState().diceNumber);
    }
  }

  bool spaceToMove() {
    final tokenPath = GameState().getTokenPath(playerId);
    final index = tokenPath.indexOf(positionId);
    final newIndex = index + GameState().diceNumber;

    return newIndex < tokenPath.length;
  }
}
