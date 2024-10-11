import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:collection/collection.dart';

import 'state/player.dart';
import 'component/home/home.dart';
import 'state/token_manager.dart';
import 'state/event_bus.dart';
import 'component/home/home_spot.dart';
import 'state/game_state.dart';
import 'state/token_path.dart';
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

  ColorEffect? _greenBlinkEffect;
  ColorEffect? _greenStaticEffect;
  ColorEffect? _blueBlinkEffect;
  ColorEffect? _blueStaticEffect;

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

    add(FpsTextComponent(
      position: Vector2(10, 10), // Adjust position as needed
      anchor: Anchor.topLeft, // Set anchor to align top-left
    ));

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

    // Initialize effects if they haven't been created yet
    _blueBlinkEffect ??= ColorEffect(
      Color(0xFF4FC3F7),
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    _blueStaticEffect ??= ColorEffect(
      Colors.blue,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    // Add the appropriate effect based on shouldBlink
    homePlate.add(shouldBlink ? _blueBlinkEffect! : _blueStaticEffect!);
  }

  void blinkGreenBase(bool shouldBlink) {
    final ludoBoard = world.children.whereType<LudoBoard>().first;
    final childrenOfLudoBoard = ludoBoard.children.toList();
    final child = childrenOfLudoBoard[2];
    final home = child.children.toList();
    final homePlate = home[0] as Home;

    // Initialize effects if they haven't been created yet
    _greenBlinkEffect ??= ColorEffect(
      Colors.lightGreen,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    _greenStaticEffect ??= ColorEffect(
      Colors.green,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    // Add the appropriate effect based on shouldBlink
    homePlate.add(shouldBlink ? _greenBlinkEffect! : _greenStaticEffect!);
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

      final ludoBoardPosition = ludoBoard.absolutePosition;
      const homeSpotSizeFactorX = 0.10;
      const homeSpotSizeFactorY = 0.05;
      const tokenSizeFactorX = 0.80;
      const tokenSizeFactorY = 1.05;

      for (var token in TokenManager().getBlueTokens()) {
        final homeSpot = getHomeSpot(world, 6)
            .whereType<HomeSpot>()
            .firstWhere((spot) => spot.uniqueId == token.positionId);
        token.innerCircleColor = Colors.blue;
        token.position = Vector2(
          homeSpot.absolutePosition.x +
              (homeSpot.size.x * homeSpotSizeFactorX) -
              ludoBoardPosition.x,
          homeSpot.absolutePosition.y -
              (homeSpot.size.x * homeSpotSizeFactorY) -
              ludoBoardPosition.y,
        );
        token.size = Vector2(
          homeSpot.size.x * tokenSizeFactorX,
          homeSpot.size.x * tokenSizeFactorY,
        );
        ludoBoard.add(token);
      }

      const playerId = 'BP';
      final tokens = TokenManager().getBlueTokens();

      if (gameState.players.isEmpty) {
        blinkBlueBase(true);
        Player bluePlayer = Player(
          playerId: playerId,
          tokens: tokens,
          isCurrentTurn: true,
          enableDice: true,
        );
        gameState.players.add(bluePlayer);
        for (var token in tokens) {
          token.playerId = bluePlayer.playerId;
          token.enableToken = true;
        }
      } else {
        Player bluePlayer = Player(
          playerId: playerId,
          tokens: tokens,
        );
        gameState.players.add(bluePlayer);
        for (var token in tokens) {
          token.playerId = bluePlayer.playerId;
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

      final ludoBoardPosition = ludoBoard.absolutePosition;
      const homeSpotSizeFactorX = 0.10;
      const homeSpotSizeFactorY = 0.05;
      const tokenSizeFactorX = 0.80;
      const tokenSizeFactorY = 1.05;

      for (var token in TokenManager().getGreenTokens()) {
        final homeSpot = getHomeSpot(world, 2)
            .whereType<HomeSpot>()
            .firstWhere((spot) => spot.uniqueId == token.positionId);
        token.innerCircleColor = Colors.green;
        token.position = Vector2(
          homeSpot.absolutePosition.x +
              (homeSpot.size.x * homeSpotSizeFactorX) -
              ludoBoardPosition.x,
          homeSpot.absolutePosition.y -
              (homeSpot.size.x * homeSpotSizeFactorY) -
              ludoBoardPosition.y,
        );
        token.size = Vector2(
          homeSpot.size.x * tokenSizeFactorX,
          homeSpot.size.x * tokenSizeFactorY,
        );
        ludoBoard.add(token);
      }

      const playerId = 'GP';
      final tokens = TokenManager().getGreenTokens();

      if (gameState.players.isEmpty) {
        blinkGreenBase(true);
        Player greenPlayer = Player(
          playerId: playerId,
          tokens: tokens,
          isCurrentTurn: true,
          enableDice: true,
        );
        gameState.players.add(greenPlayer);
        for (var token in tokens) {
          token.playerId = greenPlayer.playerId;
          token.enableToken = true;
        }
      } else {
        Player greenPlayer = Player(
          playerId: playerId,
          tokens: tokens,
        );
        gameState.players.add(greenPlayer);
        for (var token in tokens) {
          token.playerId = greenPlayer.playerId;
          token.enableToken = false;
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
    if (TokenManager().getBlueTokens().isEmpty &&
        TokenManager().getGreenTokens().isEmpty) {
      startGame();
    }
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

  // Create an instance of SpotManager
  SpotManager spotManager = SpotManager();

  // Get the first spot (starting point) from the path
  Spot spot = spotManager.findSpotById(tokenPath.first);

  // Calculate the target position on the board
  Vector2 targetPosition = calculateTargetPosition(token, spot, ludoBoard);

  // Apply the movement effect to move the token out of base
  applyMoveEffect(world, token, targetPosition);
}

void applyMoveEffect(World world, Token token, Vector2 targetPosition) async {
  final moveToEffect = MoveToEffect(
    targetPosition,
    EffectController(
        duration: 0.05, curve: Curves.easeInOut), // Reduced duration
  );

  await token.add(moveToEffect);
  await Future.delayed(Duration(milliseconds: 100)); // Reduced delay
  tokenCollision(world, token);
}

Vector2 calculateTargetPosition(Token token, Spot spot, LudoBoard ludoBoard) {
  // Precompute the token size adjustments
  final tokenSizeAdjustmentX = token.size.x * 0.10;
  final tokenSizeAdjustmentY = token.size.x * 0.05;

  // Precompute the global positions
  final spotGlobalPosition = spot.absolutePositionOf(Vector2.zero());
  final ludoBoardGlobalPosition = ludoBoard.absolutePositionOf(Vector2.zero());

  // Calculate the target position using precomputed values
  return Vector2(
    spotGlobalPosition.x + tokenSizeAdjustmentX - ludoBoardGlobalPosition.x,
    spotGlobalPosition.y - tokenSizeAdjustmentY - ludoBoardGlobalPosition.y,
  );
}

void tokenCollision(World world, Token attackerToken) {
  final tokens = TokenManager().allTokens; // Source data
  final ludoBoard = world.children.whereType<LudoBoard>().first;

  final homeSpot = getHomeSpot(world, 6)
      .whereType<HomeSpot>()
      .firstWhere((spot) => spot.uniqueId == 'B1');

  // Store original size and position of tokens based on homeSpot
  final Vector2 originalSize =
      Vector2(homeSpot.size.x * 0.80, homeSpot.size.x * 1.05);

  // Count occurrences of each positionId
  final positionIdCount = groupBy(tokens, (token) => token.positionId)
      .map((key, value) => MapEntry(key, value.length));

  // Use a set to store duplicate positionIds for faster lookup
  final duplicatePositionIds = positionIdCount.entries
      .where((entry) => entry.value > 1)
      .map((entry) => entry.key)
      .toSet();

  // Filter tokens directly using the set of duplicate positionIds
  final duplicateTokens = tokens.where((token) {
    return duplicatePositionIds.contains(token.positionId);
  }).toList();
  final currentMiniTokens = TokenManager().miniTokens;

  final duplicateTokenIds =
      duplicateTokens.map((token) => token.tokenId).toSet();

  // Track token ID from different players on collision
  for (var otherTokenId in duplicateTokenIds) {
    if (otherTokenId != attackerToken.tokenId) {
      final otherToken =
          tokens.firstWhere((token) => token.tokenId == otherTokenId);

      if (otherToken.positionId == attackerToken.positionId) {
        // Check if the token is from a different player
        if (attackerToken.tokenId[0] != otherTokenId[0]) {
          final knockedOutToken = TokenManager()
              .allTokens
              .firstWhere((t) => t.tokenId == otherTokenId);
          moveBackward(
            world: world,
            token: knockedOutToken,
            tokenPath: getTokenPath(knockedOutToken.playerId),
            ludoBoard: ludoBoard,
          );
        }
      }
    }
  }

  // Group duplicateTokens by positionId and apply margin incrementally
  if (duplicateTokenIds.isNotEmpty) {
    TokenManager().miniTokens = tokens
        .where((token) => duplicateTokenIds.contains(token.tokenId))
        .toList();

    // Group tokens by positionId using duplicateTokenIds, considering the attackedToken
    final Map<String, List<Token>> groupedTokens = {};
    for (var token in tokens) {
      // Check if the token is in duplicateTokenIds
      if (duplicateTokenIds.contains(token.tokenId)) {
        // If attackedToken's tokenId matches, only add tokens with the same playerId
        if (token.tokenId == attackerToken.tokenId) {
          if (!groupedTokens.containsKey(token.positionId)) {
            groupedTokens[token.positionId] = [];
          }
          groupedTokens[token.positionId]!.add(token);
        } else if (token.playerId == attackerToken.playerId) {
          // If it's a different token, add it only if it belongs to the same player
          if (!groupedTokens.containsKey(token.positionId)) {
            groupedTokens[token.positionId] = [];
          }
          groupedTokens[token.positionId]!.add(token);
        }
      }
    }

    // Apply size adjustment and incremental margin within each group
    groupedTokens.forEach((positionId, group) {
      final sizeFactor = group.length == 2 ? 0.70 : 0.50;
      final positionIncrement = group.length == 2 ? 10 : 5;

      SpotManager spotManager = SpotManager();

      for (var i = 0; i < group.length; i++) {
        var token = group[i];
        // Prevent size change for the attackerToken
        if (token.tokenId == attackerToken.tokenId) {
          continue; // Skip size adjustment for the attackerToken
        }
        // Scale relative to the original size
        token.size = originalSize * sizeFactor;
        final spot = spotManager.findSpotById(token.positionId);
        final spotGlobalPosition = spot.absolutePosition;
        final ludoBoardGlobalPosition = ludoBoard.absolutePosition;

        token.position = Vector2(
            spotGlobalPosition.x +
                (i * positionIncrement) -
                ludoBoardGlobalPosition.x,
            spotGlobalPosition.y - ludoBoardGlobalPosition.y);
      }
    });
  }

  // Filter miniTokens to find tokens that are not in duplicateTokens
  final tokensNotInDuplicateTokens = currentMiniTokens
      .where((token) => !duplicateTokenIds.contains(token.tokenId))
      .toList();

  // Adjust size and position for tokens not in duplicateTokens
  if (tokensNotInDuplicateTokens.isNotEmpty) {
    final ludoBoardGlobalPosition =
        ludoBoard.absolutePositionOf(Vector2.zero());

    SpotManager spotManager = SpotManager();

    for (var token in tokensNotInDuplicateTokens) {
      // Restore the original size
      token.size = originalSize;
      final spot = spotManager.findSpotById(token.positionId);
      final spotGlobalPosition = spot.absolutePositionOf(Vector2.zero());

      // Calculate the position once and reuse it
      final adjustedPosition = spotGlobalPosition - ludoBoardGlobalPosition;

      token.position = Vector2(
        adjustedPosition.x + (token.size.x * 0.10),
        adjustedPosition.y - (token.size.x * 0.05),
      );
    }
  }
}

void addTokenTrail(List<Token> tokensOnBoard) {
  SpotManager spotManager = SpotManager();
  for (var token in tokensOnBoard) {
    final spot = spotManager.findSpotById(token.positionId);
    if (spot == null || !token.spaceToMove()) {
      continue;
    }

    // Determine the color based on the tokenId prefix
    Color? color;
    if (token.tokenId.startsWith('B')) {
      color = Color(0xFF4FC3F7); // Blue color
    } else if (token.tokenId.startsWith('G')) {
      color = Colors.lightGreen; // Green color
    }

    // Set the color if it's determined
    if (color != null) {
      spot.paint.color = color; // Assuming 'spot' has a 'paint' property
    }
  }
}

Future<void> moveBackward({
  required World world,
  required Token token,
  required List<String> tokenPath,
  required PositionComponent ludoBoard,
}) async {
  List<Spot> allSpots = SpotManager().getSpots();
  final currentIndex = tokenPath.indexOf(token.positionId);
  const finalIndex = 0;
  final ludoBoardGlobalPosition = ludoBoard.absolutePositionOf(Vector2.zero());

  // Preload audio to avoid delays during playback
  FlameAudio.audioCache.load('move.mp3');
  bool audioPlayed = false;

  final tokenSizeAdjustmentX = token.size.x * 0.10;
  final tokenSizeAdjustmentY = token.size.x * 0.05;

  for (int i = currentIndex; i >= finalIndex; i--) {
    String positionId = tokenPath[i];
    token.positionId = positionId;

    final spot = allSpots.firstWhere((spot) => spot.uniqueId == positionId);
    final spotGlobalPosition = spot.absolutePositionOf(Vector2.zero());

    final targetPosition = Vector2(
      spotGlobalPosition.x + tokenSizeAdjustmentX - ludoBoardGlobalPosition.x,
      spotGlobalPosition.y - tokenSizeAdjustmentY - ludoBoardGlobalPosition.y,
    );

    if (!audioPlayed) {
      FlameAudio.play('move.mp3');
      audioPlayed = true;
    }

    await _applyEffect(
      token,
      MoveToEffect(
        targetPosition,
        EffectController(duration: 0.05, curve: Curves.easeInOut),
      ),
    );

    await Future.delayed(Duration(milliseconds: 50));
  }
}

Future<void> moveForward({
  required World world,
  required Token token,
  required List<String> tokenPath,
  required int diceNumber,
  required PositionComponent ludoBoard,
}) async {
  List<Spot> allSpots = SpotManager().getSpots();
  final currentIndex = tokenPath.indexOf(token.positionId);
  final finalIndex = currentIndex + diceNumber;
  final ludoBoardGlobalPosition = ludoBoard.absolutePositionOf(Vector2.zero());

  // Preload audio to avoid delays during playback
  FlameAudio.audioCache.load('move.mp3');

  // Precompute the initial audio play flag
  bool audioPlayed = false;

  // Precompute the token size adjustments
  final tokenSizeAdjustmentX = token.size.x * 0.10;
  final tokenSizeAdjustmentY = token.size.x * 0.05;

  for (int i = currentIndex + 1; i <= finalIndex && i < tokenPath.length; i++) {
    String positionId = tokenPath[i];
    token.positionId = positionId;

    final spot = allSpots.firstWhere((spot) => spot.uniqueId == positionId);
    final spotGlobalPosition = spot.absolutePositionOf(Vector2.zero());

    final targetPosition = Vector2(
      spotGlobalPosition.x + tokenSizeAdjustmentX - ludoBoardGlobalPosition.x,
      spotGlobalPosition.y - tokenSizeAdjustmentY - ludoBoardGlobalPosition.y,
    );

    // Play audio only once per move
    if (!audioPlayed) {
      FlameAudio.play('move.mp3');
      audioPlayed = true;
    }

    // Apply move effect only, remove size effect to reduce load
    await _applyEffect(
      token,
      MoveToEffect(
        targetPosition,
        EffectController(duration: 0.05, curve: Curves.easeInOut),
      ),
    );

    // Reduce delay to improve performance
    await Future.delayed(Duration(milliseconds: 50));
  }

  tokenCollision(world, token);
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

void clearTokenTrail(Token token) {
  final spots = SpotManager().getSpots();

  for (var spot in spots) {
    // Determine the color to reset based on uniqueId
    Color resetColor;
    switch (spot.uniqueId) {
      case 'B04':
      case 'B10':
      case 'B11':
      case 'B12':
      case 'B13':
      case 'B14':
      case 'BF':
        resetColor = Colors.blue;
        break;
      case 'G21':
      case 'G11':
      case 'G12':
      case 'G13':
      case 'G14':
      case 'G15':
      case 'GF':
        resetColor = Colors.green;
        break;
      case 'Y42':
      case 'Y41':
      case 'Y31':
      case 'Y21':
      case 'Y11':
      case 'Y01':
      case 'YF':
        resetColor = Colors.yellow;
        break;
      case 'R10':
      case 'R11':
      case 'R21':
      case 'R31':
      case 'R41':
      case 'R51':
      case 'RF':
        resetColor = Colors.red;
        break;
      default:
        resetColor = Colors.white;
    }

    // Set the color directly
    spot.paint.color = resetColor; // Assuming 'spot' has a 'paint' property
  }
}

Future<void> _applyEffect(PositionComponent component, Effect effect) {
  final completer = Completer<void>();
  effect.onComplete = completer.complete;
  component.add(effect);
  return completer.future;
}
