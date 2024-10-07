import 'package:flame/components.dart';
import 'package:flutter/material.dart';
// user files
import 'red_grid_component.dart';
import 'yellow_grid_component.dart';
import 'blue_grid_component.dart';
import 'green_grid_component.dart';
import 'home.dart';

class LudoBoard extends PositionComponent {
  LudoBoard({
    required double width,
    required double height,
    Vector2? position, // Add position parameter
  }) {
    // Define the percentage widths for the components in each row
    final double firstComponentWidth = width * 0.398;
    final double secondComponentWidth = width * 0.199;
    final double thirdComponentWidth = width * 0.398;

    final double firstRowHeight = width * 0.398;
    final double secondRowHeight = width * 0.199;

    // Spacing between components
    const double horizontalSpacing = 0.0;

    const rowOne = 0;

    final firstComponent = RectangleComponent(
        size: Vector2(firstComponentWidth, firstRowHeight),
        position: Vector2(0, rowOne * firstRowHeight),
        children: [
          Home(
            size: firstComponentWidth,
            paint: Paint()..color = Colors.red,
            homeSpotColor: Paint()..color = Colors.red,
          )
        ]);

    final secondComponent = RectangleComponent(
        size: Vector2(secondComponentWidth, firstRowHeight),
        position: Vector2(
            firstComponentWidth + horizontalSpacing, rowOne * firstRowHeight),
        children: [GreenGridComponent(size: secondComponentWidth * 0.3333)]);

    final thirdComponent = RectangleComponent(
        size: Vector2(thirdComponentWidth, firstRowHeight),
        position: Vector2(
            firstComponentWidth + secondComponentWidth + 2 * horizontalSpacing,
            rowOne * firstRowHeight),
        children: [
          Home(
            size: firstComponentWidth,
            paint: Paint()..color = Colors.green,
            homeSpotColor: Paint()..color = Colors.green,
          )
        ]);

    const rowTwo = 1;

    final fourthComponent = RectangleComponent(
        size: Vector2(firstComponentWidth, secondRowHeight),
        position: Vector2(0, rowTwo * firstRowHeight),
        children: [RedGridComponent(size: firstComponentWidth * 0.1666)]);

    final fifthComponent = RectangleComponent(
        size: Vector2(secondComponentWidth, secondRowHeight),
        position: Vector2(
            firstComponentWidth + horizontalSpacing, rowTwo * firstRowHeight),
        children: [
          DiagonalRectangleComponent(size: Vector2.all(secondComponentWidth))
        ]);

    final sixthComponent = RectangleComponent(
        size: Vector2(thirdComponentWidth, secondRowHeight),
        position: Vector2(
            firstComponentWidth + secondComponentWidth + 2 * horizontalSpacing,
            rowTwo * firstRowHeight),
        children: [YellowGridComponent(size: firstComponentWidth * 0.1666)]);

    final seventhComponent = RectangleComponent(
        size: Vector2(firstComponentWidth, firstRowHeight),
        position: Vector2(0, firstRowHeight + secondRowHeight),
        children: [
          Home(
            size: firstComponentWidth,
            paint: Paint()..color = Colors.blue,
            homeSpotColor: Paint()..color = Colors.blue,
          )
        ]);

    final eigthComponent = RectangleComponent(
        size: Vector2(secondComponentWidth, firstRowHeight),
        position: Vector2(firstComponentWidth + horizontalSpacing,
            firstRowHeight + secondRowHeight),
        children: [BlueGridComponent(size: secondComponentWidth * 0.3333)]);

    final ninthComponent = RectangleComponent(
        size: Vector2(thirdComponentWidth, firstRowHeight),
        position: Vector2(
            firstComponentWidth + secondComponentWidth + 2 * horizontalSpacing,
            firstRowHeight + secondRowHeight),
        children: [
          Home(
            size: firstComponentWidth,
            paint: Paint()..color = Colors.primaries[12],
            homeSpotColor: Paint()..color = Colors.primaries[12],
          )
        ]);

    // Add all components to the LudoBoard
    add(firstComponent);
    add(secondComponent);
    add(thirdComponent);
    add(fourthComponent);
    add(fifthComponent);
    add(sixthComponent);
    add(seventhComponent);
    add(eigthComponent);
    add(ninthComponent);

    // Set the position of the LudoBoard
    this.position = position ??
        Vector2.zero(); // Default to (0, 0) if no position is provided
  }
}

class DiagonalRectangleComponent extends PositionComponent {
  DiagonalRectangleComponent({required Vector2 size}) {
    this.size = size;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // Define the rectangle area with its top-left corner at (0, 0)
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Define the vertices of the rectangle
    final topLeft = rect.topLeft;
    final topRight = rect.topRight;
    final bottomLeft = rect.bottomLeft;
    final bottomRight = rect.bottomRight;
    final center = Offset(
        (topLeft.dx + bottomRight.dx) / 2, (topLeft.dy + bottomRight.dy) / 2);

    // Define paints for filling the triangles with colors
    Paint yellowPaint = Paint()..color = Colors.yellow;
    Paint redPaint = Paint()..color = Colors.red;
    Paint bluePaint = Paint()..color = Colors.blue;
    Paint greenPaint = Paint()..color = Colors.green;

    // Define a black paint for the triangle borders
    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Yellow Triangle (top-left)
    Path redTriangle = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();
    canvas.drawPath(redTriangle, redPaint);
    canvas.drawPath(redTriangle, borderPaint); // Border

    // Red Triangle (bottom-right)
    Path yellowTriangle = Path()
      ..moveTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..close();
    canvas.drawPath(yellowTriangle, yellowPaint);
    canvas.drawPath(yellowTriangle, borderPaint); // Border

    // Blue Triangle (bottom-left)
    Path blueTriangle = Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();
    canvas.drawPath(blueTriangle, bluePaint);
    canvas.drawPath(blueTriangle, borderPaint); // Border

    // Green Triangle (top-right)
    Path greenTriangle = Path()
      ..moveTo(topRight.dx, topRight.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(topLeft.dx, topLeft.dy)
      ..close();
    canvas.drawPath(greenTriangle, greenPaint);
    canvas.drawPath(greenTriangle, borderPaint); // Border
  }

  @override
  void update(double dt) {
    // No update logic required for this static component
  }
}
