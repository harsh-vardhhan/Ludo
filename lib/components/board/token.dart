import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:ludo/models/token.dart';
import 'package:ludo/managers/game_state.dart';
import 'package:ludo/ludo.dart';

class TokenComponent extends PositionComponent with TapCallbacks, HasGameReference<Ludo> {
  final Token token;
  Color topColor;
  Color sideColor;

  bool _shouldDrawCircle = false; // Flag to control circle rendering and animation
  double _circleScale = 1.0;
  Timer? _circleAnimationTimer;

  TokenComponent({
    required this.token,
    required Vector2 position, // Initial position of the token
    required Vector2 size, // Size of the token
    required this.topColor,
    required this.sideColor,
  }) : super(position: position, size: size);

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
        Paint()..color = const Color(0xFF3C3D37).withValues(alpha: 0.6));
    canvas.drawCircle(centerShadow, sideOuterRadius,
        Paint()..color = sideColor); // Draw outer circle

    canvas.drawCircle(
        center, outerRadius, Paint()..color = topColor); // Draw border

    canvas.drawCircle(smallerCircleShadow, smallerCircleDepth,
        Paint()..color = const Color(0xFF3C3D37).withValues(alpha: 0.7));
    canvas.drawCircle(center, smallerCircle, Paint()..color = Colors.white);

    // Conditionally render the circle around the token
    if (_shouldDrawCircle) {
      _renderCircleAroundToken(canvas);
    }
  }

  void _renderCircleAroundToken(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 1.8);

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Scale the circle based on _circleScale
    final scaledRadius = (size.x / 2) * _circleScale;
    canvas.drawCircle(center, scaledRadius, paint);
  }

  // Enable circle rendering and animation
  void enableCircleAnimation() {
    if (_shouldDrawCircle) return; // Already active, do nothing

    _shouldDrawCircle = true;

    // Start a timer to simulate the scale effect
    _circleAnimationTimer = Timer(
      0.070, // Frame interval
      onTick: () {
        _circleScale += 0.05; // Increase scale
        if (_circleScale >= 2) {
          _circleScale = 1.0; // Reset scale
        }
      },
      repeat: true,
    )..start();
  }

  // Disable circle rendering and animation
  void disableCircleAnimation() {
    _shouldDrawCircle = false;

    // Stop the animation timer
    _circleAnimationTimer?.stop();
    _circleAnimationTimer = null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the timer for the animation
    _circleAnimationTimer?.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    GameState().handleTokenTap(game.world, token);
  }
}
