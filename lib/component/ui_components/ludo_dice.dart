import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/geometry.dart';
// user files
import 'dice_face_component.dart';
import '../../state/game_state.dart';
import '../../state/audio_manager.dart';
import '../../state/player.dart';
import '../../ludo.dart';

class LudoDice extends PositionComponent with TapCallbacks, HasGameReference<Ludo> {
  static const double borderRadiusFactor =
      0.2; // Precomputed factor for border radius
  static const double innerSizeFactor =
      0.9; // Precomputed factor for inner size

  // final gameState = GameState();
  final double faceSize; // size of the square
  late final double borderRadius; // radius of the curved edges
  late final double innerRectangleWidth; // width of the inner rectangle
  late final double innerRectangleHeight; // height of the inner rectangle

  late final RectangleComponent innerRectangle; // inner rectangle component
  late final DiceFaceComponent diceFace; // The dice face showing dots

  final Player player;

  void playSound() async {
    await AudioManager.playDiceSound();
  }

  @override
  void onTapDown(TapDownEvent event) async {
    if (!player.enableDice ||
        !player.isCurrentTurn ||
        player != GameState().currentPlayer) {
      return; // Exit if the player cannot roll the dice
    }

    // Disable dice to prevent multiple taps
    final world = game.world;
    GameState().hidePointer();
    player.enableDice = false;

    // Roll the dice and update the dice face
    final rolledNumber = GameState().rollDice();
    diceFace.updateDiceValue(rolledNumber);

    playSound();
    // Apply dice rotation effect
    _applyDiceRollEffect();

    await Future.delayed(const Duration(milliseconds: 300));

    // Resolve the roll logic on the GameState controller
    GameState().resolveDiceRoll(world);
  }

  // Apply a 360-degree rotation effect to the dice
  FutureOr<void> _applyDiceRollEffect() {
    add(
      RotateEffect.by(
        tau, // Full 360-degree rotation (2π radians)
        EffectController(
          duration: 0.3, // Reduced duration
          curve: Curves.linear, // Simpler curve
        ),
      ),
    );
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
    final innerRectangle = RoundedRectangle(
      size: innerSize,
      position: innerPosition,
      paint: Paint()..color = Colors.white,
      borderRadius: 15.0, // Customize corner radius
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
      ..color = const Color(0xFFD6D6D6)
      ..style = PaintingStyle.fill;

    // Define the rounded rectangle
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final radius = Radius.circular(borderRadius);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    // Draw the rounded rectangle
    canvas.drawRRect(rrect, paint);
  }
}

class RoundedRectangle extends PositionComponent {
  final Paint paint;
  final double borderRadius;

  RoundedRectangle({
    required Vector2 size,
    required this.paint,
    this.borderRadius = 10.0, // Default corner radius
    super.position,
    super.children,
  }) : super(size: size);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, paint);
    super.render(canvas);
  }
}
