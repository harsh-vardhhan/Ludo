library;

import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final Ludo game;

  @override
  void initState() {
    super.initState();
    game = Ludo();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff98DED9),
                Color(0xffFFFFFF),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: FittedBox(
                  child: SizedBox(
                    width: screenWidth,
                    height: screenWidth + screenWidth * 0.70,
                    child: GameWidget(
                      game: game,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayArea extends RectangleComponent with HasGameReference<Ludo> {
  PlayArea() : super(children: [RectangleHitbox()]);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);
  }
}

class CustomRectangleComponent extends PositionComponent {
  final Paint strokePaint;
  final double strokeWidth;
  final bool transparentRight;
  final bool transparentLeft;

  CustomRectangleComponent({
    required Vector2 size, // Size of the rectangle
    required Vector2 position, // Position of the rectangle
    required Paint paint, // Fill paint of the rectangle
    this.strokeWidth = 4.0, // Width of the stroke
    this.transparentRight = false,
    this.transparentLeft = false,
    List<Component>? children, // Optional child components
  })  : strokePaint = Paint()
          ..color = paint.color.withOpacity(1.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
        super(
          size: size,
          position: position,
          children: children ?? [],
        );

  @override
  void render(Canvas canvas) {
    // Draw the filled rectangle
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect,
        Paint()..color = strokePaint.color.withOpacity(0)); // Transparent fill

    // Stroke paint for sides
    final transparentStrokePaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.0;

    // Draw stroke on sides, skipping the top if transparentTop is true
    if (transparentLeft) {
      canvas.drawLine(
          const Offset(0, 0), Offset(0, size.y), transparentStrokePaint);
    } else {
      canvas.drawLine(const Offset(0, 0), Offset(0, size.y), strokePaint);
    }
    if (transparentRight) {
      canvas.drawLine(
          Offset(size.x, 0), Offset(size.x, size.y), transparentStrokePaint);
    } else {
      canvas.drawLine(Offset(size.x, 0), Offset(size.x, size.y), strokePaint);
    }
    canvas.drawLine(const Offset(0, 0), Offset(size.x, 0), strokePaint); // Top
    canvas.drawLine(
        Offset(0, size.y), Offset(size.x, size.y), strokePaint); // Bottom
  }

  @override
  void update(double dt) {
    // Update logic if needed
  }
}

class DiceFaceComponent extends PositionComponent {
  final double faceSize; // size of the dice face
  final int diceValue; // dice value from 1 to 6

  late final double dotSize; // size of each dot
  late final double spacing; // spacing between dots

  DiceFaceComponent({
    required this.faceSize,
    required this.diceValue,
  }) {
    dotSize = faceSize * 0.1; // Adjust dot size
    spacing = faceSize * 0.3; // Spacing between dots
    size = Vector2.all(faceSize);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the dice face background
    final paint = Paint()..color = Colors.white;
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
    switch (diceValue) {
      case 1:
        return [Offset(size.x / 2, size.y / 2)]; // Center dot
      case 2:
        return [
          Offset(size.x * 0.3, size.y * 0.3), // Top left
          Offset(size.x * 0.7, size.y * 0.7), // Bottom right
        ];
      case 3:
        return [
          Offset(size.x * 0.3, size.y * 0.3), // Top left
          Offset(size.x / 2, size.y / 2), // Center dot
          Offset(size.x * 0.7, size.y * 0.7), // Bottom right
        ];
      case 4:
        return [
          Offset(size.x * 0.3, size.y * 0.3), // Top left
          Offset(size.x * 0.7, size.y * 0.3), // Top right
          Offset(size.x * 0.3, size.y * 0.7), // Bottom left
          Offset(size.x * 0.7, size.y * 0.7), // Bottom right
        ];
      case 5:
        return [
          Offset(size.x * 0.3, size.y * 0.3), // Top left
          Offset(size.x * 0.7, size.y * 0.3), // Top right
          Offset(size.x / 2, size.y / 2), // Center dot
          Offset(size.x * 0.3, size.y * 0.7), // Bottom left
          Offset(size.x * 0.7, size.y * 0.7), // Bottom right
        ];
      case 6:
        return [
          Offset(size.x * 0.3, size.y * 0.2), // Top left
          Offset(size.x * 0.7, size.y * 0.2), // Top right
          Offset(size.x * 0.3, size.y * 0.5), // Middle left
          Offset(size.x * 0.7, size.y * 0.5), // Middle right
          Offset(size.x * 0.3, size.y * 0.8), // Bottom left
          Offset(size.x * 0.7, size.y * 0.8), // Bottom right
        ];
      default:
        return [];
    }
  }
}

class CurvedSquareComponent extends PositionComponent {
  final double faceSize; // size of the square
  late final double borderRadius; // radius of the curved edges
  late final double innerRectangleWidth; // width of the inner rectangle
  late final double innerRectangleHeight; // height of the inner rectangle

  late final RectangleComponent innerRectangle; // inner rectangle component

  CurvedSquareComponent({
    required this.faceSize,
    required Vector2 position, // Position argument
  }) {
    // Calculate properties based on faceSize
    borderRadius = faceSize / 5;
    innerRectangleWidth = faceSize * 0.7;
    innerRectangleHeight = faceSize * 0.7;

    // Initialize the size of the component
    size = Vector2.all(faceSize);

    // Set the position of the component
    this.position = position;

    // Initialize the inner rectangle component
    innerRectangle = RectangleComponent(
      size: Vector2(innerRectangleWidth, innerRectangleHeight),
      position: Vector2(
          (faceSize - innerRectangleWidth) / 2, // Center horizontally
          (faceSize - innerRectangleHeight) / 2 // Center vertically
          ),
      paint: Paint()..color = Colors.grey, 
      children: [
          DiceFaceComponent(faceSize: innerRectangleWidth, diceValue: 6)
      ]
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

class LowerController extends RectangleComponent {
  LowerController({
    required double width,
    required double height,
    Vector2? position, // Add position parameter
  }) : super(
          size: Vector2(width, height),
          paint: Paint()..color = Colors.transparent, // Adjust color as needed
        ) {
    final double innerWidth = width * 0.45; // Width of the inner rectangles
    final double innerHeight = height; // Same height as the outer rectangle

    final leftToken = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
        position: Vector2(2.2, innerWidth * 0.05), // Sticks to the left
        paint: Paint()..color = Color(0xFFA0DEFF),
        children: [
          CustomRectangleComponent(
              transparentRight: true,
              transparentLeft: false,
              size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
              position: Vector2(0, 0),
              paint: Paint()
                ..color = Colors.black
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0
                ..color = Color(0xFF03346E),
              children: []),
        ]);

    final leftDice = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight),
        position: Vector2(innerWidth * 0.4, 0), // Sticks to the left
        paint: Paint()..color = Color(0xFFA0DEFF),
        children: [
          RectangleComponent(
              size: Vector2(innerWidth * 0.4, innerHeight),
              paint: Paint()
                ..color = Colors.transparent
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4.0
                ..color = Color(0xFF03346E),
              children: [
                CurvedSquareComponent(
                    faceSize: (innerWidth * 0.4) * 0.65,
                    position: Vector2((innerWidth * 0.4) * 0.15, (innerWidth * 0.4) * 0.22))
              ]),
        ] // Adjust color as needed
        );

    final rightDice = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight),
        position: Vector2(width - innerWidth * 0.8, 0), // Sticks to the right
        paint: Paint()..color = Color(0xFFFFF455),
        children: [
          RectangleComponent(
              size: Vector2(innerWidth * 0.4, innerHeight),
              paint: Paint()
                ..color = Colors.transparent
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4.0
                ..color = Color(0xFF03346E))
        ]);

    final rightToken = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
        position: Vector2(width - innerWidth * 0.4 - 2.5, innerWidth * 0.05),
        paint: Paint()..color = Color(0xFFFFF455),
        children: [
          CustomRectangleComponent(
              transparentLeft: true,
              size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
              position: Vector2(0, 0),
              paint: Paint()
                ..color = Colors.black
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0
                ..color = Color(0xFF03346E),
              children: []),
        ]);

    add(leftDice);
    add(leftToken);

    add(rightDice);
    add(rightToken);

    // Set the position of the UpperController
    this.position = position ??
        Vector2.zero(); // Default to (0, 0) if no position is provided
  }
}

