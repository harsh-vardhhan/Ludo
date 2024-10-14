import 'package:flame/components.dart';
import 'package:flutter/material.dart';
// user files
import 'component/grid_component/red_grid_component.dart';
import 'component/grid_component/yellow_grid_component.dart';
import 'component/grid_component/blue_grid_component.dart';
import 'component/grid_component/green_grid_component.dart';
import 'component/home/home.dart';
import 'component/ui_components/spot.dart';

class LudoBoard extends PositionComponent {
  // Pre-computed constants
  static const double longWidth = 0.398;
  static const double shortWidth = 0.199;
  static const double horizontalSpacing = 0.0;

  // Pre-computed row indices
  static const int rowOne = 0;
  static const int rowTwo = 1;

  // Constructor
  LudoBoard({
    required double width,
    required double height,
    Vector2? position,
  }) {
    // Pre-compute dimensions based on width
    final double longDimension = width * longWidth;
    final double shortDimension = width * shortWidth;

    // Use longDimension and shortDimension wherever applicable
    final firstComponent = RectangleComponent(
        size: Vector2(longDimension, longDimension),
        position: Vector2(0, rowOne * longDimension),
        children: [
          Home(
            size: longDimension,
            paint: Paint()..color = Colors.red,
            homeSpotColor: Paint()..color = Colors.red,
          )
        ]);

    final secondComponent = RectangleComponent(
        size: Vector2(shortDimension, longDimension),
        position: Vector2(
            longDimension + horizontalSpacing, rowOne * longDimension),
        children: [GreenGridComponent(size: shortDimension * 0.3333)]);

    final thirdComponent = RectangleComponent(
        size: Vector2(longDimension, longDimension),
        position: Vector2(
            longDimension + shortDimension + 2 * horizontalSpacing,
            rowOne * longDimension),
        children: [
          Home(
            size: longDimension,
            paint: Paint()..color = Colors.green,
            homeSpotColor: Paint()..color = Colors.green,
          )
        ]);

    final fourthComponent = RectangleComponent(
        size: Vector2(longDimension, shortDimension),
        position: Vector2(0, rowTwo * longDimension),
        children: [RedGridComponent(size: longDimension * 0.1666)]);

    final fifthComponent = RectangleComponent(
        size: Vector2(shortDimension, shortDimension),
        position: Vector2(
            longDimension + horizontalSpacing, rowTwo * longDimension),
        children: [
          DiagonalRectangleComponent(size: Vector2.all(shortDimension))
        ]);

    final sixthComponent = RectangleComponent(
        size: Vector2(longDimension, shortDimension),
        position: Vector2(
            longDimension + shortDimension + 2 * horizontalSpacing,
            rowTwo * longDimension),
        children: [YellowGridComponent(size: longDimension * 0.1666)]);

    final seventhComponent = RectangleComponent(
        size: Vector2(longDimension, longDimension),
        position: Vector2(0, longDimension + shortDimension),
        children: [
          Home(
            size: longDimension,
            paint: Paint()..color = Colors.blue,
            homeSpotColor: Paint()..color = Colors.blue,
          )
        ]);

    final eigthComponent = RectangleComponent(
        size: Vector2(shortDimension, longDimension),
        position: Vector2(longDimension + horizontalSpacing,
            longDimension + shortDimension),
        children: [BlueGridComponent(size: shortDimension * 0.3333)]);

    final ninthComponent = RectangleComponent(
        size: Vector2(longDimension, longDimension),
        position: Vector2(
            longDimension + shortDimension + 2 * horizontalSpacing,
            longDimension + shortDimension),
        children: [
          Home(
            size: longDimension,
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
    this.position = position ?? Vector2.zero();
  }
}

class DiagonalRectangleComponent extends PositionComponent {
  // Precomputed centers of triangles
  late final Vector2 centerRedTriangle;
  late final Vector2 centerYellowTriangle;
  late final Vector2 centerBlueTriangle;
  late final Vector2 centerGreenTriangle;

  // Define Spot instances
  late final Spot redSpot;
  late final Spot yellowSpot;
  late final Spot blueSpot;
  late final Spot greenSpot;

  DiagonalRectangleComponent({required Vector2 size}) {
    this.size = size;

    // Precompute the centers of the triangles
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final topLeft = rect.topLeft;
    final topRight = rect.topRight;
    final bottomLeft = rect.bottomLeft;
    final bottomRight = rect.bottomRight;
    final center = Offset(
        (topLeft.dx + bottomRight.dx) / 2, (topLeft.dy + bottomRight.dy) / 2);

    centerRedTriangle = Vector2(
        (topLeft.dx + center.dx + bottomLeft.dx) / 3,
        (topLeft.dy + center.dy + bottomLeft.dy) / 3);
    centerYellowTriangle = Vector2(
        (bottomRight.dx + center.dx + topRight.dx) / 3,
        (bottomRight.dy + center.dy + topRight.dy) / 3);
    centerBlueTriangle = Vector2(
        (bottomLeft.dx + center.dx + bottomRight.dx) / 3,
        (bottomLeft.dy + center.dy + bottomRight.dy) / 3);
    centerGreenTriangle = Vector2(
        (topRight.dx + center.dx + topLeft.dx) / 3,
        (topRight.dy + center.dy + topLeft.dy) / 3);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Size of the transparent rectangle
    double rectWidth = size.x / 6;
    double rectHeight = size.y / 6;

    // Initialize Spot instances
    redSpot = Spot(
      uniqueId: 'RF',
      position: centerRedTriangle - Vector2(rectWidth / 2, rectHeight / 2),
      size: Vector2(rectWidth, rectHeight),
      paint: Paint()..color = Colors.red,
    );
    yellowSpot = Spot(
      uniqueId: 'YF',
      position: centerYellowTriangle - Vector2(rectWidth / 2, rectHeight / 2),
      size: Vector2(rectWidth, rectHeight),
      paint: Paint()..color = Colors.yellow,
    );
    blueSpot = Spot(
      uniqueId: 'BF',
      position: centerBlueTriangle - Vector2(rectWidth / 2, rectHeight / 2),
      size: Vector2(rectWidth, rectHeight),
      paint: Paint()..color = Colors.blue,
    );
    greenSpot = Spot(
      uniqueId: 'GF',
      position: centerGreenTriangle - Vector2(rectWidth / 2, rectHeight / 2),
      size: Vector2(rectWidth, rectHeight),
      paint: Paint()..color = Colors.green,
    );

    // Add all Spot instances at once
    addAll([redSpot, yellowSpot, blueSpot, greenSpot]);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

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

    // Draw the triangles and borders
    _drawTriangle(canvas, redPaint, borderPaint, topLeft, center, bottomLeft);
    _drawTriangle(canvas, yellowPaint, borderPaint, bottomRight, center, topRight);
    _drawTriangle(canvas, bluePaint, borderPaint, bottomLeft, center, bottomRight);
    _drawTriangle(canvas, greenPaint, borderPaint, topRight, center, topLeft);
  }

  void _drawTriangle(Canvas canvas, Paint fillPaint, Paint borderPaint, Offset p1, Offset p2, Offset p3) {
    Path triangle = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    canvas.drawPath(triangle, fillPaint);
    canvas.drawPath(triangle, borderPaint);
  }
}


// Define transparentPaint
final Paint transparentPaint = Paint()..color = const Color(0x00000000);