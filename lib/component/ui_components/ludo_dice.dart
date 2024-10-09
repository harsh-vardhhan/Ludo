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
import '../../state/game_state.dart';
import '../../state/player.dart';
import '../../ludo_board.dart';
import 'token.dart';
import '../../state/token_path.dart';
import '../../ludo.dart';

class LudoDice extends PositionComponent with TapCallbacks {
  static const double borderRadiusFactor =
      0.2; // Precomputed factor for border radius
  static const double innerSizeFactor =
      0.9; // Precomputed factor for inner size

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
    if (!player.enableDice ||
        !player.isCurrentTurn ||
        player != gameState.currentPlayer) {
      return; // Exit if the player cannot roll the dice
    }

    // Disable dice to prevent multiple taps
    player.enableDice = false;

    // Roll the dice and update the dice face
    final int diceNumber = Random().nextInt(6) + 1;
    gameState.diceNumber = diceNumber;
    diceFace.updateDiceValue(diceNumber);

    FlameAudio.play('dice.mp3');
    // Apply dice rotation effect
    await _applyDiceRollEffect();

    await Future.delayed(Duration(milliseconds: 700));

    final world = parent?.parent?.parent?.parent?.parent;
    if (world is! World) return; // Ensure the world is available

    final ludoBoard = world.children.whereType<LudoBoard>().first;

    // Handle dice roll based on the number
    final handleRoll = diceNumber == 6 ? _handleSixRoll : _handleNonSixRoll;
    await handleRoll(world, ludoBoard, diceNumber);
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

    // Filter tokens once and reuse the lists
    final tokensInBase = player.tokens
        .where((token) => token.state == TokenState.inBase)
        .toList();
    final tokensOnBoard = player.tokens
        .where((token) => token.state == TokenState.onBoard)
        .toList();

    if (_canMoveSingleToken(tokensInBase, tokensOnBoard)) {
      await _moveSingleToken(
        world,
        ludoBoard,
        diceNumber,
        tokensInBase,
        tokensOnBoard,
        getTokenPath(player.playerId),
      );
    } else {
      await _enableManualTokenSelection(tokensInBase, tokensOnBoard);
    }
  }

  // Handle logic for non-six dice rolls
  Future<void> _handleNonSixRoll(
      World world, LudoBoard ludoBoard, int diceNumber) async {
    final tokensOnBoard = player.tokens
        .where((token) => token.state == TokenState.onBoard)
        .toList();

    if (tokensOnBoard.isEmpty) {
      print('No tokens available to move for player ${player.playerId}.');
      gameState.switchToNextPlayer();
      return;
    }

    if (tokensOnBoard.length == 1 && tokensOnBoard.first.spaceToMove()) {
      await _moveForwardSingleToken(
          world, ludoBoard, diceNumber, tokensOnBoard.first);
      gameState.switchToNextPlayer();
      return;
    }

    final tokensInBase = player.tokens
        .where((token) => token.state == TokenState.inBase)
        .toList();

    _enableManualTokenSelection(tokensInBase, tokensOnBoard);
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
      List<Token> tokensOnBoard,
      List<String> tokenPath) async {
    if (tokensInBase.length == 1) {
      moveOutOfBase(
        world: world,
        token: tokensInBase.first,
        tokenPath: tokenPath, // Use the provided tokenPath directly
        ludoBoard: ludoBoard,
      );
      gameState.resetTokenMovement();
    } else if (tokensOnBoard.length == 1 && tokensOnBoard.first.spaceToMove()) {
      await _moveForwardSingleToken(
          world, ludoBoard, diceNumber, tokensOnBoard.first);
    }
    gameState.switchToNextPlayer();
    player.enableDice = true;
  }

  // Enable manual selection if multiple tokens can move
  Future<void> _enableManualTokenSelection(
      List<Token> tokensInBase, List<Token> tokensOnBoard) {
    player.enableToken = true;
    for (var token in player.tokens) {
      token.enableToken = true;
    }
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
    // Pre-calculate values to avoid repeated calculations
    final double borderRadiusValue = faceSize * borderRadiusFactor;
    final double innerWidth = faceSize * innerSizeFactor;
    final double innerHeight = faceSize * innerSizeFactor;
    final Vector2 innerSize = Vector2(innerWidth, innerHeight);
    final Vector2 innerPosition = Vector2(
        (faceSize - innerWidth) / 2, // Center horizontally
        (faceSize - innerHeight) / 2 // Center vertically
        );

    // Assign pre-calculated values
    borderRadius = borderRadiusValue;
    innerRectangleWidth = innerWidth;
    innerRectangleHeight = innerHeight;

    // Initialize the size of the component
    size = Vector2.all(faceSize);

    // Set the anchor to center for center rotation
    anchor = Anchor.center;

    // Initialize the dice face component
    diceFace = DiceFaceComponent(faceSize: innerWidth, diceValue: 6);

    // Initialize the inner rectangle component
    innerRectangle = RectangleComponent(
      size: innerSize,
      position: innerPosition,
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
