import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../state/game_state.dart';
import '../../ludo_board.dart';
import '../../state/token_path.dart';
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
  final gameState = GameState();

  final Paint borderPaint; // Paint for the token's border
  final Paint transparentPaint; // Paint for transparent areas
  final Paint fillPaint; // Paint for filling the token
  final Paint dropletFillPaint; // Paint for filling the inside of the droplet


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
  })  :
        borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.04
          ..color = borderColor,
        transparentPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = Colors.transparent, // Transparent line
        fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = innerCircleColor, // Use the passed innerCircleColor
        dropletFillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = dropletFillColor, // Paint for filling droplet
        super(position: position, size: size);

  bool isInBase() => state == TokenState.inBase;
  bool isOnBoard() => state == TokenState.onBoard;
  bool isInHome() => state == TokenState.inHome;

  // Setter for innerCircleColor, updates the fillPaint color
  set innerCircleColor(Color color) {
    fillPaint.color = color; // Update the paint color when the color changes
  }

  @override
  Future<void> onTapDown(TapDownEvent event) async {
    super.onTapDown(event);

    final world = parent?.parent;

    if (!spaceToMove() || !enableToken || world is! World) return;

    enableToken = false;
    final ludoBoard = world.children.whereType<LudoBoard>().first;

    if (gameState.currentPlayer.playerId != playerId) return;

    if (gameState.diceNumber == 6) {
      // Handle movement logic
      if (state == TokenState.inBase && gameState.canMoveTokenFromBase) {
        moveOutOfBase(
            world: world,
            token: this,
            tokenPath: getTokenPath(playerId),
            ludoBoard: ludoBoard);
        await Future.delayed(Duration(milliseconds: 100));
      } else if (state == TokenState.onBoard && gameState.canMoveTokenOnBoard) {
        await moveForward(
            world: world,
            token: this,
            tokenPath: getTokenPath(playerId),
            diceNumber: gameState.diceNumber,
            ludoBoard: ludoBoard);
      }
      gameState.currentPlayer.enableDice = true;
      return;
    }

    // Non-six logic
    if (state == TokenState.onBoard && gameState.canMoveTokenOnBoard) {
      await moveForward(
          world: world,
          token: this,
          tokenPath: getTokenPath(playerId),
          diceNumber: gameState.diceNumber,
          ludoBoard: ludoBoard);
    }

    gameState.switchToNextPlayer();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Save the canvas state before transformation
    canvas.save();

    // Move the canvas origin to the center of the component and rotate it by 180 degrees
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(3.14); // Rotate by 180 degrees (π radians)
    canvas.translate(
        -size.x / 2, -size.y / 2); // Move back to top-left of the component

    // Draw the droplet shape
    final path = Path();

    // Define the droplet's body (bottom is a half-circle, top is a sharp point)
    final baseRadius = size.x / 2;
    final bottomCenter = Offset(size.x / 2, size.y - baseRadius);

    // Draw the half-circle with transparent paint
    path.arcTo(
      Rect.fromCircle(center: bottomCenter, radius: baseRadius),
      0, // Start angle
      3.14, // Sweep angle (half-circle)
      false,
    );

    // Draw lines forming the point at the top of the droplet with visible paint
    path.lineTo(size.x / 2, 0); // Top point of the droplet
    path.lineTo(size.x, size.y - baseRadius); // Connect to bottom-right

    // Close the path
    path.close();

    // Fill the droplet shape with grey (or specified color)
    canvas.drawPath(path, dropletFillPaint);

    // Draw the droplet border with visible paint
    canvas.drawPath(path, borderPaint);

    // Now, draw a smaller circle inside the droplet at the bottom
    final smallerCircleRadius =
        baseRadius / 1.7; // Radius of the smaller circle
    final smallerCircleCenter = Offset(size.x / 2, size.y - baseRadius);

    // Draw the smaller circle
    canvas.drawCircle(smallerCircleCenter, smallerCircleRadius, fillPaint);

    // Restore the canvas state
    canvas.restore();
  }

  bool spaceToMove() {
    final tokenPath = getTokenPath(playerId);
    final index = tokenPath.indexOf(positionId);
    final newIndex = index + gameState.diceNumber;

    if (newIndex < tokenPath.length) {
      return true;
    } else {
      return false;
    }
  }
}
