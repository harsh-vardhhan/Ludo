import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';
import '../../ludo.dart';
import '../../state/game_state.dart';

// user files
import 'controller_block.dart';

class LowerController extends RectangleComponent with HasGameReference<Ludo> {
  final RectangleComponent leftArrow;
  final RectangleComponent rightArrow;

  LowerController({
    required double width,
    required double height,
    Vector2? position,
  })  : leftArrow = RectangleComponent(
          size: Vector2(width * 0.45 * 0.3, height * 0.8),
          position: Vector2(width * 0.45 * 0.8, width * 0.45 * 0.05),
          paint: Paint()..color = Colors.transparent,
        ),
        rightArrow = RectangleComponent(
          size: Vector2(width * 0.45 * 0.3, height * 0.8),
          position: Vector2(width * 0.45  * 0.975, width * 0.45 * 0.05),
          paint: Paint()..color = Colors.transparent,
        ),
        super(
          size: Vector2(width, height),
          paint: Paint()..color = Colors.transparent,
        ) {
    final double innerWidth = width * 0.45;
    final double innerHeight = height;

    final leftToken = RectangleComponent(
      size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
      position: Vector2(2.2, innerWidth * 0.05),
      paint: Paint()..color = GameState().blue,
      children: [
        ControllerBlock(
          transparentRight: true,
          transparentLeft: false,
          size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
          position: Vector2(0, 0),
          paint: Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = const Color(0xFF03346E),
          children: [],
        ),
      ],
    );

    final leftDice = RectangleComponent(
      size: Vector2(innerWidth * 0.4, innerHeight),
      position: Vector2(innerWidth * 0.4, 0),
      paint: Paint()..color = GameState().blue,
      children: [
        RectangleComponent(
          size: Vector2(innerWidth * 0.4, innerHeight),
          paint: Paint()
            ..color = Colors.transparent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0
            ..color = const Color(0xFF03346E),
          children: [
            RectangleComponent(
              position: Vector2(innerWidth * 0.20, innerHeight * 0.5),
            ),
          ],
        ),
      ],
    );

    final rightDice = RectangleComponent(
      size: Vector2(innerWidth * 0.4, innerHeight),
      position: Vector2(width - innerWidth * 0.8, 0),
      paint: Paint()..color = GameState().yellow,
      children: [
        RectangleComponent(
          size: Vector2(innerWidth * 0.4, innerHeight),
          paint: Paint()
            ..color = Colors.transparent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0
            ..color = const Color(0xFF03346E),
          children: [
            RectangleComponent(
              position: Vector2(innerWidth * 0.20, innerHeight * 0.5),
            ),
          ],
        ),
      ],
    );

    final rightToken = RectangleComponent(
      size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
      position: Vector2(width - innerWidth * 0.4 - 2.5, innerWidth * 0.05),
      paint: Paint()..color = GameState().yellow,
      children: [
        ControllerBlock(
          transparentLeft: true,
          size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
          position: Vector2(0, 0),
          paint: Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = const Color(0xFF03346E),
          children: [],
        ),
      ],
    );

    addAll([leftDice, leftToken, rightDice, rightToken, leftArrow, rightArrow]);

    this.position = position ?? Vector2.zero();
  }

  /// Displays a `DicePointer` with a movement effect on the `leftArrow` component
  void showPointer(String playerId) {
    final pointerX = size.x * 0.05;
    final pointerY = (size.x * 0.20) * 0.2;

    final leftPointer = DicePointer(
      direction: PointerDirection.left,
      size: 30, // Triangle bounding box size
      paint: Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill,
      position: Vector2(pointerX, pointerY),
    );

    final rightPointer = DicePointer(
      direction: PointerDirection.right,
      size: 30, // Triangle bounding box size
      paint: Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill,
      position: Vector2(pointerX, pointerY ),
    );

    if (playerId == 'BP') {
      // Add movement effect to the pointer
      leftPointer.add(
        MoveByEffect(
          Vector2((size.x * 0.20) * 0.1, 0), // Move along the x-axis
          EffectController(
            duration: 0.2, // Takes 0.2 seconds to complete
            reverseDuration: 0.2, // Move back in 0.2 seconds
            infinite: true, // Repeats forever
          ),
        ),
      );
      leftArrow.add(leftPointer);
    } else if (playerId == 'YP') {
      rightPointer.add(
        MoveByEffect(
          Vector2((size.x * (-0.20)) * 0.1, 0), // Move along the x-axis
          EffectController(
            duration: 0.2, // Takes 0.2 seconds to complete
            reverseDuration: 0.2, // Move back in 0.2 seconds
            infinite: true, // Repeats forever
          ),
        ),
      );
      rightArrow.add(rightPointer);
    }
  }

  void hidePointer(String playerId) {
    if (playerId == 'BP') {
      final pointer = leftArrow.children.whereType<DicePointer>().firstOrNull;
      if (pointer != null) {
        leftArrow.remove(pointer);
      }
    } else if (playerId == 'YP') {
      final pointer = rightArrow.children.whereType<DicePointer>().firstOrNull;
      if (pointer != null) {
        rightArrow.remove(pointer);
      }
    }
  }
}

enum PointerDirection { left, right }

class DicePointer extends PositionComponent {
  final Paint paint;
  final PointerDirection direction;

  DicePointer({
    required double size,
    required this.paint,
    required this.direction,
    Vector2? position,
  }) : super(size: Vector2.all(size), position: position);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final path = Path();

    if (direction == PointerDirection.left) {
      path
        ..moveTo(size.x, 0) // Right corner
        ..lineTo(0, size.y / 2) // Left corner (new "top")
        ..lineTo(size.x, size.y) // Bottom corner
        ..close();
    } else if (direction == PointerDirection.right) {
      path
        ..moveTo(0, 0) // Left corner
        ..lineTo(size.x, size.y / 2) // Right corner (new "top")
        ..lineTo(0, size.y) // Bottom corner
        ..close();
    }

    canvas.drawPath(path, paint);
  }
}