class Ludo extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  Ludo();

  final rand = Random();
  double get width => size.x;
  double get height => size.y;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    // Now you can set up the camera with the screen size
    camera = CameraComponent.withFixedResolution(
      width: width,
      height: height,
    );
    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(LudoBoard(
        width: width, height: width, position: Vector2(0, height * 0.125)));
    world.add(LowerController(
        position: Vector2(0, width + (width * 0.25)),
        width: width,
        height: width * 0.20));
  }

  void startGame() {}

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        startGame();
    }
    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() => const Color.fromARGB(0, 0, 0, 0);
}

class LudoBoard extends PositionComponent {
  LudoBoard({
    required double width,
    required double height,
    Vector2? position, // Add position parameter
  }) {
    // Define the percentage widths for the components in each row
    final double firstComponentWidth = width * 0.40;
    final double secondComponentWidth = width * 0.20;
    final double thirdComponentWidth = width * 0.40;

    final double firstRowHeight = width * 0.40;
    final double secondRowHeight = width * 0.20;

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

class Home extends RectangleComponent {
  Home(
      {required double size,
      required Paint? paint,
      required Paint? homeSpotColor,
      children})
      : super(size: Vector2.all(size), paint: paint ?? Paint(), children: [
          // Define border as a separate child component for the stroke
          RectangleComponent(
            size: Vector2.all(size),
            paint: Paint()
              ..color = Colors.transparent
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0
              ..color = Colors.black,
          ),
          HomePlate(
              size: size / 1.5,
              position: Vector2(
                size / 2 - (size / 1.5) / 2, // Calculate center x
                size / 2 - (size / 1.5) / 2, // Calculate center y
              ),
              homeSpotColor: homeSpotColor)
        ]);
}

class SquareBlocks extends RectangleComponent {
  SquareBlocks({
    required double size,
  }) : super(paint: Paint()..color = Colors.white, children: [
          RectangleComponent(
            size: Vector2.all(size),
            paint: Paint()
              ..color = Colors.transparent // Keep interior transparent
              ..style = PaintingStyle.stroke // Set style to stroke
              ..strokeWidth = 1.0 // Set border width
              ..color = Colors.black, // Set border color to black
          ),
        ]);
}

class StarComponent extends PositionComponent {
  final double innerRadius; // Instance variable for inner radius
  final double outerRadius; // Instance variable for outer radius
  final Paint borderPaint;

  // Constructor that initializes the size, innerRadius, and outerRadius
  StarComponent({
    required Vector2 size,
    required this.innerRadius, // Inner radius passed during component creation
    required this.outerRadius, // Outer radius passed during component creation
    Color borderColor = Colors.black,
  }) : borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 {
    this.size = size; // Set the size
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Create the star shape using the provided inner and outer radius
    Path starPath = createStarPath(innerRadius, outerRadius);

    // Center the star in the component's bounding box
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    // Draw the star with transparent fill and black border
    Paint fillPaint = Paint()..color = Colors.transparent;
    canvas.drawPath(starPath, fillPaint);
    canvas.drawPath(starPath, borderPaint); // Black border

    // Restore the canvas to its original state
    canvas.restore();
  }

  /// Creates a star shape with the specified inner and outer radius.
  /// Rotate the star so that one tip is at the top (90 degrees).
  Path createStarPath(double innerRadius, double outerRadius) {
    Path path = Path();
    double angleStep = pi / 5; // 5-pointed star
    double angleOffset = -pi / 2; // Offset to point one tip upwards

    for (int i = 0; i < 10; i++) {
      double radius = i.isEven ? outerRadius : innerRadius;
      double angle = angleStep * i + angleOffset;
      double x = radius * cos(angle);
      double y = radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void update(double dt) {
    // No update logic required for this static component
  }
}

class InvertedDropletComponent extends PositionComponent {
  final Paint borderPaint;
  final Paint transparentPaint;
  final Paint fillPaint;
  final Paint dropletFillPaint; // Paint for filling the inside of the droplet

  InvertedDropletComponent({
    required Vector2 position,
    required Vector2 size,
    Color borderColor = Colors.black,
    Color innerCircleColor = Colors.blueAccent,
    Color dropletFillColor = Colors.white, // Default fill color for droplet
  })  : borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = borderColor,
        transparentPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = Colors.transparent, // Transparent line
        fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = innerCircleColor,
        dropletFillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = dropletFillColor, // Paint for filling droplet
        super(position: position, size: size);

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
}

class GreenGridComponent extends PositionComponent {
  GreenGridComponent({
    required double size,
  }) : super(
          size: Vector2.all(size),
        ) {
    _createGrid();
  }

  // Function to create the grid of rectangles
  void _createGrid() {
    //Vector2 rectangleSize = Vector2(20, 20); // Size of each square
    double spacing = 0; // Vertical spacing between rectangles
    double columnSpacing = 0; // Horizontal spacing between columns

    int numberOfRows = 6;
    int numberOfColumns = 3;

    // Loop to create 3 columns of 6 squares each
    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.transparent;
        if (row > 0 && col == 1 || row == 1 && col == 2) {
          color = Colors.green;
        }
        var rectangle = RectangleComponent(
            position: Vector2(
                col * (size.x + columnSpacing), row * (size.y + spacing)),
            size: size,
            paint: Paint()..color = color,
            children: [
              RectangleComponent(
                  size: size,
                  paint: Paint()
                    ..color = Colors.transparent // Keep interior transparent
                    ..style = PaintingStyle.stroke // Set style to stroke
                    ..strokeWidth = 0.6 // Set border width
                    ..color = Colors.black, // Set border color to black
                  children: [
                    if (col == 0 && row == 2)
                      StarComponent(
                          size: size,
                          innerRadius: size.x * 0.24,
                          outerRadius: size.x * 0.48),
                    if (col == 1 && row == 0)
                      ArrowIconComponent(
                        icon: Icons.south,
                        size: size.x * 0.90,
                        position: Vector2(size.x * 0.05,
                            size.x * 0.05), // Font size of the arrow
                        borderColor: Colors.green, // Color of the arrow
                      ),
                    if (col == 0 && row == 0)
                      InvertedDropletComponent(
                        position: Vector2(size.x * 0.10, -size.x * 0.30),
                        size: Vector2(size.x * 0.75, size.x * 1),
                      ),
                    if (col == 0 && row == 5)
                      InvertedDropletComponent(
                        position: Vector2(size.x * 0.10, -size.x * 0.30),
                        size: Vector2(size.x * 0.75, size.x * 1),
                      ),
                    if (col == 0 && row == 3)
                      InvertedDropletComponent(
                        position: Vector2(size.x * 0.10, -size.x * 0.30),
                        size: Vector2(size.x * 0.75, size.x * 1),
                      ),
                  ])
            ]);
        add(rectangle);
      }
    }
  }
}

class BlueGridComponent extends PositionComponent {
  BlueGridComponent({
    required double size,
  }) : super(
          size: Vector2.all(size),
        ) {
    _createGrid();
  }

  // Function to create the grid of rectangles
  void _createGrid() {
    //Vector2 rectangleSize = Vector2(20, 20); // Size of each square
    double spacing = 0; // Vertical spacing between rectangles
    double columnSpacing = 0; // Horizontal spacing between columns

    int numberOfRows = 6;
    int numberOfColumns = 3;

    // Loop to create 3 columns of 6 squares each
    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.transparent;
        if (col == 0 && row == 4 || col == 1 && row < 5) {
          color = Colors.blue;
        }
        var rectangle = RectangleComponent(
            position: Vector2(
                col * (size.x + columnSpacing), row * (size.y + spacing)),
            size: size,
            paint: Paint()..color = color,
            children: [
              RectangleComponent(
                  size: size,
                  paint: Paint()
                    ..color = Colors.transparent // Keep interior transparent
                    ..style = PaintingStyle.stroke // Set style to stroke
                    ..strokeWidth = 0.6 // Set border width
                    ..color = Colors.black, // Set border color to black
                  children: [
                    if (col == 2 && row == 3)
                      StarComponent(
                          size: size,
                          innerRadius: size.x * 0.24,
                          outerRadius: size.x * 0.48),
                    if (col == 1 && row == 5)
                      ArrowIconComponent(
                        icon: Icons.north,
                        size: size.x * 0.90,
                        position: Vector2(size.x * 0.05,
                            size.x * 0.05), // Font size of the arrow
                        borderColor: Colors.blue, // Color of the arrow
                      )
                  ])
            ]);
        add(rectangle);
      }
    }
  }
}

