import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

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
  List<String> teams;

  Ludo(this.teams);

  final rand = Random();
  double get width => size.x;
  double get height => size.y;

  ColorEffect? _greenBlinkEffect;
  ColorEffect? _greenStaticEffect;

  ColorEffect? _blueBlinkEffect;
  ColorEffect? _blueStaticEffect;

  ColorEffect? _yellowBlinkEffect;
  ColorEffect? _yellowStaticEffect;

  ColorEffect? _redBlinkEffect;
  ColorEffect? _redStaticEffect;

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
      blinkBlueBase(false);
      blinkRedBase(false);
      blinkYellowBase(false);
    });

    EventBus().on<BlinkBlueBaseEvent>((event) {
      blinkBlueBase(true);
      blinkGreenBase(false);
      blinkRedBase(false);
      blinkYellowBase(false);
    });

    EventBus().on<BlinkRedBaseEvent>((event) {
      blinkRedBase(true);
      blinkGreenBase(false);
      blinkBlueBase(false);
      blinkYellowBase(false);
    });

    EventBus().on<BlinkYellowBaseEvent>((event) {
      blinkYellowBase(true);
      blinkGreenBase(false);
      blinkBlueBase(false);
      blinkRedBase(false);
    });
  }

  void blinkRedBase(bool shouldBlink) {
    final ludoBoard = world.children.whereType<LudoBoard>().first;
    final childrenOfLudoBoard = ludoBoard.children.toList();
    final child = childrenOfLudoBoard[0];
    final home = child.children.toList();
    final homePlate = home[0] as Home;

    // Initialize effects if they haven't been created yet
    _redBlinkEffect ??= ColorEffect(
      const Color(0xFFFF8A8A),
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    _redStaticEffect ??= ColorEffect(
      Colors.red,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    // Add the appropriate effect based on shouldBlink
    homePlate.add(shouldBlink ? _redBlinkEffect! : _redStaticEffect!);
  }

  void blinkYellowBase(bool shouldBlink) {
    final ludoBoard = world.children.whereType<LudoBoard>().first;
    final childrenOfLudoBoard = ludoBoard.children.toList();
    final child = childrenOfLudoBoard[8];
    final home = child.children.toList();
    final homePlate = home[0] as Home;

    // Initialize effects if they haven't been created yet
    _yellowBlinkEffect ??= ColorEffect(
      Colors.yellowAccent,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    _yellowStaticEffect ??= ColorEffect(
      Colors.yellow,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    // Add the appropriate effect based on shouldBlink
    homePlate.add(shouldBlink ? _yellowBlinkEffect! : _yellowStaticEffect!);
  }

  void blinkBlueBase(bool shouldBlink) {
    final ludoBoard = world.children.whereType<LudoBoard>().first;
    final childrenOfLudoBoard = ludoBoard.children.toList();
    final child = childrenOfLudoBoard[6];
    final home = child.children.toList();
    final homePlate = home[0] as Home;

    // Initialize effects if they haven't been created yet
    _blueBlinkEffect ??= ColorEffect(
      const Color(0xFF4FC3F7),
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

    for (var team in teams) {
      if (team == 'BP') {
        if (TokenManager().getBlueTokens().isEmpty) {
          TokenManager().initializeTokens(TokenManager().blueTokensBase);

          final ludoBoardPosition = ludoBoard.absolutePosition;
          const homeSpotSizeFactorX = 0.10;
          const homeSpotSizeFactorY = 0.05;
          const tokenSizeFactorX = 0.80;
          const tokenSizeFactorY = 1.05;

          for (var token in TokenManager().getBlueTokens()) {
            final homeSpot = getHomeSpot(world, 6)
                .whereType<HomeSpot>()
                .firstWhere((spot) => spot.uniqueId == token.positionId);
            final spot = SpotManager().findSpotById(token.positionId);
            // update spot position
            spot.position = Vector2(
              homeSpot.absolutePosition.x +
                  (homeSpot.size.x * homeSpotSizeFactorX) -
                  ludoBoardPosition.x,
              homeSpot.absolutePosition.y -
                  (homeSpot.size.x * homeSpotSizeFactorY) -
                  ludoBoardPosition.y,
            );
            // update token position
            token.innerCircleColor = Colors.blue;
            token.position = spot.position;
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

          final player = gameState.players
              .firstWhere((player) => player.playerId == playerId);

          // dice for player blue
          final lowerController =
              world.children.whereType<LowerController>().first;
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
      } else if (team == 'GP') {
        if (TokenManager().getGreenTokens().isEmpty) {
          TokenManager().initializeTokens(TokenManager().greenTokensBase);

          final ludoBoardPosition = ludoBoard.absolutePosition;
          const homeSpotSizeFactorX = 0.10;
          const homeSpotSizeFactorY = 0.05;
          const tokenSizeFactorX = 0.80;
          const tokenSizeFactorY = 1.05;

          for (var token in TokenManager().getGreenTokens()) {
            final homeSpot = getHomeSpot(world, 2)
                .whereType<HomeSpot>()
                .firstWhere((spot) => spot.uniqueId == token.positionId);
            final spot = SpotManager().findSpotById(token.positionId);
            // update spot position
            spot.position = Vector2(
              homeSpot.absolutePosition.x +
                  (homeSpot.size.x * homeSpotSizeFactorX) -
                  ludoBoardPosition.x,
              homeSpot.absolutePosition.y -
                  (homeSpot.size.x * homeSpotSizeFactorY) -
                  ludoBoardPosition.y,
            );
            // update token position
            token.innerCircleColor = Colors.green;
            token.position = spot.position;
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

          final player = gameState.players
              .firstWhere((player) => player.playerId == playerId);

          // dice for player green
          final upperController =
              world.children.whereType<UpperController>().first;
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
      } else if (team == 'YP') {
        if (TokenManager().getYellowTokens().isEmpty) {
          TokenManager().initializeTokens(TokenManager().yellowTokensBase);

          final ludoBoardPosition = ludoBoard.absolutePosition;
          const homeSpotSizeFactorX = 0.10;
          const homeSpotSizeFactorY = 0.05;
          const tokenSizeFactorX = 0.80;
          const tokenSizeFactorY = 1.05;

          for (var token in TokenManager().getYellowTokens()) {
            final homeSpot = getHomeSpot(world, 8)
                .whereType<HomeSpot>()
                .firstWhere((spot) => spot.uniqueId == token.positionId);
            final spot = SpotManager().findSpotById(token.positionId);
            // update spot position
            spot.position = Vector2(
              homeSpot.absolutePosition.x +
                  (homeSpot.size.x * homeSpotSizeFactorX) -
                  ludoBoardPosition.x,
              homeSpot.absolutePosition.y -
                  (homeSpot.size.x * homeSpotSizeFactorY) -
                  ludoBoardPosition.y,
            );
            // update token position
            token.innerCircleColor = Colors.yellow;
            token.position = spot.position;
            token.size = Vector2(
              homeSpot.size.x * tokenSizeFactorX,
              homeSpot.size.x * tokenSizeFactorY,
            );
            ludoBoard.add(token);
          }

          const playerId = 'YP';
          final tokens = TokenManager().getYellowTokens();

          if (gameState.players.isEmpty) {
            blinkYellowBase(true);
            Player yellowPlayer = Player(
              playerId: playerId,
              tokens: tokens,
              isCurrentTurn: true,
              enableDice: true,
            );
            gameState.players.add(yellowPlayer);
            for (var token in tokens) {
              token.playerId = yellowPlayer.playerId;
              token.enableToken = true;
            }
          } else {
            Player yellowPlayer = Player(
              playerId: playerId,
              tokens: tokens,
            );
            gameState.players.add(yellowPlayer);
            for (var token in tokens) {
              token.playerId = yellowPlayer.playerId;
              token.enableToken = false;
            }
          }

          final player = gameState.players
              .firstWhere((player) => player.playerId == playerId);

          // dice for player yellow
          final lowerController =
              world.children.whereType<LowerController>().first;
          final lowerControllerComponents = lowerController.children.toList();
          final rightDice = lowerControllerComponents[2]
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
      } else if (team == 'RP') {
        if (TokenManager().getRedTokens().isEmpty) {
          TokenManager().initializeTokens(TokenManager().redTokensBase);

          final ludoBoardPosition = ludoBoard.absolutePosition;
          const homeSpotSizeFactorX = 0.10;
          const homeSpotSizeFactorY = 0.05;
          const tokenSizeFactorX = 0.80;
          const tokenSizeFactorY = 1.05;

          for (var token in TokenManager().getRedTokens()) {
            final homeSpot = getHomeSpot(world, 0)
                .whereType<HomeSpot>()
                .firstWhere((spot) => spot.uniqueId == token.positionId);
            final spot = SpotManager().findSpotById(token.positionId);
            // update spot position
            spot.position = Vector2(
              homeSpot.absolutePosition.x +
                  (homeSpot.size.x * homeSpotSizeFactorX) -
                  ludoBoardPosition.x,
              homeSpot.absolutePosition.y -
                  (homeSpot.size.x * homeSpotSizeFactorY) -
                  ludoBoardPosition.y,
            );
            // update token position
            token.innerCircleColor = Colors.red;
            token.position = spot.position;
            token.size = Vector2(
              homeSpot.size.x * tokenSizeFactorX,
              homeSpot.size.x * tokenSizeFactorY,
            );
            ludoBoard.add(token);
          }

          const playerId = 'RP';
          final tokens = TokenManager().getRedTokens();

          if (gameState.players.isEmpty) {
            blinkRedBase(true);
            Player redPlayer = Player(
              playerId: playerId,
              tokens: tokens,
              isCurrentTurn: true,
              enableDice: true,
            );
            gameState.players.add(redPlayer);
            for (var token in tokens) {
              token.playerId = redPlayer.playerId;
              token.enableToken = true;
            }
          } else {
            Player redPlayer = Player(
              playerId: playerId,
              tokens: tokens,
            );
            gameState.players.add(redPlayer);
            for (var token in tokens) {
              token.playerId = redPlayer.playerId;
              token.enableToken = false;
            }
          }

          final player = gameState.players
              .firstWhere((player) => player.playerId == playerId);

          // dice for player yellow
          final upperController =
              world.children.whereType<UpperController>().first;
          final upperControllerComponents = upperController.children.toList();
          final leftDice = upperControllerComponents[0]
              .children
              .whereType<RectangleComponent>()
              .first;
          final rightDiceContainer =
              leftDice.children.whereType<RectangleComponent>().first;
          rightDiceContainer.add(LudoDice(
            player: player,
            faceSize: leftDice.size.x * 0.70,
          ));
        }
      }
    }
  }

  @override
  void onTap() {
    if (TokenManager().getBlueTokens().isEmpty &&
        TokenManager().getGreenTokens().isEmpty &&
        TokenManager().getRedTokens().isEmpty &&
        TokenManager().getYellowTokens().isEmpty) {
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
  await Future.delayed(const Duration(milliseconds: 100)); // Reduced delay
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

void tokenCollision(World world, Token attackerToken) async {
  final gameState = GameState();
  final ludoBoard = world.children.whereType<LudoBoard>().first;
  final spotId = attackerToken.positionId;
  final tokens = TokenManager().allTokens;
  final tokensOnSpot =
      tokens.where((token) => token.positionId == spotId).toList();

  // Initialize the flag to track if any token was attacked
  bool wasTokenAttacked = false;

  // only attacker token on spot, return
  if (tokensOnSpot.length > 1) {
    // if attacker token is in safe zone, return
    final safeZones = ['B04', 'B23', 'R22', 'R10', 'G02', 'G21', 'Y30', 'Y42'];
    if (!safeZones.contains(spotId)) {
      // attacker token is not in safe zone, check for collision
      for (var token in tokensOnSpot) {
        if (token.playerId != attackerToken.playerId) {
          await moveBackward(
              world: world,
              token: token,
              tokenPath: getTokenPath(token.playerId),
              ludoBoard: ludoBoard);

          // Set the flag to true if a token was attacked
          wasTokenAttacked = true;
        }
      }
    }
  }

  // Grant another turn or switch to next player
  final player = gameState.players
      .firstWhere((player) => player.playerId == attackerToken.playerId);

  if (wasTokenAttacked) {
    player.grantAnotherTurn();
    if (player.hasRolledThreeConsecutiveSixes()) {
      player.resetExtraTurns();
    }
    player.enableDice = true;
    for (var token in player.tokens) {
      token.enableToken = false;
    }
  } else {
    if (gameState.diceNumber == 6) {
      if (player.hasRolledThreeConsecutiveSixes()) {
        player.resetExtraTurns();
        gameState.switchToNextPlayer();
      } else {
        player.grantAnotherTurn();
        player.enableDice = true;
        for (var token in player.tokens) {
          token.enableToken = false;
        }
      }
    } else {
      gameState.switchToNextPlayer();
    }
  }

  // Ensure this block completes before resizing tokens
  await Future.delayed(Duration.zero);

  // Call the function to resize tokens after moveBackward is complete
  resizeTokensOnSpot(world, ludoBoard);
}

void resizeTokensOnSpot(World world, LudoBoard ludoBoard) {
  final tokens = TokenManager().allTokens;
  final Map<String, List<Token>> tokensByPositionId = {};
  for (var token in tokens) {
    if (!tokensByPositionId.containsKey(token.positionId)) {
      tokensByPositionId[token.positionId] = [];
    }
    tokensByPositionId[token.positionId]!.add(token);
  }

  final homeSpot = getHomeSpot(world, 6)
      .whereType<HomeSpot>()
      .firstWhere((spot) => spot.uniqueId == 'B1');
  final Vector2 originalSize =
      Vector2(homeSpot.size.x * 0.80, homeSpot.size.x * 1.05);
  final ludoBoardGlobalPosition = ludoBoard.absolutePosition;

  tokensByPositionId.forEach((positionId, tokenList) {
    final spot = SpotManager().findSpotById(positionId);
    final spotGlobalPosition = spot.absolutePosition;
    final adjustedPosition = spotGlobalPosition - ludoBoardGlobalPosition;

    double sizeFactor;
    int positionIncrement;

    if (tokenList.length == 1) {
      sizeFactor = 1.0;
      positionIncrement = 0;
    } else if (tokenList.length == 2) {
      sizeFactor = 0.70;
      positionIncrement = 10;
    } else {
      sizeFactor = 0.50;
      positionIncrement = 5;
    }

    for (var i = 0; i < tokenList.length; i++) {
      final token = tokenList[i];
      token.size = originalSize * sizeFactor;
      token.position = Vector2(
        adjustedPosition.x + (i * positionIncrement) + (token.size.x * 0.10),
        adjustedPosition.y - (token.size.x * 0.05),
      );

      if (token.state == TokenState.inBase) {
        token.position = spot.position;
      }
    }
  });
}

void addTokenTrail(List<Token> tokensOnBoard) {
  SpotManager spotManager = SpotManager();
  for (var token in tokensOnBoard) {
    final spot = spotManager.findSpotById(token.positionId);
    if (!token.spaceToMove()) {
      continue;
    }

    // Determine the color based on the tokenId prefix
    Color? color;
    if (token.tokenId.startsWith('B')) {
      color = const Color(0xFFB7E0FF); // Blue color
    } else if (token.tokenId.startsWith('G')) {
      color = const Color(0xFFB6FFA1); // Green color
    } else if (token.tokenId.startsWith('Y')) {
      color = const Color(0xFFFEFFA7); // Yellow color
    } else if (token.tokenId.startsWith('R')) {
      color = const Color(0xFFFF8A8A); // Red color
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
        EffectController(duration: 0.03, curve: Curves.easeInOut),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 30));
  }

  if (token.playerId == 'BP') {
    moveTokenToBase(
      world: world,
      token: token,
      tokenBase: TokenManager().blueTokensBase,
      homeSpotIndex: 6,
      ludoBoard: ludoBoard,
    );
  } else if (token.playerId == 'GP') {
    moveTokenToBase(
      world: world,
      token: token,
      tokenBase: TokenManager().greenTokensBase,
      homeSpotIndex: 2,
      ludoBoard: ludoBoard,
    );
  } else if (token.playerId == 'RP') {
    moveTokenToBase(
      world: world,
      token: token,
      tokenBase: TokenManager().redTokensBase,
      homeSpotIndex: 0,
      ludoBoard: ludoBoard,
    );
  } else if (token.playerId == 'YP') {
    moveTokenToBase(
      world: world,
      token: token,
      tokenBase: TokenManager().yellowTokensBase,
      homeSpotIndex: 8,
      ludoBoard: ludoBoard,
    );
  }
}

Future<void> moveForward({
  required World world,
  required Token token,
  required List<String> tokenPath,
  required int diceNumber,
  required PositionComponent ludoBoard,
}) async {
  // get all spots
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
    if (token.positionId == 'BF') {
      token.state = TokenState.inHome;
    } else if (token.positionId == 'GF') {
      token.state = TokenState.inHome;
    } else if (token.positionId == 'YF') {
      token.state = TokenState.inHome;
    } else if (token.positionId == 'RF') {
      token.state = TokenState.inHome;
    }

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
    await Future.delayed(const Duration(milliseconds: 50));
  }

  tokenCollision(world, token);
  clearTokenTrail(token);
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

void moveTokenToBase({
  required World world,
  required Token token,
  required Map<String, String> tokenBase,
  required int homeSpotIndex,
  required PositionComponent ludoBoard,
}) async {
  for (var entry in tokenBase.entries) {
    var tokenId = entry.key;
    var homePosition = entry.value;
    if (token.tokenId == tokenId) {
      token.positionId = homePosition;
      token.state = TokenState.inBase;
    }
  }
  final spot = SpotManager().findSpotById(token.positionId);
  final targetPosition = spot.position;

  await _applyEffect(
    token,
    MoveToEffect(
      targetPosition,
      EffectController(duration: 0.03, curve: Curves.easeInOut),
    ),
  );
  await Future.delayed(const Duration(milliseconds: 30));
}
