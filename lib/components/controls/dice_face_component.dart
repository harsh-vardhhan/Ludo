import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DiceFaceComponent extends PositionComponent {
  final double faceSize; // size of the dice face
  int diceValue; // dice value from 1 to 6

  late final double dotSize; // size of each dot
  late final double spacing; // spacing between dots

  late final Map<int, List<Offset>> precomputedDotOffsets;

  DiceFaceComponent({
    required this.faceSize,
    required this.diceValue,
  }) {
    dotSize = faceSize * 0.09; // Adjust dot size
    spacing = faceSize * 0.3; // Spacing between dots
    size = Vector2.all(faceSize);

    // Precompute dot positions
    precomputedDotOffsets = {
      1: [Offset(size.x / 2, size.y / 2)], // Center dot
      2: [
        Offset(size.x * 0.3, size.y * 0.3), // Top left
        Offset(size.x * 0.7, size.y * 0.7), // Bottom right
      ],
      3: [
        Offset(size.x * 0.3, size.y * 0.3), // Top left
        Offset(size.x / 2, size.y / 2), // Center dot
        Offset(size.x * 0.7, size.y * 0.7), // Bottom right
      ],
      4: [
        Offset(size.x * 0.3, size.y * 0.3), // Top left
        Offset(size.x * 0.7, size.y * 0.3), // Top right
        Offset(size.x * 0.3, size.y * 0.7), // Bottom left
        Offset(size.x * 0.7, size.y * 0.7), // Bottom right
      ],
      5: [
        Offset(size.x * 0.3, size.y * 0.3), // Top left
        Offset(size.x * 0.7, size.y * 0.3), // Top right
        Offset(size.x / 2, size.y / 2), // Center dot
        Offset(size.x * 0.3, size.y * 0.7), // Bottom left
        Offset(size.x * 0.7, size.y * 0.7), // Bottom right
      ],
      6: [
        Offset(size.x * 0.3, size.y * 0.2), // Top left
        Offset(size.x * 0.7, size.y * 0.2), // Top right
        Offset(size.x * 0.3, size.y * 0.5), // Middle left
        Offset(size.x * 0.7, size.y * 0.5), // Middle right
        Offset(size.x * 0.3, size.y * 0.8), // Bottom left
        Offset(size.x * 0.7, size.y * 0.8), // Bottom right
      ],
    };
  }

  // Method to update the dice value and re-render
  void updateDiceValue(int newDiceValue) {
    diceValue = newDiceValue;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the dice face background
    final paint = Paint()..color = Colors.transparent;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, paint);

    // Draw the dots
    final dotPaint = Paint()..color = Colors.black;

    // Define dot positions for each dice face
    final List<Offset> dotOffsets = _getDotOffsets();

    for (var offset in dotOffsets) {
      canvas.drawCircle(offset, dotSize, dotPaint);
    }
  }

  List<Offset> _getDotOffsets() {
    return precomputedDotOffsets[diceValue] ?? [];
  }
}
