import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/geometry.dart';
import 'package:flame_audio/flame_audio.dart';
// user files
import 'dice_face_component.dart';
import 'game_state.dart';
import 'player.dart';
import 'ludo_board.dart';
import 'token.dart';
import 'token_path.dart';
import 'ludo.dart';


class LudoDice extends PositionComponent with TapCallbacks {
  final gameState = GameState();
  final double faceSize; // size of the square
  late final double borderRadius; // radius of the curved edges
  late final double innerRectangleWidth; // width of the inner rectangle
  late final double innerRectangleHeight; // height of the inner rectangle

  late final RectangleComponent innerRectangle; // inner rectangle component
  late final DiceFaceComponent diceFace; // The dice face showing dots

  final Player player;

  @override
  Future<void> onTapDown(TapDownEvent event) async {
    final gameState = GameState();

    if (!player.enableDice ||
        !player.isCurrentTurn ||
        player != gameState.currentPlayer) {
      return; // Exit if the player cannot roll the dice
    }

    // Disable dice to prevent multiple taps
    player.enableDice = false;

    // Roll the dice and update the dice face
    final Random random = Random(); // Random number generator
    int rollDice() => random.nextInt(6) + 1;
    final int diceNumber = rollDice();
    gameState.diceNumber = diceNumber;
    diceFace.updateDiceValue(diceNumber);

    FlameAudio.play('dice.mp3');
    // Apply dice rotation effect
    await _applyDiceRollEffect();

    await Future.delayed(Duration(milliseconds: 700));

    final world = parent?.parent?.parent?.parent?.parent;
    if (world is! World) return; // Ensure the world is available

    final ludoBoard = world.children.whereType<LudoBoard>().first;

    if (diceNumber == 6) {
      await _handleSixRoll(world, ludoBoard, diceNumber);
    } else {
      await _handleNonSixRoll(world, ludoBoard, diceNumber);
    }
  }

  // Apply a 360-degree rotation effect to the dice
  FutureOr<void> _applyDiceRollEffect() {
    add(
      RotateEffect.by(
        tau, // Full 360-degree rotation (2π radians)
        EffectController(
          duration: 0.5,
          curve: Curves.easeInOut,
        ),
      ),
    );
    return Future.value();
  }

  // Handle logic when the player rolls a 6
  Future<void> _handleSixRoll(
      World world, LudoBoard ludoBoard, int diceNumber) async {
    player.grantAnotherTurn(); // Grant extra turn for rolling a six

    if (player.hasRolledThreeConsecutiveSixes()) {
      gameState.switchToNextPlayer();
      return;
    }

    final tokensInBase = player.tokens
        .where((token) => token.state == TokenState.inBase)
        .toList();
    final tokensOnBoard = player.tokens
        .where((token) => token.state == TokenState.onBoard)
        .toList();

    if (_canMoveSingleToken(tokensInBase, tokensOnBoard)) {
      _moveSingleToken(
          world, ludoBoard, diceNumber, tokensInBase, tokensOnBoard);
    } else {
      _enableManualTokenSelection(tokensInBase, tokensOnBoard);
    }

    return Future.value();
  }

  // Handle logic for non-six dice rolls
  Future<void> _handleNonSixRoll(
      World world, LudoBoard ludoBoard, int diceNumber) async {
    final tokensOnBoard = player.tokens
        .where((token) => token.state == TokenState.onBoard)
        .toList();

    final tokensInBase = player.tokens
        .where((token) => token.state == TokenState.inBase)
        .toList();

    if (tokensOnBoard.length == 1) {
      await _moveForwardSingleToken(
          world, ludoBoard, diceNumber, tokensOnBoard.first);
      gameState.switchToNextPlayer();
    } else if (tokensOnBoard.isNotEmpty) {
      _enableManualTokenSelection(tokensInBase, tokensOnBoard);
    } else {
      print('No tokens available to move for player ${player.playerId}.');
      gameState.switchToNextPlayer();
    }
    return Future.value();
  }

  // Check if the player can move a single token (either from base or on the board)
  bool _canMoveSingleToken(
      List<Token> tokensInBase, List<Token> tokensOnBoard) {
    return (tokensInBase.length == 1 && tokensOnBoard.isEmpty) ||
        (tokensOnBoard.length == 1 && tokensInBase.isEmpty);
  }

  // Move a single token based on whether it's in base or on the board
  Future<void> _moveSingleToken(
      World world,
      LudoBoard ludoBoard,
      int diceNumber,
      List<Token> tokensInBase,
      List<Token> tokensOnBoard) async {
    if (tokensInBase.length == 1) {
      moveOutOfBase(
        world: world,
        token: tokensInBase.first,
        tokenPath: getTokenPath(player.playerId),
        ludoBoard: ludoBoard,
      );
      gameState.resetTokenMovement();
      player.enableDice = true;
    } else if (tokensOnBoard.length == 1) {
      await _moveForwardSingleToken(
          world, ludoBoard, diceNumber, tokensOnBoard.first);
      gameState.switchToNextPlayer();
      player.enableDice = true;
    }
    return Future.value();
  }

  // Enable manual selection if multiple tokens can move
  Future<void> _enableManualTokenSelection(
      List<Token> tokensInBase, List<Token> tokensOnBoard) {
    player.enableToken = true;
    if (tokensInBase.isNotEmpty && tokensOnBoard.isNotEmpty) {
      gameState.enableMoveFromBoth();
      addTokenTrail(tokensOnBoard);
    } else if (tokensInBase.isNotEmpty) {
      gameState.enableMoveFromBase();
    } else if (tokensOnBoard.isNotEmpty) {
      addTokenTrail(tokensOnBoard);
      gameState.enableMoveOnBoard();
    }
    return Future.value();
  }

  // Move the token forward on the board
  Future<void> _moveForwardSingleToken(
      World world, LudoBoard ludoBoard, int diceNumber, Token token) async {
    await moveForward(
      world: world,
      token: token,
      tokenPath: getTokenPath(player.playerId),
      diceNumber: diceNumber,
      ludoBoard: ludoBoard,
    );
    await Future.delayed(Duration(milliseconds: 300));
    tokenCollision(world);
    return Future.value();
  }

  LudoDice({required this.faceSize, required this.player}) {
    // Calculate properties based on faceSize
    borderRadius = faceSize / 5;
    innerRectangleWidth = faceSize * 0.9;
    innerRectangleHeight = faceSize * 0.9;

    // Initialize the size of the component
    size = Vector2.all(faceSize);

    // Set the anchor to center for center rotation
    anchor = Anchor.center;

    // Initialize the dice face component
    diceFace = DiceFaceComponent(faceSize: innerRectangleWidth, diceValue: 6);

    // Initialize the inner rectangle component
    innerRectangle = RectangleComponent(
      size: Vector2(innerRectangleWidth, innerRectangleHeight),
      position: Vector2(
          (faceSize - innerRectangleWidth) / 2, // Center horizontally
          (faceSize - innerRectangleHeight) / 2 // Center vertically
          ),
      paint: Paint()..color = Colors.white,
      children: [diceFace],
    );

    // Add the inner rectangle to this component
    add(innerRectangle);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Create paint for the square
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Define the rounded rectangle
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final radius = Radius.circular(borderRadius);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    // Draw the rounded rectangle
    canvas.drawRRect(rrect, paint);
  }
}
