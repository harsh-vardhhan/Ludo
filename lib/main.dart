library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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
  late final BrickBreaker game;

  @override
  void initState() {
    super.initState();
    game = BrickBreaker();
  }

  @override
  Widget build(BuildContext context) {
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
                    width: gameWidth,
                    height: gameHeight,
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

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  BrickBreaker()
      : super(
            camera: CameraComponent.withFixedResolution(
                width: gameWidth, height: gameHeight));

  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(PlayArea());
    startGame();
  }

  void startGame() {
    const gameWidth = 820.0;
    const gameHeight = 815.0;
    const homeSize = 310.0;
    final screenSize =
        Vector2(gameWidth, gameHeight); // Replace with your actual screen size

    world.add(Home(
      size: homeSize,
      position: Vector2(0, 0), // Top-left corner
      paint: Paint()..color = Colors.red,
      homeSpotColor: Paint()..color = Colors.red,
    ));

    world.add(Home(
      size: homeSize,
      position: Vector2(screenSize.x - homeSize, 0), // Top-right corner
      paint: Paint()..color = Colors.green,
      homeSpotColor: Paint()..color = Colors.green,
    ));

    world.add(Home(
      size: homeSize,
      position: Vector2(0, screenSize.y - homeSize), // Bottom-left corner
      paint: Paint()..color = Colors.blue,
      homeSpotColor: Paint()..color = Colors.blue,
    ));

    world.add(Home(
      size: homeSize,
      position: Vector2(screenSize.x - homeSize,
          screenSize.y - homeSize), // Bottom-right corner
      paint: Paint()..color = brickColors[4],
      homeSpotColor: Paint()..color = brickColors[4],
    ));
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

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
            radius: radius,
            anchor: Anchor.center,
            paint: Paint()
              ..color = const Color(0xff1e6091)
              ..style = PaintingStyle.fill,
            children: [CircleHitbox()]);

  final Vector2 velocity;
  final double difficultyModifier;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        add(RemoveEffect(
          delay: 0.35,
          onComplete: () {
            game.startGame();
          },
        ));
      }
    } else if (other is Paddle) {
      velocity.y = -velocity.y;
      velocity.x = velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
    } else if (other is Brick) {
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
      velocity.setFrom(velocity * difficultyModifier);
    }
  }
}

class Paddle extends PositionComponent
    with DragCallbacks, HasGameReference<BrickBreaker>, KeyboardHandler {
  Paddle({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center, children: [RectangleHitbox()]);

  final Radius cornerRadius;

  final _paint = Paint()
    ..color = const Color(0xff1e6091)
    ..style = PaintingStyle.fill;

  @override
  void update(double dt) {
    super.update(dt);

    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      position.x =
          (position.x - (dt * 500)).clamp(width / 2, game.width - width / 2);
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      position.x =
          (position.x + (dt * 500)).clamp(width / 2, game.width - width / 2);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size.toSize(),
        cornerRadius,
      ),
      _paint,
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isRemoved) return;
    super.onDragUpdate(event);
    position.x = (position.x + event.localDelta.x)
        .clamp(width / 2, game.width - width / 2);
  }
}

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Brick(Vector2 position, Color color)
      : super(
          position: position,
          size: Vector2(brickWidth, brickHeight),
          anchor: Anchor.center,
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.fill,
          children: [RectangleHitbox()],
        );

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    removeFromParent();

    if (game.world.children.query<Brick>().length == 1) {
      game.startGame();
    }
  }
}

class PlayArea extends RectangleComponent with HasGameReference<BrickBreaker> {
  PlayArea() : super(children: [RectangleHitbox()]);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);
  }
}

class Home extends RectangleComponent {
  Home(
      {required double size,
      required Vector2 position,
      required Paint? paint,
      required Paint? homeSpotColor,
      children})
      : super(
            size: Vector2.all(size),
            position: position,
            paint: paint ?? Paint(),
            children: [
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
              size: size * 0.6667,
              position: position * 0.6667,
              homeSpotColor: homeSpotColor,
              radius: size * 0.125,
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

const brickColors = [
  Color(0xfff94144),
  Color(0xfff3722c),
  Color(0xfff8961e),
  Color(0xfff9844a),
  Color(0xffFDDA0D),
  Color(0xff90be6d),
  Color(0xff43aa8b),
  Color(0xff4d908e),
  Color(0xff277da1),
  Color(0xff577590),
];

const gameWidth = 820.0;
const gameHeight = 815.0;
const ballRadius = gameWidth * 0.02;
const paddleWidth = gameWidth * 0.8;
const paddleHeight = ballRadius * 2;
const paddleStep = gameWidth * 0.05;
const brickGutter = gameWidth * 0.015;
final brickWidth =
    (gameWidth - (brickGutter * (brickColors.length + 1))) / brickColors.length;
const brickHeight = gameHeight * 0.03;
const difficultyModifier = 1.05;
