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
import 'component/controller/upper_controller.dart';
import 'component/controller/lower_controller.dart';
import 'ludo_board.dart';
import 'component/ui_components/token.dart';
import 'component/ui_components/spot.dart';
import 'component/ui_components/ludo_dice.dart';
import 'component/ui_components/rank_modal_component.dart';

class Ludo extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  List<String> teams;
  final BuildContext context;

  // Add an unnamed constructor
  Ludo(this.teams, this.context);

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
  void onLoad() async {
    super.onLoad();
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

    GameState().ludoBoard = world.children.whereType<LudoBoard>().first;
    final ludoBoard = GameState().ludoBoard as PositionComponent;
    GameState().ludoBoardAbsolutePosition = ludoBoard.absolutePosition;

    EventBus().on<OpenPlayerModalEvent>((event) {
      showPlayerModal();
    });

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

    await startGame();
  }

  void blinkRedBase(bool shouldBlink) {
    final childrenOfLudoBoard = GameState().ludoBoard?.children.toList();
    final child = childrenOfLudoBoard![0];
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
    final childrenOfLudoBoard = GameState().ludoBoard?.children.toList();
    final child = childrenOfLudoBoard![8];
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
    final childrenOfLudoBoard = GameState().ludoBoard?.children.toList();
    final child = childrenOfLudoBoard![6];
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
    final childrenOfLudoBoard = GameState().ludoBoard?.children.toList();
    final child = childrenOfLudoBoard![2];
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

  Future<void> startGame() async {
    await TokenManager().clearTokens();
    await GameState().clearPlayers();

    for (var team in teams) {
      if (team == 'BP') {
        if (TokenManager().getBlueTokens().isEmpty) {
          TokenManager().initializeTokens(TokenManager().blueTokensBase);

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
                  GameState().ludoBoardAbsolutePosition.x,
              homeSpot.absolutePosition.y -
                  (homeSpot.size.x * homeSpotSizeFactorY) -
                  GameState().ludoBoardAbsolutePosition.y,
            );
            // update token position
            token.innerCircleColor = Colors.blue;
            token.position = spot.position;
            token.size = Vector2(
              homeSpot.size.x * tokenSizeFactorX,
              homeSpot.size.x * tokenSizeFactorY,
            );
            GameState().ludoBoard?.add(token);
          }

          const playerId = 'BP';
          // final tokens = TokenManager().getBlueTokens();

          if (GameState().players.isEmpty) {
            blinkBlueBase(true);
            Player bluePlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getBlueTokens(),
              isCurrentTurn: true,
              enableDice: true,
            );
            GameState().players.add(bluePlayer);
            for (var token in TokenManager().getBlueTokens()) {
              token.playerId = bluePlayer.playerId;
              token.enableToken = true;
            }
          } else {
            Player bluePlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getBlueTokens(),
            );
            GameState().players.add(bluePlayer);
            for (var token in TokenManager().getBlueTokens()) {
              token.playerId = bluePlayer.playerId;
            }
          }

          final player = GameState()
              .players
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

          final ludoBoardPosition = GameState().ludoBoardAbsolutePosition;
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
            GameState().ludoBoard?.add(token);
          }

          const playerId = 'GP';
          // final tokens = TokenManager().getGreenTokens();

          if (GameState().players.isEmpty) {
            blinkGreenBase(true);
            Player greenPlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getGreenTokens(),
              isCurrentTurn: true,
              enableDice: true,
            );
            GameState().players.add(greenPlayer);
            for (var token in TokenManager().getGreenTokens()) {
              token.playerId = greenPlayer.playerId;
              token.enableToken = true;
            }
          } else {
            Player greenPlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getGreenTokens(),
            );
            GameState().players.add(greenPlayer);
            for (var token in TokenManager().getGreenTokens()) {
              token.playerId = greenPlayer.playerId;
              token.enableToken = false;
            }
          }

          final player = GameState()
              .players
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

          final ludoBoardPosition = GameState().ludoBoardAbsolutePosition;
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
            GameState().ludoBoard?.add(token);
          }

          const playerId = 'YP';
          // final tokens = TokenManager().getYellowTokens();

          if (GameState().players.isEmpty) {
            blinkYellowBase(true);
            Player yellowPlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getYellowTokens(),
              isCurrentTurn: true,
              enableDice: true,
            );
            GameState().players.add(yellowPlayer);
            for (var token in TokenManager().getYellowTokens()) {
              token.playerId = yellowPlayer.playerId;
              token.enableToken = true;
            }
          } else {
            Player yellowPlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getYellowTokens(),
            );
            GameState().players.add(yellowPlayer);
            for (var token in TokenManager().getYellowTokens()) {
              token.playerId = yellowPlayer.playerId;
              token.enableToken = false;
            }
          }

          final player = GameState()
              .players
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

          final ludoBoardPosition = GameState().ludoBoardAbsolutePosition;
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
            GameState().ludoBoard?.add(token);
          }

          const playerId = 'RP';
          // final tokens = TokenManager().getRedTokens();

          if (GameState().players.isEmpty) {
            blinkRedBase(true);
            Player redPlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getRedTokens(),
              isCurrentTurn: true,
              enableDice: true,
            );
            GameState().players.add(redPlayer);
            for (var token in TokenManager().getRedTokens()) {
              token.playerId = redPlayer.playerId;
              token.enableToken = true;
            }
          } else {
            Player redPlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getRedTokens(),
            );
            GameState().players.add(redPlayer);
            for (var token in TokenManager().getRedTokens()) {
              token.playerId = redPlayer.playerId;
              token.enableToken = false;
            }
          }

          final player = GameState()
              .players
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
    return Future.value();
  }

  @override
  Color backgroundColor() => const Color.fromARGB(0, 0, 0, 0);

  RankModalComponent? _playerModal;

  void showPlayerModal() {
    _playerModal = RankModalComponent(
      players: GameState().players,
      position: Vector2(size.x * 0.05, size.y * 0.10),
      size: Vector2(size.x * 0.90, size.y * 0.90),
      context: context,
    );
    world.add(_playerModal!);
  }

  void hidePlayerModal() {
    _playerModal?.removeFromParent();
    _playerModal = null;
  }
}