class ArrowIconComponent extends PositionComponent {
  final IconData arrowIcon;
  final Paint borderPaint;

  ArrowIconComponent({
    required IconData icon,
    required double size,
    required Vector2 position, // Make position a required parameter
    Color borderColor = Colors.black,
  })  : arrowIcon = icon,
        borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 {
    this.size = Vector2.all(size); // Set the size of the component
    this.position = position; // Set the position
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Create a TextPainter to render the icon
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(arrowIcon.codePoint),
        style: TextStyle(
          fontSize: size.x, // Font size for the arrow
          color: borderPaint.color,
          fontFamily: arrowIcon.fontFamily, // Use the FontAwesome font
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Calculate the offset to center the text within the component
    double xOffset = (size.x - textPainter.width) / 2;
    double yOffset = (size.y - textPainter.height) / 2;

    // Center the arrow in the component
    canvas.save();
    canvas.translate(xOffset, yOffset);

    // Draw the arrow icon
    textPainter.paint(canvas, Offset.zero);

    // Restore the canvas
    canvas.restore();
  }

  @override
  void update(double dt) {
    // No update logic required for this static component
  }
}

class RedGridComponent extends PositionComponent {
  RedGridComponent({
    required double size,
  }) : super(
          size: Vector2.all(size),
        ) {
    _createGrid();
  }

