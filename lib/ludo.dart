import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

import 'state/player.dart';
import 'component/home/home.dart';
import 'state/token_manager.dart';
import 'state/event_bus.dart';
import 'component/home/home_spot.dart';
import 'state/game_state.dart';
import 'component/controller/upper_controller.dart';
import 'component/controller/lower_controller.dart';
import 'ludo_board.dart';
import 'component/ui_components/token.dart';
import 'component/ui_components/spot.dart';
import 'component/ui_components/ludo_dice.dart';

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

    EventBus().on<BlinkGreenBaseEvent>((event) {
      blinkGreenBase(true);
      blinkBlueBase(false); // Call your blinkGreenBase method
    });

    EventBus().on<BlinkBlueBaseEvent>((event) {
      blinkGreenBase(false);
      blinkBlueBase(true); // Call your blinkGreenBase method
    });
  }

  void blinkBlueBase(bool shouldBlink) {
    final ludoBoard = world.children.whereType<LudoBoard>().first;
    final childrenOfLudoBoard = ludoBoard.children.toList();
    final child = childrenOfLudoBoard[6];
    final home = child.children.toList();
    final homePlate = home[0] as Home;

    // Only add the blinking effect if shouldBlink is true
    if (shouldBlink) {
      final lightEffectForHome = ColorEffect(
        Color(0xFF4FC3F7),
        EffectController(
          duration: 0.2,
          reverseDuration: 0.2,
          infinite: true,
          alternate: true,
        ),
      );
      homePlate.add(lightEffectForHome);
    } else {
      final lightEffectForHome = ColorEffect(
        Colors.blue,
        EffectController(
          duration: 0.2,
          reverseDuration: 0.2,
          infinite: true,
          alternate: true,
        ),
      );
      homePlate.add(lightEffectForHome);
    }
  }

  void blinkGreenBase(bool shouldBlink) {
    final ludoBoard = world.children.whereType<LudoBoard>().first;
    final childrenOfLudoBoard = ludoBoard.children.toList();
    final child = childrenOfLudoBoard[2];
    final home = child.children.toList();
    final homePlate = home[0] as Home;

    // Only add the blinking effect if shouldBlink is true
    if (shouldBlink) {
      final lightEffectForHome = ColorEffect(
        Colors.lightGreen,
        EffectController(
          duration: 0.2,
          reverseDuration: 0.2,
          infinite: true,
          alternate: true,
        ),
      );
      homePlate.add(lightEffectForHome);
    } else {
      final lightEffectForHome = ColorEffect(
        Colors.green,
        EffectController(
          duration: 0.2,
          reverseDuration: 0.2,
          infinite: true,
          alternate: true,
        ),
      );
      homePlate.add(lightEffectForHome);
    }
  }

  void startGame() {
    final gameState = GameState();
    final ludoBoard = world.children.whereType<LudoBoard>().first;

    if (TokenManager().getBlueTokens().isEmpty) {
      final tokenToHome = {
        'BT1': 'B1',
        'BT2': 'B2',
        'BT3': 'B3',
        'BT4': 'B4',
      };
      TokenManager().initializeTokens(tokenToHome);

      for (var token in TokenManager().getBlueTokens()) {
        final homeSpot = getHomeSpot(world, 6)
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

      const playerId = 'BP';
      final tokens = TokenManager().getBlueTokens();

      if (gameState.players.isEmpty) {
        Player bluePlayer = Player(
          playerId: playerId,
          tokens: tokens,
          isCurrentTurn: true,
          enableDice: true,
        );
        blinkBlueBase(true);
        gameState.players.add(bluePlayer);
        for (var token in tokens) {
          token.player = bluePlayer;
        }
      } else {
        Player bluePlayer = Player(
          playerId: playerId,
          tokens: tokens,
        );
        gameState.players.add(bluePlayer);
        for (var token in tokens) {
          token.player = bluePlayer;
        }
      }

      final player =
          gameState.players.firstWhere((player) => player.playerId == playerId);

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

      for (var token in TokenManager().getGreenTokens()) {
        final homeSpot = getHomeSpot(world, 2)
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

      const playerId = 'GP';
      final tokens = TokenManager().getGreenTokens();

      if (gameState.players.isEmpty) {
        Player greenPlayer = Player(
          playerId: playerId,
          tokens: tokens,
          isCurrentTurn: true,
          enableDice: true,
        );
        blinkGreenBase(true);
        gameState.players.add(greenPlayer);
        for (var token in tokens) {
          token.player = greenPlayer;
        }
      } else {
        Player greenPlayer = Player(
          playerId: playerId,
          tokens: tokens,
        );
        gameState.players.add(greenPlayer);
        for (var token in tokens) {
          token.player = greenPlayer;
        }
      }

      final player =
          gameState.players.firstWhere((player) => player.playerId == playerId);

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

List<Component> getHomeSpot(world, i) {
  final ludoBoard = world.children.whereType<LudoBoard>().first;
  final childrenOfLudoBoard = ludoBoard.children.toList();
  final child = childrenOfLudoBoard[i];
  final home = child.children.toList();
  final homePlate = home[0].children.toList();
  final homeSpotContainer = homePlate[1].children.toList();
  final homeSpotList = homeSpotContainer[1].children.toList();
  return homeSpotList;
}

void moveOutOfBase({
  required World world,
  required Token token,
  required List<String> tokenPath,
  required LudoBoard ludoBoard,
}) {
  // Update token position to the first position in the path
  token.positionId = tokenPath.first;
  token.state = TokenState.onBoard;

  // Get the first spot (starting point) from the path
  Spot spot = findSpotById(tokenPath.first);

  // Calculate the target position on the board
  Vector2 targetPosition = calculateTargetPosition(token, spot, ludoBoard);

  // Apply the movement effect to move the token out of base
  applyMoveEffect(world, token, targetPosition);
}

void applyMoveEffect(World world, Token token, Vector2 targetPosition) async {
  final moveToEffect = MoveToEffect(
    targetPosition,
    EffectController(duration: 0.1, curve: Curves.easeInOut),
  );

  await token.add(moveToEffect);
  await Future.delayed(Duration(milliseconds: 300));
  tokenCollision(world);
}

Vector2 calculateTargetPosition(Token token, Spot spot, LudoBoard ludoBoard) {
  // Calculate the position adjustment based on the token size and ludo board position
  final spotGlobalPosition = spot.absolutePositionOf(Vector2.zero());
  final ludoBoardGlobalPosition = ludoBoard.absolutePositionOf(Vector2.zero());

  return Vector2(
    spotGlobalPosition.x + (token.size.x * 0.10) - ludoBoardGlobalPosition.x,
    spotGlobalPosition.y - (token.size.x * 0.50) - ludoBoardGlobalPosition.y,
  );
}

void tokenCollision(world) {
  final tokens = TokenManager().allTokens; // Source data
  final ludoBoard = world.children.whereType<LudoBoard>().first;

  final homeSpot = getHomeSpot(world, 6)
      .whereType<HomeSpot>()
      .firstWhere((spot) => spot.uniqueId == 'B1');

  // Step 1: Store original size and position of tokens based on homeSpot
  final Vector2 originalSize =
      Vector2(homeSpot.size.x * 0.80, homeSpot.size.x * 1.05);

  // Step 2: Count occurrences of each positionId
  final Map<String, int> positionIdCount = {};
  for (var token in tokens) {
    positionIdCount[token.positionId] =
        (positionIdCount[token.positionId] ?? 0) + 1;
  }

  // Step 3: Filter out tokens that have duplicate positionIds (more than one occurrence)
  final duplicateTokens = tokens.where((token) {
    return positionIdCount[token.positionId]! > 1;
  }).toList();

  final currentMiniTokens =
      TokenManager().miniTokens; // Get the current miniTokens
  Set<String> duplicateTokenIds = duplicateTokens
      .map((token) => token.tokenId)
      .toSet(); // Create a set of tokenIds from duplicateTokens

  // Step 4: Filter miniTokens to find tokens that are not in duplicateTokens
  final tokensNotInDuplicateTokens = currentMiniTokens
      .where((token) => !duplicateTokenIds.contains(token.tokenId))
      .toList();

  // Step 5: Adjust size and position for tokens not in duplicateTokens
  if (tokensNotInDuplicateTokens.isNotEmpty) {
    for (var i = 0; i < tokensNotInDuplicateTokens.length; i++) {
      var token = tokensNotInDuplicateTokens[i];
      // Restore the original size
      token.size = originalSize;
      final spot = findSpotById(token.positionId);
      final spotGlobalPosition = spot.absolutePositionOf(Vector2.zero());
      final ludoBoardGlobalPosition =
          ludoBoard.absolutePositionOf(Vector2.zero());

      token.position = Vector2(
        spotGlobalPosition.x +
            (token.size.x * 0.10) -
            ludoBoardGlobalPosition.x,
        spotGlobalPosition.y -
            (token.size.x * 0.50) -
            ludoBoardGlobalPosition.y,
      );
    }
  }

  // Step 6: Group duplicateTokens by positionId and apply margin incrementally
  if (duplicateTokens.isNotEmpty) {
    print(duplicateTokens);

    TokenManager().miniTokens = duplicateTokens;

    // Group tokens by positionId
    final Map<String, List<Token>> groupedTokens = {};
    for (var token in duplicateTokens) {
      if (!groupedTokens.containsKey(token.positionId)) {
        groupedTokens[token.positionId] = [];
      }
      groupedTokens[token.positionId]!.add(token);
    }

    // Apply size adjustment and incremental margin within each group
    groupedTokens.forEach((positionId, group) {
      if (group.length == 2) {
        for (var i = 0; i < group.length; i++) {
          var token = group[i];
          // Scale relative to the original size
          token.size = originalSize * 0.70;
          final spot = findSpotById(token.positionId);
          token.position = Vector2(
              spot.absolutePosition.x + (i * 10) - ludoBoard.absolutePosition.x,
              spot.absolutePosition.y - ludoBoard.absolutePosition.y);
        }
      }
      if (group.length >= 3) {
        for (var i = 0; i < group.length; i++) {
          var token = group[i];
          // Scale relative to the original size
          token.size = originalSize * 0.50;
          final spot = findSpotById(token.positionId);
          token.position = Vector2(
              spot.absolutePosition.x + (i * 5) - ludoBoard.absolutePosition.x,
              spot.absolutePosition.y - ludoBoard.absolutePosition.y);
        }
      }
    });
  }
}

void addTokenTrail(List<Token> tokensOnBoard) {
  for (var token in tokensOnBoard) {
    final spot = findSpotById(token.positionId);

    if (spot == null) {
      continue;
    }

    if (token.spaceToMove()) {
      if (token.tokenId.startsWith('B')) {
        spot.add(ColorEffect(
          Color(0xFF4FC3F7),
          EffectController(
            duration: 0.2,
            reverseDuration: 0.2,
            infinite: true,
            alternate: true,
          ),
        ));
      }
      if (token.tokenId.startsWith('G')) {
        spot.add(ColorEffect(
          Colors.lightGreen,
          EffectController(
            duration: 0.2,
            reverseDuration: 0.2,
            infinite: true,
            alternate: true,
          ),
        ));
      }
    }
  }
}

Future<void> moveForward({
  required World world,
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
  final originalSize = tokenOriginalSize(world).clone();

  // Loop through the positions from current to final index
  for (int i = currentIndex + 1; i <= finalIndex; i++) {
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

      FlameAudio.play('move.mp3');

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
  tokenCollision(world);
  clearTokenTrail(token);
}

Vector2 tokenOriginalSize(world) {
  final homeSpot = getHomeSpot(world, 6)
      .whereType<HomeSpot>()
      .firstWhere((spot) => spot.uniqueId == 'B1');

  // Step 1: Store original size and position of tokens based on homeSpot
  final Vector2 originalSize =
      Vector2(homeSpot.size.x * 0.80, homeSpot.size.x * 1.05);
  return originalSize;
}

void clearTokenTrail(Token token) async {
  final spots = SpotManager().getSpots();

  for (var spot in spots) {
    // Check if the spot has any ColorEffect children
    if (spot.children.whereType<ColorEffect>().isNotEmpty) {
      final effects = spot.children.whereType<ColorEffect>().toList();

      // Iterate through each ColorEffect and remove it
      for (var colorEffect in effects) {
        print("Removing ColorEffect: $colorEffect");
        spot.remove(colorEffect);
      }

      // Optionally reset the spot's color after removing effects
      if (spot.uniqueId == 'B04' ||
          spot.uniqueId == 'B10' ||
          spot.uniqueId == 'B11' ||
          spot.uniqueId == 'B12' ||
          spot.uniqueId == 'B13' ||
          spot.uniqueId == 'B14') {
        spot.add(ColorEffect(
          Colors.blue,
          EffectController(
            duration: 0.2,
            reverseDuration: 0.2,
            infinite: true,
            alternate: true,
          ),
        ));
      } else if (spot.uniqueId == 'G21' ||
          spot.uniqueId == 'G11' ||
          spot.uniqueId == 'G12' ||
          spot.uniqueId == 'G13' ||
          spot.uniqueId == 'G14' ||
          spot.uniqueId == 'G15') {
        spot.add(ColorEffect(
          Colors.green,
          EffectController(
            duration: 0.2,
            reverseDuration: 0.2,
            infinite: true,
            alternate: true,
          ),
        ));
      } else if (spot.uniqueId == 'Y42') {
        spot.add(ColorEffect(
          Colors.yellow,
          EffectController(
            duration: 0.2,
            reverseDuration: 0.2,
            infinite: true,
            alternate: true,
          ),
        ));
      } else if (spot.uniqueId == 'R10') {
        spot.add(ColorEffect(
          Colors.red,
          EffectController(
            duration: 0.2,
            reverseDuration: 0.2,
            infinite: true,
            alternate: true,
          ),
        ));
      } else {
        spot.add(ColorEffect(
          Colors.white,
          EffectController(
            duration: 0.2,
            reverseDuration: 0.2,
            infinite: true,
            alternate: true,
          ),
        ));
      }
    }
  }
}

Future<void> _applyEffect(PositionComponent component, Effect effect) {
  final completer = Completer<void>();
  effect.onComplete = completer.complete;
  component.add(effect);
  return completer.future;
}