List<Component> getHomeSpot(world, i) {
  final childrenOfLudoBoard = GameState().ludoBoard?.children.toList();
  final child = childrenOfLudoBoard![i];
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
}) async {
  // Update token position to the first position in the path
  token.positionId = tokenPath.first;
  token.state = TokenState.onBoard;

  await _applyEffect(
      token,
      MoveToEffect(SpotManager().findSpotById(tokenPath.first).tokenPosition,
          EffectController(duration: 0.1, curve: Curves.easeInOut)));

  tokenCollision(world, token);
}

void tokenCollision(World world, Token attackerToken) async {
  final tokensOnSpot = TokenManager()
      .allTokens
      .where((token) => token.positionId == attackerToken.positionId)
      .toList();

  // Initialize the flag to track if any token was attacked
  bool wasTokenAttacked = false;

  // only attacker token on spot, return
  if (tokensOnSpot.length > 1 &&
      !['B04', 'B23', 'R22', 'R10', 'G02', 'G21', 'Y30', 'Y42']
          .contains(attackerToken.positionId)) {
    // Batch token movements
    final tokensToMove = tokensOnSpot
        .where((token) => token.playerId != attackerToken.playerId)
        .toList();

    for (var token in tokensToMove) {
      moveBackward(
        world: world,
        token: token,
        tokenPath: GameState().getTokenPath(token.playerId),
        ludoBoard: GameState().ludoBoard as PositionComponent,
      ).then((_) {
        wasTokenAttacked = true;
      });
    }

    // Wait for all movements to complete
    await Future.wait(tokensToMove.map((token) => moveBackward(
          world: world,
          token: token,
          tokenPath: GameState().getTokenPath(token.playerId),
          ludoBoard: GameState().ludoBoard as PositionComponent,
        )));
  }

  // Grant another turn or switch to next player
  final player = GameState()
      .players
      .firstWhere((player) => player.playerId == attackerToken.playerId);

  if (wasTokenAttacked) {
    if (player.hasRolledThreeConsecutiveSixes()) {
      player.resetExtraTurns();
    }
    player.grantAnotherTurn();
  } else {
    if (GameState().diceNumber != 6) {
      GameState().switchToNextPlayer();
    }
  }

  player.enableDice = true;
  for (var token in player.tokens) {
    token.enableToken = false;
  }

  // Call the function to resize tokens after moveBackward is complete
  resizeTokensOnSpot(world);
}

