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

  Color topColor;
  Color sideColor;
  bool _shouldDrawCircle = false; // Flag to control circle rendering

  Token({
    required this.tokenId, // Mandatory unique ID for the token
    required this.positionId, // Mandatory position ID for the token
    required Vector2 position, // Initial position of the token
    required Vector2 size, // Size of the token
    required this.playerId, // Initialize playerId
    this.enableToken = false, // Initialize enableToken
    this.state = TokenState.inBase, // Default state
    required this.topColor,
    required this.sideColor,
  }) : super(position: position, size: size);

  bool isInBase() => state == TokenState.inBase;
  bool isOnBoard() => state == TokenState.onBoard;
  bool isInHome() => state == TokenState.inHome;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Define the radius of the outer circle
    final outerRadius = size.x / 2;
    final sideOuterRadius = size.x / 1.9;

    // Define the radius of the smaller inner circle
    final smallerCircle = outerRadius / 2.5; // Radius of the smaller circle
    final smallerCircleDepth = smallerCircle * 0.90;

    // Define the center of the circles
    final center = Offset(size.x / 2, size.y / 2);
    final centerShadow = Offset(size.x / 2, size.y / 1.70);
    final tokenShadow = Offset(size.x / 2, size.y / 1.5);
    final smallerCircleShadow = Offset(size.x / 2, size.y / 1.75);

    canvas.drawCircle(tokenShadow, outerRadius,
        Paint()..color = const Color(0xFF3C3D37).withOpacity(0.6));
    canvas.drawCircle(centerShadow, sideOuterRadius,
        Paint()..color = sideColor); // Draw outer circle

    canvas.drawCircle(
        center, outerRadius, Paint()..color = topColor); // Draw border

    canvas.drawCircle(smallerCircleShadow, smallerCircleDepth,
        Paint()..color = const Color(0xFF3C3D37).withOpacity(0.7));
    canvas.drawCircle(center, smallerCircle, Paint()..color = Colors.white);

    // Conditionally render the circle around the token
    if (_shouldDrawCircle) {
      _renderCircleAroundToken(canvas);
    }
  }

  void _renderCircleAroundToken(Canvas canvas) {
    // Radius for the outer circle surrounding the token
    final surroundingCircleRadius =
        size.x / 2 * 2; // Slightly larger than the token

    // Center position of the circle
    final center = Offset(size.x / 2, size.y / 2);

    // Circle's paint style
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5) // Blue color with transparency
      ..style = PaintingStyle.stroke // Stroke for an outline
      ..strokeWidth = 3.0; // Thickness of the circle outline

    // Draw the circle around the token
    canvas.drawCircle(center, surroundingCircleRadius, paint);
  }

  // Public method to enable the circle rendering
  void drawCircleAroundToken() {
    _shouldDrawCircle = true;
  }

  // Public method to disable the circle rendering
  void hideCircleAroundToken() {
    _shouldDrawCircle = false;
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
      } else if (state == TokenState.onBoard &&
          GameState().canMoveTokenOnBoard) {
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
