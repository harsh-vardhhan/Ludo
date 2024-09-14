library;

import 'dart:async';
import 'dart:math' as math;

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
                Color(0xffa9d6e5),
                Color(0xfff2e8cf),
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
                    height: screenWidth,
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

class Ludo extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  Ludo();

  final rand = math.Random();
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
    world.add(PlayArea());
    startGame();
  }

  void startGame() {
    // Get the screen width and height
    final screenSize = size;
    final double screenWidth = screenSize.x;

    // Define the percentage widths for the components in each row
    final double firstComponentWidth = screenWidth * 0.40;
    final double secondComponentWidth = screenWidth * 0.20;
    final double thirdComponentWidth = screenWidth * 0.40;

    final double firstRowHeight = screenWidth * 0.40;
    final double secondRowHeight = screenWidth * 0.20;

    // Spacing between components
    const double horizontalSpacing = 0.0;

    const rowOne = 0;

    final firstComponent = RectangleComponent(
        size: Vector2(
            firstComponentWidth, firstRowHeight), // Assign color based on row
        position: Vector2(0, rowOne * firstRowHeight),
        children: [
          Home(
            size: firstComponentWidth, // Top-left corner
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
      size: Vector2(
          firstComponentWidth, secondRowHeight), // Assign color based on row
      position: Vector2(0, rowTwo * firstRowHeight),
      children: [
        RedGridComponent(size: firstComponentWidth * 0.1666)
      ]
    );

    final fifthComponent = RectangleComponent(
      size: Vector2(secondComponentWidth, secondRowHeight),
      position: Vector2(
          firstComponentWidth + horizontalSpacing, rowTwo * firstRowHeight),
    );

    final sixthComponent = RectangleComponent(
      size: Vector2(thirdComponentWidth, secondRowHeight),
      position: Vector2(
          firstComponentWidth + secondComponentWidth + 2 * horizontalSpacing,
          rowTwo * firstRowHeight),
      children: [
        YellowGridComponent(size: firstComponentWidth * 0.1666)
      ]
    );

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
      children: [BlueGridComponent(size: secondComponentWidth * 0.3333)]
    );

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

    world.add(firstComponent);
    world.add(secondComponent);
    world.add(thirdComponent);

    world.add(fourthComponent);
    world.add(fifthComponent);
    world.add(sixthComponent);

    world.add(seventhComponent);
    world.add(eigthComponent);
    world.add(ninthComponent);
  }

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
  Color backgroundColor() => const Color(0xfff2e8cf);
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
              )
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
        if (col == 0 && row == 4 ||  col == 1 && row < 5) {
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
              )
            ]);
        add(rectangle);
      }
    }
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
              )
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
              )
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
