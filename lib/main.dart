library;

import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/geometry.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late Ludo game;
  int? selectedPlayerCount;

  @override
  void initState() {
    super.initState();
    // Don't initialize the game yet; wait for player selection
  }

  void startGame(int? playerCount) {
    setState(() {
      if (playerCount != null) {
        selectedPlayerCount = playerCount;
        game = Ludo(selectedPlayerCount!); // Use the non-nullable value
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // If the player count hasn't been selected, show the menu
    if (selectedPlayerCount == null) {
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Number of Players',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => startGame(2),
                    child: Text('2 Players'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => startGame(3),
                    child: Text('3 Players'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => startGame(4),
                    child: Text('4 Players'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // If the player count is selected, display the game
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

const showId = false;
const blueTokenPath = [
  'B04',
  'B03',
  'B02',
  'B01',
  'B00',
  'R52',
  'R42',
  'R32',
  'R22',
  'R12',
  'R02',
  'R01',
  'R00',
  'R10',
  'R20',
  'R30',
  'R40',
  'R50',
  'G05',
  'G04',
  'G03',
  'G02',
  'G01',
  'G00',
  'G10',
  'G20',
  'G21',
  'G22',
  'G23',
  'G24',
  'G25',
  'Y00',
  'Y10',
  'Y20',
  'Y30',
  'Y40',
  'Y50',
  'Y51',
  'Y52',
  'Y42',
  'Y32',
  'Y22',
  'Y12',
  'Y02',
  'B20',
  'B21',
  'B22',
  'B23',
  'B24',
  'B25',
  'B15',
  'B14',
  'B13',
  'B12',
  'B11',
  'B10',
];

const greenTokenPath = [
  'G21',
  'G22',
  'G23',
  'G24',
  'G25',
  'Y00',
  'Y10',
  'Y20',
  'Y30',
  'Y40',
  'Y50',
  'Y51',
  'Y52',
  'Y42',
  'Y32',
  'Y22',
  'Y12',
  'Y02',
  'B20',
  'B21',
  'B22',
  'B23',
  'B24',
  'B25',
  'B15',
  'B05',
  'B04',
  'B03',
  'B02',
  'B01',
  'B00',
  'R52',
  'R42',
  'R32',
  'R22',
  'R12',
  'R02',
  'R01',
  'R00',
  'R10',
  'R20',
  'R30',
  'R40',
  'R50',
  'G05',
  'G04',
  'G03',
  'G02',
  'G01',
  'G00',
  'G10',
  'G11',
  'G12',
  'G13',
  'G14',
  'G15',
];

class GameState {
  // Private constructor
  GameState._();

  // Singleton instance
  static final GameState _instance = GameState._();

  List<int> diceChances = List.filled(3, 0, growable: false);
  int consecutiveSixes = 0; // Track consecutive 6s
  var diceNumber = 5;
  List<Player> players = [];
  int currentPlayerIndex = 0;

  // Factory method to access the instance
  factory GameState() {
    return _instance;
  }

  void rotateTurn() {
    // Mark current player as not having their turn anymore
    players[currentPlayerIndex].isCurrentTurn = false;
    do {
      // Move to the next player
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } while (!players[currentPlayerIndex].isActive ||
        players[currentPlayerIndex].hasWon);
    // Mark the next player as the current player
    players[currentPlayerIndex].isCurrentTurn = true;
    print(currentPlayerIndex);
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
  int diceValue; // dice value from 1 to 6

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

  // Method to update the dice value and re-render
  void updateDiceValue(int newDiceValue) {
    diceValue = newDiceValue;
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

void openToken(Token token, List<String> blueTokenPath, LudoBoard ludoBoard) {
  token.positionId = blueTokenPath.first;
  List<Spot> allSpots = SpotManager().getSpots();

  // Return a default Spot if not found
  Spot spotB04 = allSpots.firstWhere(
    (spot) => spot.uniqueId == blueTokenPath.first,
    orElse: () => Spot(
      uniqueId: 'default', // Default values
      position: Vector2.zero(),
      size: Vector2(10, 10),
      paint: Paint()..color = Colors.grey, // Grey for default spot
    ),
  );

  // Proceed with logic using spotB04
  final targetPosition = Vector2(
    spotB04.absolutePosition.x +
        (token.size.x * 0.10) -
        ludoBoard.absolutePosition.x,
    spotB04.absolutePosition.y -
        (token.size.x * 0.50) -
        ludoBoard.absolutePosition.y,
  );

  final moveToEffect = MoveToEffect(
    targetPosition,
    EffectController(duration: 0.1, curve: Curves.easeInOut),
  );

  token.add(moveToEffect);
}

class LudoDice extends PositionComponent with TapCallbacks {
  final gameState = GameState();
  final double faceSize; // size of the square
  late final double borderRadius; // radius of the curved edges
  late final double innerRectangleWidth; // width of the inner rectangle
  late final double innerRectangleHeight; // height of the inner rectangle

  late final RectangleComponent innerRectangle; // inner rectangle component
  late final DiceFaceComponent diceFace; // The dice face showing dots

  final Player player;
  final Random _random = Random(); // Random number generator


  @override
  Future<void> onTapDown(TapDownEvent event) async {
    final gameState = GameState();

    if (player.isCurrentTurn) {
      // Generate a random number between 1 and 6
      int newDiceValue = _random.nextInt(6) + 1;

      gameState.diceNumber = newDiceValue;
      diceFace.updateDiceValue(newDiceValue);

      // Apply a rotate effect to the dice when tapped
      add(
        RotateEffect.by(
          tau, // Full 360-degree rotation (2π radians)
          EffectController(
            duration: 0.5,
            curve: Curves.easeInOut,
          ), // Rotation duration and curve
        ),
      );

      final playerId = player.playerId[gameState.currentPlayerIndex];

      List<Token> allTokens = TokenManager().getAllTokens(playerId);
      List<Token> openTokens = TokenManager().getOpenTokens(playerId);
      List<Token> closeTokens = TokenManager().getCloseTokens(playerId);
      List<String> tokenPath = TokenManager().getTokenPath(playerId);

      final world = parent?.parent?.parent?.parent?.parent;

      if (world is World) {
        final ludoBoard = world.children.whereType<LudoBoard>().first;

        if (gameState.diceNumber == 6) {
          gameState.consecutiveSixes++;
          if (gameState.consecutiveSixes < 3) {
            if (openTokens.isEmpty) {
              // first open position
              final token = allTokens.first;
              token.state = TokenState.onBoard;
              openToken(token, tokenPath, ludoBoard);
            } else {
              // dice number is 6 and open token exists
              if (openTokens.singleOrNull != null && closeTokens.isEmpty) {
                // single open token & no close tokens
                final token = openTokens.first;
                await moveToken(
                  token: token,
                  tokenPath: tokenPath,
                  diceNumber: gameState.diceNumber,
                  ludoBoard: ludoBoard,
                );
              } else if (openTokens.singleOrNull != null &&
                  closeTokens.isNotEmpty) {
                // single open token & some close tokens
              } else if (openTokens.isNotEmpty) {
                // mutliple open tokens
                multiMoveToken(
                  openTokens: openTokens,
                  tokenPath: tokenPath,
                  gameState: gameState,
                  ludoBoard: ludoBoard,
                );
              }
            }
          } else {
            gameState.consecutiveSixes = 0;
            gameState.rotateTurn();
          }
        } else {
          // non six dice number
          if (openTokens.singleOrNull != null) {
            // moving position for single open token
            final token = openTokens.first;

            await moveToken(
              token: token,
              tokenPath: tokenPath,
              diceNumber: gameState.diceNumber,
              ludoBoard: ludoBoard,
            );
          } else {
            // multiple open position
            // check if open positions have space to move
            multiMoveToken(
              openTokens: openTokens,
              tokenPath: tokenPath,
              gameState: gameState,
              ludoBoard: ludoBoard,
            );
          }
          gameState.rotateTurn();
        }
      }
    }
  }

  LudoDice({required this.faceSize, required this.player}) {
    // Calculate properties based on faceSize
    borderRadius = faceSize / 5;
    innerRectangleWidth = faceSize * 0.9;
    innerRectangleHeight = faceSize * 0.9;

    // Initialize the size of the component
    size = Vector2.all(faceSize);

    // Set the anchor to center for center rotation
    anchor = Anchor.center;

    // Initialize the dice face component
    diceFace = DiceFaceComponent(faceSize: innerRectangleWidth, diceValue: 6);

    // Initialize the inner rectangle component
    innerRectangle = RectangleComponent(
      size: Vector2(innerRectangleWidth, innerRectangleHeight),
      position: Vector2(
          (faceSize - innerRectangleWidth) / 2, // Center horizontally
          (faceSize - innerRectangleHeight) / 2 // Center vertically
          ),
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

class UpperController extends RectangleComponent with HasGameReference<Ludo> {
  UpperController({
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
        paint: Paint()..color = Color(0xFFFF8C9E),
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
        paint: Paint()..color = Color(0xFFFF8C9E),
        children: [
          RectangleComponent(
              size: Vector2(innerWidth * 0.4, innerHeight),
              paint: Paint()
                ..color = Colors.transparent
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4.0
                ..color = Color(0xFF03346E)),
        ] // Adjust color as needed
        );

    final rightDice = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight),
        position: Vector2(width - innerWidth * 0.8, 0), // Sticks to the right
        paint: Paint()..color = Color(0xFFC0EBA6),
        children: [
          RectangleComponent(
              size: Vector2(innerWidth * 0.4, innerHeight),
              paint: Paint()
                ..color = Colors.transparent
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4.0
                ..color = Color(0xFF03346E),
              children: [
                RectangleComponent(
                    position: Vector2(innerWidth * 0.20, innerHeight * 0.5)),
              ])
        ]);

    final rightToken = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
        position: Vector2(width - innerWidth * 0.4 - 2.5, innerWidth * 0.05),
        paint: Paint()..color = Color(0xFFC0EBA6),
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

class LowerController extends RectangleComponent with HasGameReference<Ludo> {
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
    final gameState = GameState();

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
                RectangleComponent(
                    position: Vector2(innerWidth * 0.20, innerHeight * 0.5)),
              ]),
        ] // Adjust color as needed
        );

    final rightDice = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight),
        position: Vector2(width - innerWidth * 0.8, 0), // Sticks to the right
        paint: Paint()..color = Color(0xFFFCDE70),
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
        paint: Paint()..color = Color(0xFFFCDE70),
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

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();

  TokenManager._internal();

  factory TokenManager() {
    return _instance;
  }

  List<Token> allTokens = [];

  void initializeTokens(Map<String, String> tokenToHomeSpotMap) {
    for (var entry in tokenToHomeSpotMap.entries) {
      final token = Token(
          uniqueId: entry.key,
          positionId: entry.value,
          position: Vector2(100, 100), // Adjust position
          size: Vector2(50, 50), // Adjust size
          innerCircleColor: Colors.transparent);
      allTokens.add(token);
    }
  }

  List<Token> getAllTokens(player) {
    return allTokens
        .where((token) => token.uniqueId.startsWith(player))
        .toList();
  }

  List<Token> getOpenTokens(player) {
    return allTokens
        .where((token) =>
            token.uniqueId.startsWith(player) && token.positionId.length == 3)
        .toList();
  }

  List<Token> getCloseTokens(player) {
    return allTokens
        .where((token) =>
            token.uniqueId.startsWith(player) && token.positionId.length == 2)
        .toList();
  }

  List<String> getTokenPath(player) {
    if (player == 'B') {
      return blueTokenPath;
    } else if (player == 'G') {
      return greenTokenPath;
    } else {
      return [];
    }
  }

  // Get all tokens whose uniqueId starts with 'B'
  List<Token> getBlueTokens() {
    return allTokens.where((token) => token.uniqueId.startsWith('B')).toList();
  }

  // Get all tokens whose uniqueId starts with 'B'
  List<Token> getGreenTokens() {
    return allTokens.where((token) => token.uniqueId.startsWith('G')).toList();
  }
}

class Player {
  String playerId;
  List<Token> tokens; // Tokens belonging to the player
  bool isActive; // Is the player still active in the game?
  bool isCurrentTurn; // Is it the player's turn right now?
  int score; // Player's current score
  int totalTokensInHome; // Number of tokens in the home position
  bool hasWon; // Has the player won the game?

  // Constructor to initialize the player's attributes
  Player({
    required this.playerId,
    required this.tokens,
    this.isActive = true, // Default: player is active when initialized
    this.isCurrentTurn = false, // Default: not the player's turn initially
    this.score = 0, // Default: score starts at 0
    this.totalTokensInHome = 0, // Default: no tokens in home initially
    this.hasWon = false, // Default: player hasn't won yet
  });
  
  // Helper method to check if all tokens are in base
  bool allTokensInBase() {
    return tokens.every((token) => token.isInBase());
  }

  // Helper method to get the tokens that are on the board
  List<Token> getTokensOnBoard() {
    return tokens.where((token) => token.isOnBoard()).toList();
  }

  // Helper method to check if only one token is on the board
  bool hasOneTokenOnBoard() {
    return getTokensOnBoard().length == 1;
  }

  // Helper method to check if there are multiple tokens on the board
  bool hasMultipleTokensOnBoard() {
    return getTokensOnBoard().length > 1;
  }

}

class Ludo extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  int playerCount;

  Ludo(this.playerCount) {
    print(playerCount);
  }

  final rand = Random();
  double get width => size.x;
  double get height => size.y;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    camera = CameraComponent.withFixedResolution(
      width: width,
      height: height,
    );
    camera.viewfinder.anchor = Anchor.topLeft;
    //world.add(camera);
    // world.add(PlayArea());
    // Now you can set up the camera with the screen size
    world.add(UpperController(
        position: Vector2(0, width * 0.05),
        width: width,
        height: width * 0.20));
    world.add(LudoBoard(
        width: width, height: width, position: Vector2(0, height * 0.175)));
    world.add(LowerController(
        position: Vector2(0, width + (width * 0.35)),
        width: width,
        height: width * 0.20));
  }

  void startGame() {
    final gameState = GameState();
    final ludoBoard = world.children.whereType<LudoBoard>().first;
    final childrenOfLudoBoard = ludoBoard.children.toList();

    if (TokenManager().getBlueTokens().isEmpty) {
      final tokenToHome = {
        'BT1': 'B1',
        'BT2': 'B2',
        'BT3': 'B3',
        'BT4': 'B4',
      };
      TokenManager().initializeTokens(tokenToHome);

      final child = childrenOfLudoBoard[6];
      final home = child.children.toList();
      final homePlate = home[0].children.toList();
      final homeSpotContainer = homePlate[1].children.toList();
      final homeSpotList = homeSpotContainer[1].children.toList();

      for (var token in TokenManager().getBlueTokens()) {
        final homeSpot = homeSpotList
            .whereType<HomeSpot>()
            .firstWhere((spot) => spot.uniqueId == token.positionId);
        token.innerCircleColor = Colors.blue;
        token.position = Vector2(
          homeSpot.absolutePosition.x +
              (homeSpot.size.x * 0.10) -
              ludoBoard.absolutePosition.x,
          homeSpot.absolutePosition.y -
              (homeSpot.size.x * 0.50) -
              ludoBoard.absolutePosition.y,
        );
        token.size = Vector2(homeSpot.size.x * 0.80, homeSpot.size.x * 1.05);
        ludoBoard.add(token);
      }

      if (gameState.players.isEmpty) {
        Player bluePlayer = Player(
          playerId: 'BP',
          tokens: TokenManager().getBlueTokens(),
          isCurrentTurn: true,
        );
        gameState.players.add(bluePlayer);
      } else {
        Player bluePlayer = Player(
          playerId: 'BP',
          tokens: TokenManager().getBlueTokens(),
        );
        gameState.players.add(bluePlayer);
      }

      final player =
          gameState.players.firstWhere((player) => player.playerId == 'BP');

      // dice for player blue
      final lowerController = world.children.whereType<LowerController>().first;
      final lowerControllerComponents = lowerController.children.toList();
      final leftDice = lowerControllerComponents[0]
          .children
          .whereType<RectangleComponent>()
          .first;
      final leftDiceContainer =
          leftDice.children.whereType<RectangleComponent>().first;

      leftDiceContainer.add(LudoDice(
        player: player,
        faceSize: leftDice.size.x * 0.70,
      ));
    }

    if (TokenManager().getGreenTokens().isEmpty) {
      final tokenToHome = {
        'GT1': 'G1',
        'GT2': 'G2',
        'GT3': 'G3',
        'GT4': 'G4',
      };
      TokenManager().initializeTokens(tokenToHome);

      final child = childrenOfLudoBoard[2];
      final home = child.children.toList();
      final homePlate = home[0].children.toList();
      final homeSpotContainer = homePlate[1].children.toList();
      final homeSpotList = homeSpotContainer[1].children.toList();

      for (var token in TokenManager().getGreenTokens()) {
        final homeSpot = homeSpotList
            .whereType<HomeSpot>()
            .firstWhere((spot) => spot.uniqueId == token.positionId);
        token.innerCircleColor = Colors.green;
        token.position = Vector2(
          homeSpot.absolutePosition.x +
              (homeSpot.size.x * 0.10) -
              ludoBoard.absolutePosition.x,
          homeSpot.absolutePosition.y -
              (homeSpot.size.x * 0.50) -
              ludoBoard.absolutePosition.y,
        );
        token.size = Vector2(homeSpot.size.x * 0.80, homeSpot.size.x * 1.05);
        ludoBoard.add(token);
      }

      if (gameState.players.isEmpty) {
        Player greenPlayer = Player(
          playerId: 'GP',
          tokens: TokenManager().getBlueTokens(),
          isCurrentTurn: true,
        );
        gameState.players.add(greenPlayer);
      } else {
        Player greenPlayer = Player(
          playerId: 'GP',
          tokens: TokenManager().getBlueTokens(),
        );
        gameState.players.add(greenPlayer);
      }

      final player =
          gameState.players.firstWhere((player) => player.playerId == 'GP');

      // dice for player green
      final upperController = world.children.whereType<UpperController>().first;
      final upperControllerComponents = upperController.children.toList();
      final rightDice = upperControllerComponents[2]
          .children
          .whereType<RectangleComponent>()
          .first;
      final rightDiceContainer =
          rightDice.children.whereType<RectangleComponent>().first;

      rightDiceContainer.add(LudoDice(
        player: player,
        faceSize: rightDice.size.x * 0.70,
      ));
    }
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
        print('test');
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

class Home extends RectangleComponent {
  Home(
      {required double size,
      required Paint? paint,
      required Paint homeSpotColor,
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
          ..strokeWidth = size.x * 0.035 {
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

void multiMoveToken({
  required List<Token> openTokens,
  required List<String> tokenPath,
  required GameState gameState,
  required LudoBoard ludoBoard,
}) {
  final tokens = openTokens.iterator;
  final pathSize = tokenPath.length;
  List<Token> movableTokens = [];

  // Iterate through each token and determine if it can move
  while (tokens.moveNext()) {
    final token = tokens.current;
    final index = tokenPath.indexOf(token.positionId);
    if (index != -1) {
      final distance = pathSize - index;
      if (distance > gameState.diceNumber) {
        movableTokens.add(token); // Add the token to the list if it's movable
      }
    }
  }

  // Check if multiple tokens are movable
  if (movableTokens.length > 1) {
    // gameState.enableBlueToken = true; // Enable token movement
  } else if (movableTokens.length == 1) {
    final token = movableTokens.first;
    moveToken(
      token: token,
      tokenPath: tokenPath,
      diceNumber: gameState.diceNumber,
      ludoBoard: ludoBoard,
    );
  }
}

Future<void> _applyEffect(PositionComponent component, Effect effect) {
  final completer = Completer<void>();
  effect.onComplete = completer.complete;
  component.add(effect);
  return completer.future;
}

Future<void> moveToken({
  required Token token,
  required List<String> tokenPath,
  required int diceNumber,
  required PositionComponent
      ludoBoard, // Ensure ludoBoard is a PositionComponent
}) async {
  List<Spot> allSpots = SpotManager().getSpots();
  // Get the current and final index
  final currentIndex = tokenPath.indexOf(token.positionId);
  final finalIndex = currentIndex + diceNumber;
  final originalSize = token.size.clone();

  // Loop through the positions from current to final index
  for (int i = currentIndex; i <= finalIndex; i++) {
    if (i < tokenPath.length) {
      String positionId = tokenPath[i];
      token.positionId = positionId;

      // Find the corresponding spot using positionId
      final spot = allSpots.firstWhere((spot) => spot.uniqueId == positionId);

      // Calculate target position for the token based on the spot's absolute position
      final spotGlobalPosition = spot.absolutePositionOf(Vector2.zero());
      final ludoBoardGlobalPosition =
          ludoBoard.absolutePositionOf(Vector2.zero());

      final targetPosition = Vector2(
        spotGlobalPosition.x +
            (token.size.x * 0.10) -
            ludoBoardGlobalPosition.x,
        spotGlobalPosition.y -
            (token.size.x * 0.50) -
            ludoBoardGlobalPosition.y,
      );

      // Apply size increase effect
      await _applyEffect(
        token,
        SizeEffect.to(
          Vector2(
            originalSize.x * 1.30,
            originalSize.y * 1.30,
          ), // Increase by 10% of original size
          EffectController(duration: 0.05),
        ),
      );

      // Move the token to the target position
      await _applyEffect(
        token,
        MoveToEffect(
          targetPosition,
          EffectController(duration: 0.05, curve: Curves.easeInOut),
        ),
      );

      // Restore token to original size
      await _applyEffect(
        token,
        SizeEffect.to(
          originalSize, // Restore to original size
          EffectController(duration: 0.05),
        ),
      );

      // Add a delay between each move (optional)
      await Future.delayed(Duration(milliseconds: 300));
    }
  }
}

// Enum to define token states
enum TokenState {
  inBase,
  onBoard,
  inHome,
}

class Token extends PositionComponent with TapCallbacks {
  final String uniqueId; // Mandatory unique ID for the token
  String positionId; // Mandatory position ID for the token
  TokenState state;

  final Paint borderPaint;
  final Paint transparentPaint;
  final Paint fillPaint;
  final Paint dropletFillPaint; // Paint for filling the inside of the droplet
  Color _innerCircleColor;

  Token({
    required this.uniqueId, // Mandatory uniqueId
    required this.positionId, // Mandatory positionId
    required Vector2 position, // Position of the token
    required Vector2 size, // Size of the token
    required Color innerCircleColor, // Mandatory inner fill color
    Color borderColor = Colors.black, // Default border color
    Color dropletFillColor = Colors.white, // Default droplet fill color
    this.state = TokenState.inBase,
  })  : _innerCircleColor = innerCircleColor,
        borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.05
          ..color = borderColor,
        transparentPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = Colors.transparent, // Transparent line
        fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = innerCircleColor, // Use the passed innerCircleColor
        dropletFillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = dropletFillColor, // Paint for filling droplet
        super(position: position, size: size);

  bool isInBase() => state == TokenState.inBase;
  bool isOnBoard() => state == TokenState.onBoard;
  bool isInHome() => state == TokenState.inHome;
  
  // Setter for innerCircleColor, updates the fillPaint color
  set innerCircleColor(Color color) {
    _innerCircleColor = color;
    fillPaint.color = color; // Update the paint color when the color changes
  }

  @override
  Future<void> onTapDown(TapDownEvent event) async {
    final gameState = GameState();
      List<Token> blueTokens = TokenManager().getBlueTokens();
      final token = blueTokens.firstWhere((t) => t.uniqueId == uniqueId);
      final world = parent?.parent;
      if (world is World) {
        final ludoBoard = world.children.whereType<LudoBoard>().first;
        if (blueTokenPath.contains(token.positionId)) {
          // moving position
          moveToken(
              token: token,
              tokenPath: blueTokenPath,
              diceNumber: gameState.diceNumber,
              ludoBoard: ludoBoard);
        } else {
          if (gameState.diceNumber == 6) {
            // opening position
            openToken(token, blueTokenPath, ludoBoard);
          }
        }
      }
  }

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

        // Create the unique ID for this block
        String uniqueId = 'G$col$row';

        var rectangle = Spot(
          uniqueId: uniqueId,
          position:
              Vector2(col * (size.x + columnSpacing), row * (size.x + spacing)),
          size: size,
          paint: Paint()..color = color,
          children: [
            // Border Rectangle
            RectangleComponent(
              size: size,
              paint: Paint()
                ..color = Colors.transparent // Keep interior transparent
                ..style = PaintingStyle.stroke // Set style to stroke
                ..strokeWidth = size.x * 0.025 // Set border width
                ..color = Colors.black, // Set border color to black
              children: [
                if (col == 0 && row == 2)
                  StarComponent(
                    size: size,
                    innerRadius: size.x * 0.24,
                    outerRadius: size.x * 0.48,
                  ),
                if (col == 1 && row == 0)
                  ArrowIconComponent(
                    icon: Icons.south,
                    size: size.x * 0.90,
                    position: Vector2(size.x * 0.05, size.x * 0.05),
                    borderColor: Colors.green,
                  ),
                // Add the unique ID as a text label at the center
                if (showId)
                  TextComponent(
                    text: uniqueId,
                    position: Vector2(size.x / 2, size.y / 2),
                    anchor: Anchor.center,
                    textRenderer: TextPaint(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.x * 0.4, // Adjust font size as needed
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
        add(rectangle);
      }
    }
  }
}

class SpotManager {
  static final SpotManager _instance = SpotManager._internal();
  final List<Spot> spots = [];

  SpotManager._internal();

  factory SpotManager() {
    return _instance;
  }

  void addSpot(Spot spot) {
    spots.add(spot);
  }

  List<Spot> getSpots() {
    return List.unmodifiable(spots);
  }
}

class Spot extends RectangleComponent {
  final String uniqueId;

  Spot({
    required this.uniqueId,
    required Vector2 position,
    required Vector2 size,
    required Paint paint,
    List<Component>? children,
  }) : super(
          position: position,
          size: size,
          paint: paint,
          children: children ?? [],
        ) {
    SpotManager().addSpot(this);
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

        // Create the unique ID for this block
        String uniqueId = 'B$col$row';

        var rectangle = Spot(
          uniqueId: uniqueId,
          position:
              Vector2(col * (size.x + columnSpacing), row * (size.x + spacing)),
          size: size,
          paint: Paint()..color = color,
          children: [
            // Border Rectangle
            RectangleComponent(
              size: size,
              paint: Paint()
                ..color = Colors.transparent // Keep interior transparent
                ..style = PaintingStyle.stroke // Set style to stroke
                ..strokeWidth = size.x * 0.025 // Set border width
                ..color = Colors.black, // Set border color to black
              children: [
                if (col == 2 && row == 3)
                  StarComponent(
                    size: size,
                    innerRadius: size.x * 0.24,
                    outerRadius: size.x * 0.48,
                  ),
                if (col == 1 && row == 5)
                  ArrowIconComponent(
                    icon: Icons.north,
                    size: size.x * 0.90,
                    position: Vector2(size.x * 0.05, size.x * 0.05),
                    borderColor: Colors.blue,
                  ),
                // Add the unique ID as a text label at the center
                if (showId)
                  TextComponent(
                    text: uniqueId,
                    position: Vector2(size.x / 2, size.x / 2),
                    anchor: Anchor.center,
                    textRenderer: TextPaint(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.x * 0.4, // Adjust font size as needed
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
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
    required double
        size, // Allows toggling the visibility of the unique ID labels
  }) : super(
          size: Vector2.all(size),
        ) {
    _createGrid();
  }

  // Function to create the grid of rectangles
  void _createGrid() {
    double spacing = 0; // Vertical spacing between rectangles
    double columnSpacing = 0; // Horizontal spacing between columns

    int numberOfRows = 3;
    int numberOfColumns = 6;

    // Loop to create 6 columns of 3 squares each
    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.transparent;
        if (row == 0 && col == 1 || row == 1 && col > 0) {
          color = Colors.red;
        }

        // Create the unique ID for this block
        String uniqueId = 'R$col$row';

        var rectangle = Spot(
          uniqueId: uniqueId,
          position:
              Vector2(col * (size.x + columnSpacing), row * (size.x + spacing)),
          size: Vector2.all(size.x), // Adjusting size to size.x
          paint: Paint()..color = color,
          children: [
            // Border Rectangle
            RectangleComponent(
              size: Vector2.all(size.x), // Adjusting size to size.x
              paint: Paint()
                ..color = Colors.transparent // Keep interior transparent
                ..style = PaintingStyle.stroke // Set style to stroke
                ..strokeWidth = size.x * 0.025 // Set border width
                ..color = Colors.black, // Set border color to black
              children: [
                if (col == 2 && row == 2)
                  StarComponent(
                    size: size, // Adjusting size to size.x
                    innerRadius: size.x * 0.24,
                    outerRadius: size.x * 0.48,
                  ),
                if (col == 0 && row == 1)
                  ArrowIconComponent(
                    icon: Icons.east,
                    size: size.x * 0.90,
                    position: Vector2(size.x * 0.05, size.x * 0.05),
                    borderColor: Colors.red,
                  ),
                // Add the unique ID as a text label at the center
                if (showId)
                  TextComponent(
                    text: uniqueId,
                    position: Vector2(size.x / 2, size.x / 2),
                    anchor: Anchor.center,
                    textRenderer: TextPaint(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.x * 0.4, // Adjust font size as needed
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
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
    double spacing = 0; // Vertical spacing between rectangles
    double columnSpacing = 0; // Horizontal spacing between columns

    int numberOfRows = 3;
    int numberOfColumns = 6;

    // Loop to create 6 columns of 3 squares each
    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        var color = Colors.transparent;
        if (row == 1 && col < 5 || row == 2 && col == 4) {
          color = Colors.yellow;
        }

        // Create the unique ID for this block
        String uniqueId = 'Y$col$row';

        var rectangle = Spot(
          uniqueId: uniqueId,
          position:
              Vector2(col * (size.x + columnSpacing), row * (size.y + spacing)),
          size: size,
          paint: Paint()..color = color,
          children: [
            // Border Rectangle
            RectangleComponent(
              size: size,
              paint: Paint()
                ..color = Colors.transparent // Keep interior transparent
                ..style = PaintingStyle.stroke // Set style to stroke
                ..strokeWidth = size.x * 0.025 // Set border width
                ..color = Colors.black, // Set border color to black
              children: [
                if (row == 0 && col == 3)
                  StarComponent(
                    size: size,
                    innerRadius: size.x * 0.24,
                    outerRadius: size.x * 0.48,
                  ),
                if (col == 5 && row == 1)
                  ArrowIconComponent(
                    icon: Icons.west,
                    size: size.x * 0.90,
                    position: Vector2(size.x * 0.05, size.x * 0.05),
                    borderColor: Colors.yellow,
                  ),
                // Add the unique ID as a text label at the center
                if (showId)
                  TextComponent(
                    text: uniqueId,
                    position: Vector2(size.x / 2, size.y / 2),
                    anchor: Anchor.center,
                    textRenderer: TextPaint(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.x * 0.4, // Adjust font size as needed
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
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
    required Paint homeSpotColor,
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
    required Paint homeSpotColor,
    required double radius,
  }) : super(
          size: Vector2.all(size),
          position: position,
          paint: Paint()..color = Colors.transparent,
        ) {
    _createHomeSpots(homeSpotColor, radius);
  }

  // Method to create home spots with unique IDs
  void _createHomeSpots(Paint homeSpotColor, double radius) {
    String colorCode = _getColorCode(homeSpotColor);

    for (int slotNumber = 1; slotNumber <= 4; slotNumber++) {
      String uniqueId = '$colorCode$slotNumber';

      HomeSpot homeSpot = HomeSpot(
        radius: radius,
        position: _getPositionForSlot(slotNumber, radius),
        paint: homeSpotColor,
        uniqueId: uniqueId, // Assign uniqueId to each HomeSpot
      );
      add(homeSpot);
    }
  }

  // Method to get the position for each slot
  Vector2 _getPositionForSlot(int slotNumber, double radius) {
    switch (slotNumber) {
      case 1:
        return Vector2(0, 0); // Top-left
      case 2:
        return Vector2(size.x - radius * 2, 0.0); // Top-right
      case 3:
        return Vector2(0, size.y - radius * 2); // Bottom-left
      case 4:
        return Vector2(
            size.x - radius * 2, size.y - radius * 2); // Bottom-right
      default:
        return Vector2(0, 0); // Default position
    }
  }

  // Helper method to get the color code from the Paint object
  String _getColorCode(Paint paint) {
    Color color = paint.color;
    String colorCode;

    if (color.value == const Color(0xfff44336).value) {
      colorCode = 'R';
    } else if (color.value == const Color(0xff4caf50).value) {
      colorCode = 'G';
    } else if (color.value == const Color(0xff2196f3).value) {
      colorCode = 'B';
    } else if (color.value == const Color(0xffffeb3b).value) {
      colorCode = 'Y';
    } else {
      colorCode = 'U'; // For unknown colors
    }

    return colorCode;
  }
}

class HomeSpot extends CircleComponent {
  final String uniqueId;

  HomeSpot({
    required double radius,
    required Vector2 position,
    required Paint paint,
    required this.uniqueId, // Accept uniqueId
  }) : super(
          radius: radius,
          position: position,
          paint: paint,
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