  // Function to create the grid of rectangles
  void _createGrid() {
    //Vector2 rectangleSize = Vector2(20, 20); // Size of each square
    double spacing = 0; // Vertical spacing between rectangles
    double columnSpacing = 0; // Horizontal spacing between columns

    int numberOfRows = 3;
    int numberOfColumns = 6;

    // Loop to create 3 rows of 6 squares each
    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.transparent;
        if (row == 0 && col == 1 || row == 1 && col > 0) {
          color = Colors.red;
        }
        var rectangle = RectangleComponent(
            position: Vector2(
                col * (size.x + columnSpacing), row * (size.y + spacing)),
            size: size,
            paint: Paint()..color = color,
            children: [
              RectangleComponent(
                  size: size,
                  paint: Paint()
                    ..color = Colors.transparent // Keep interior transparent
                    ..style = PaintingStyle.stroke // Set style to stroke
                    ..strokeWidth = 0.6 // Set border width
                    ..color = Colors.black, // Set border color to black
                  children: [
                    if (col == 2 && row == 2)
                      StarComponent(
                          size: size,
                          innerRadius: size.x * 0.24,
                          outerRadius: size.x * 0.48),
                    if (col == 0 && row == 1)
                      ArrowIconComponent(
                        icon: Icons.east,
                        size: size.x * 0.90,
                        position: Vector2(size.x * 0.05,
                            size.x * 0.05), // Font size of the arrow
                        borderColor: Colors.red, // Color of the arrow
                      )
                  ])
            ]);
        add(rectangle);
      }
    }
  }
}