void resizeTokensOnSpot(World world) {
  // Precompute values
  final homeSpot = getHomeSpot(world, 6)
      .whereType<HomeSpot>()
      .firstWhere((spot) => spot.uniqueId == 'B1');
  final Vector2 originalSize =
      Vector2(homeSpot.size.x * 0.80, homeSpot.size.x * 1.05);

  // Precompute size factors and position increments
  final sizeFactors = {
    1: 1.0,
    2: 0.70,
    3: 0.50,
  };
  final positionIncrements = {
    1: 0,
    2: 10,
    3: 5,
  };

  // Get all tokens
  // final tokens = TokenManager().allTokens;

  // Group tokens by position ID
  final Map<String, List<Token>> tokensByPositionId = {};
  for (var token in TokenManager().allTokens) {
    if (!tokensByPositionId.containsKey(token.positionId)) {
      tokensByPositionId[token.positionId] = [];
    }
    tokensByPositionId[token.positionId]!.add(token);
  }

  tokensByPositionId.forEach((positionId, tokenList) {
    // Precompute spot global position and adjusted position
    final spot = SpotManager().findSpotById(positionId);

    // Compute size factor and position increment
    final sizeFactor = sizeFactors[tokenList.length] ?? 0.50;
    final positionIncrement = positionIncrements[tokenList.length] ?? 5;

    // Resize and reposition tokens
    for (var i = 0; i < tokenList.length; i++) {
      final token = tokenList[i];
      token.size = originalSize * sizeFactor;
      if (token.state == TokenState.inBase) {
        token.position = spot.position;
      } else if (token.state == TokenState.onBoard ||
          token.state == TokenState.inHome) {
        token.position = Vector2(
            spot.tokenPosition.x + i * positionIncrement, spot.tokenPosition.y);
      }
    }
  });
}

void addTokenTrail(List<Token> tokensOnBoard) {
  SpotManager spotManager = SpotManager();
  final colorMap = {
    'B': const Color(0xFFB7E0FF), // Blue color
    'G': const Color(0xFFB6FFA1), // Green color
    'Y': const Color(0xFFFEFFA7), // Yellow color
    'R': const Color(0xFFFF8A8A), // Red color
  };

  for (var token in tokensOnBoard) {
    if (!token.spaceToMove()) {
      continue;
    }

    final colorPrefix =
        token.tokenId.substring(0, 1); // Get the first character
    final color = colorMap[colorPrefix];

    // Set the color if it's determined
    if (color != null) {
      spotManager.findSpotById(token.positionId).paint.color =
          color; // Assuming 'spot' has a 'paint' property
    }
  }
}

Future<void> moveBackward({
  required World world,
  required Token token,
  required List<String> tokenPath,
  required PositionComponent ludoBoard,
}) async {
  final currentIndex = tokenPath.indexOf(token.positionId);
  const finalIndex = 0;

  // Preload audio to avoid delays during playback
  bool audioPlayed = false;

  // Precompute target positions
  List<Vector2> targetPositions = [];
  for (int i = currentIndex; i >= finalIndex; i--) {
    String positionId = tokenPath[i];
    final spot = SpotManager().findSpotById(positionId);
    targetPositions.add(spot.tokenPosition);
  }

  for (int i = 0; i < targetPositions.length; i++) {
    token.positionId = tokenPath[currentIndex - i];

    if (!audioPlayed) {
      FlameAudio.play('move.mp3');
      audioPlayed = true;
    }

    await _applyEffect(
      token,
      MoveToEffect(
        targetPositions[i],
        EffectController(duration: 0.03, curve: Curves.easeInOut),
      ),
    );

    // Optional: Increase delay duration or remove it
    // await Future.delayed(const Duration(milliseconds: 30));
  }

  if (token.playerId == 'BP') {
    await moveTokenToBase(
      world: world,
      token: token,
      tokenBase: TokenManager().blueTokensBase,
      homeSpotIndex: 6,
      ludoBoard: ludoBoard,
    );
  } else if (token.playerId == 'GP') {
    await moveTokenToBase(
      world: world,
      token: token,
      tokenBase: TokenManager().greenTokensBase,
      homeSpotIndex: 2,
      ludoBoard: ludoBoard,
    );
  } else if (token.playerId == 'RP') {
    await moveTokenToBase(
      world: world,
      token: token,
      tokenBase: TokenManager().redTokensBase,
      homeSpotIndex: 0,
      ludoBoard: ludoBoard,
    );
  } else if (token.playerId == 'YP') {
    await moveTokenToBase(
      world: world,
      token: token,
      tokenBase: TokenManager().yellowTokensBase,
      homeSpotIndex: 8,
      ludoBoard: ludoBoard,
    );
  }
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

Future<void> moveForward({
  required World world,
  required Token token,
  required List<String> tokenPath,
  required int diceNumber,
}) async {
  // get all spots
  final currentIndex = tokenPath.indexOf(token.positionId);
  final finalIndex = currentIndex + diceNumber;
  final originalSize = tokenOriginalSize(world).clone();
  final largeSize =
      (Vector2(originalSize.x * 1.30, originalSize.y * 1.30)).clone();

  for (int i = currentIndex + 1; i <= finalIndex && i < tokenPath.length; i++) {
    token.positionId = tokenPath[i];

    await Future.wait([
      _applyEffect(
        token,
        SizeEffect.to(
          largeSize,
          EffectController(duration: 0.1),
        ),
      ),
      _applyEffect(
        token,
        MoveToEffect(
          SpotManager()
              .getSpots()
              .firstWhere((spot) => spot.uniqueId == token.positionId)
              .tokenPosition,
          EffectController(duration: 0.1, curve: Curves.easeInOut),
        ),
      ),
    ]);

    // Restore token to original size
    await _applyEffect(
      token,
      SizeEffect.to(
        originalSize,
        EffectController(duration: 0.1),
      ),
    );
  }

  // if token is in home
  bool isTokenInHome = await checkTokenInHomeAndHandle(token);

  if (isTokenInHome) {
    resizeTokensOnSpot(world);
  } else {
    tokenCollision(world, token);
  }

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

Future<void> moveTokenToBase({
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

  await _applyEffect(
    token,
    MoveToEffect(
      SpotManager().findSpotById(token.positionId).position,
      EffectController(duration: 0.03, curve: Curves.easeInOut),
    ),
  );
  Future.delayed(const Duration(milliseconds: 30));
}

Future<bool> checkTokenInHomeAndHandle(Token token) async {
  // Define home position IDs
  const homePositions = ['BF', 'GF', 'YF', 'RF'];

  // Check if the token is in home
  if (!homePositions.contains(token.positionId)) return false;

  token.state = TokenState.inHome;

  // Cache players from GameState
  // final players = GameState().players;
  final player =
      GameState().players.firstWhere((p) => p.playerId == token.playerId);
  player.totalTokensInHome++;

  // Handle win condition
  if (player.totalTokensInHome == 4) {
    player.hasWon = true;

    // Get winners and non-winners
    final playersWhoWon = GameState().players.where((p) => p.hasWon).toList();
    final playersWhoNotWon =
        GameState().players.where((p) => !p.hasWon).toList();

    // End game condition
    if (playersWhoWon.length == GameState().players.length - 1) {
      playersWhoNotWon.first.rank =
          GameState().players.length; // Rank last player
      player.rank = playersWhoWon.length; // Set rank for current player
      // Disable dice for all players
      for (var p in GameState().players) {
        p.enableDice = false;
      }
      for (var t in TokenManager().allTokens) {
        t.enableToken = false;
      }
      EventBus().emit(OpenPlayerModalEvent());
    } else {
      // Set rank for current player
      player.rank = playersWhoWon.length;
    }
    return true;
  }

  // Grant another turn if not all tokens are home
  player.enableDice = true;

  // Disable tokens for current player
  for (var t in player.tokens) {
    t.enableToken = false;
  }

  // Reset extra turns if applicable
  if (player.hasRolledThreeConsecutiveSixes()) {
    await player.resetExtraTurns();
  }

  player.grantAnotherTurn();
  return true;
}