class YellowGridComponent extends PositionComponent {
  YellowGridComponent({
    required double size,
  }) : super(
          size: Vector2.all(size),
        ) {
    _createGrid();
  }

  // Function to create the grid of rectangles
  void _createGrid() {
    //Vector2 rectangleSize = Vector2(20, 20); // Size of each square
    double spacing = 0; // Vertical spacing between rectangles
    double columnSpacing = 0; // Horizontal spacing between columns

    int numberOfRows = 3;
    int numberOfColumns = 6;

    // Loop to create 3 rows of 6 squares each
    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.transparent;
        if (row == 1 && col < 5 || row == 2 && col == 4) {
          color = Colors.yellow;
        }
        var rectangle = RectangleComponent(
            position: Vector2(
                col * (size.x + columnSpacing), row * (size.y + spacing)),
            size: size,
            paint: Paint()..color = color,
            children: [
              RectangleComponent(
                  size: size,
                  paint: Paint()
                    ..color = Colors.transparent // Keep interior transparent
                    ..style = PaintingStyle.stroke // Set style to stroke
                    ..strokeWidth = 0.6 // Set border width
                    ..color = Colors.black, // Set border color to black
                  children: [
                    if (row == 0 && col == 3)
                      StarComponent(
                          size: size,
                          innerRadius: size.x * 0.24,
                          outerRadius: size.x * 0.48),
                    if (col == 5 && row == 1)
                      ArrowIconComponent(
                        icon: Icons.west,
                        size: size.x * 0.90,
                        position: Vector2(size.x * 0.05,
                            size.x * 0.05), // Font size of the arrow
                        borderColor: Colors.yellow, // Color of the arrow
                      )
                  ])
            ]);
        add(rectangle);
      }
    }
  }
}

class HomePlate extends RectangleComponent {
  // Constructor to initialize the square with size, position, and optional paint
  HomePlate({
    required double size,
    required Vector2 position,
    required Paint? homeSpotColor,
  }) : super(
          size: Vector2.all(size),
          position: position,
          // First paint object for the fill (white color)
          paint: Paint()..color = Colors.white,
          children: [
            // Define border as a separate child component for the stroke
            RectangleComponent(
              size: Vector2.all(size),
              paint: Paint()
                ..color = Colors.transparent // Keep interior transparent
                ..style = PaintingStyle.stroke // Set style to stroke
                ..strokeWidth = 1.0 // Set border width
                ..color = Colors.black, // Set border color to black
            ),
            HomeSpotContainer(
              size: size / 1.5,
              position: position / 1.5,
              homeSpotColor: homeSpotColor,
              radius: size / 8,
            ),
          ],
        );
}

class HomeSpotContainer extends RectangleComponent {
  HomeSpotContainer({
    required double size,
    required Vector2 position,
    required Paint? homeSpotColor,
    required double radius,
  }) : super(
          size: Vector2.all(size),
          position: position,
          paint: Paint()..color = Colors.transparent,
          children: [
            HomeSpot(
              radius: radius,
              position: Vector2(0, 0), // Top-left corner
              paint: homeSpotColor,
            ),
            HomeSpot(
              radius: radius,
              position: Vector2(size - radius * 2, 0.0), // Top-right corner
              paint: homeSpotColor,
            ),
            HomeSpot(
              radius: radius,
              position: Vector2(0, size - radius * 2), // Bottom-left corner
              paint: homeSpotColor,
            ),
            HomeSpot(
              radius: radius,
              position: Vector2(
                  size - radius * 2, size - radius * 2), // Bottom-right corner
              paint: homeSpotColor,
            ),
          ],
        );
}

class HomeSpot extends CircleComponent {
  // Constructor to initialize the square with size, position, and optional paint
  HomeSpot({
    required double radius,
    required Vector2 position,
    required Paint? paint,
  }) : super(
          radius: radius,
          position: position,
          paint: paint ?? Paint(),
          children: [
            // Add a child CircleComponent to draw the border
            CircleComponent(
              radius: radius,
              paint: Paint()
                ..color = Colors.transparent // Keep interior transparent
                ..style = PaintingStyle.stroke // Set to stroke for the border
                ..strokeWidth = 1.0 // Set border width
                ..color = Colors.black, // Set border color to black
            ),
          ],
        );
}
