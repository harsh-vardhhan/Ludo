import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'state/player.dart';
import 'component/home/home.dart';
import 'state/token_manager.dart';
import 'state/event_bus.dart';
import 'state/game_state.dart';
import 'state/audio_manager.dart';
import 'component/controller/upper_controller.dart';
import 'component/controller/lower_controller.dart';
import 'ludo_board.dart';
import 'component/ui_components/spot.dart';
import 'component/ui_components/ludo_dice.dart';
import 'component/ui_components/rank_modal_component.dart';
import 'state/home_spot_manager.dart';
import 'state/player_team.dart';

class Ludo extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  List<PlayerTeam> teams;
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

    /*
    add(FpsTextComponent(
      position: Vector2(10, 10), // Adjust position as needed
      anchor: Anchor.topLeft, // Set anchor to align top-left
    ));
    */

    GameState().ludoBoard = world.children.whereType<LudoBoard>().first;
    final ludoBoard = GameState().ludoBoard as PositionComponent;
    GameState().ludoBoardAbsolutePosition = ludoBoard.absolutePosition;

    EventBus().on<OpenPlayerModalEvent>((event) {
      showPlayerModal();
    });

    EventBus().on<SwitchPointerEvent>((event) {
      switchOffPointer();
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

  void switchOffPointer() {
    final player = GameState().players[GameState().currentPlayerIndex];
    final lowerController = world.children.whereType<LowerController>().first;
    lowerController.hidePointer(player.playerId);
    final upperController = world.children.whereType<UpperController>().first;
    upperController.hidePointer(player.playerId);
  }

  void blinkRedBase(bool shouldBlink) {
    final childrenOfLudoBoard = GameState().ludoBoard?.children.toList();
    final child = childrenOfLudoBoard![0];
    final home = child.children.toList();
    final homePlate = home[0] as Home;

    // Initialize effects if they haven't been created yet
    _redBlinkEffect ??= ColorEffect(
      const Color(0xffa3333d),
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    _redStaticEffect ??= ColorEffect(
      GameState().red,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    // dice for player red
    final upperController = world.children.whereType<UpperController>().first;
    final upperControllerComponents = upperController.children.toList();
    final leftDice = upperControllerComponents[0]
        .children
        .whereType<RectangleComponent>()
        .first;

    final rightDiceContainer =
        leftDice.children.whereType<RectangleComponent>().first;

    // Add the appropriate effect based on shouldBlink
    homePlate.add(shouldBlink ? _redBlinkEffect! : _redStaticEffect!);

    if (shouldBlink) {
      final ludoDice =
          rightDiceContainer.children.whereType<LudoDice>().firstOrNull;
      if (ludoDice == null) {
        if (GameState().players.isNotEmpty) {
          final player = GameState().players[GameState().currentPlayerIndex];
          rightDiceContainer.add(LudoDice(
            player: GameState().players[GameState().currentPlayerIndex],
            faceSize: leftDice.size.x * 0.70,
          ));
          upperController.showPointer(player.playerId);
        }
      }
    } else {
      final ludoDice =
          rightDiceContainer.children.whereType<LudoDice>().firstOrNull;
      if (ludoDice != null) {
        rightDiceContainer.remove(ludoDice);
      }
    }
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
      GameState().yellow,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    final lowerController = world.children.whereType<LowerController>().first;
    final lowerControllerComponents = lowerController.children.toList();
    final rightDice = lowerControllerComponents[2]
        .children
        .whereType<RectangleComponent>()
        .first;

    final rightDiceContainer =
        rightDice.children.whereType<RectangleComponent>().first;

    // Add the appropriate effect based on shouldBlink
    homePlate.add(shouldBlink ? _yellowBlinkEffect! : _yellowStaticEffect!);

    if (shouldBlink) {
      final player = GameState().players[GameState().currentPlayerIndex];
      rightDiceContainer.add(LudoDice(
        player: player,
        faceSize: rightDice.size.x * 0.70,
      ));
      lowerController.showPointer(player.playerId);
    } else {
      final ludoDice =
          rightDiceContainer.children.whereType<LudoDice>().firstOrNull;
      if (ludoDice != null) {
        rightDiceContainer.remove(ludoDice);
      }
    }
  }

  void blinkBlueBase(bool shouldBlink) {
    final childrenOfLudoBoard = GameState().ludoBoard?.children.toList();
    final child = childrenOfLudoBoard![6];
    final home = child.children.toList();
    final homePlate = home[0] as Home;

    // Initialize effects if they haven't been created yet
    _blueBlinkEffect ??= ColorEffect(
      Colors.lightBlueAccent,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    _blueStaticEffect ??= ColorEffect(
      GameState().blue,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    // dice for player blue
    final lowerController = world.children.whereType<LowerController>().first;
    final lowerControllerComponents = lowerController.children.toList();
    final leftDice = lowerControllerComponents[0]
        .children
        .whereType<RectangleComponent>()
        .first;

    final leftDiceContainer =
        leftDice.children.whereType<RectangleComponent>().first;

    // Add the appropriate effect based on shouldBlink
    homePlate.add(shouldBlink ? _blueBlinkEffect! : _blueStaticEffect!);

    if (shouldBlink) {
      final ludoDice =
          leftDiceContainer.children.whereType<LudoDice>().firstOrNull;
      if (ludoDice == null) {
        if (GameState().players.isNotEmpty) {
          final player = GameState().players[GameState().currentPlayerIndex];
          leftDiceContainer.add(LudoDice(
            player: player,
            faceSize: leftDice.size.x * 0.70,
          ));
          lowerController.showPointer(player.playerId);
        }
      }
    } else {
      final ludoDice =
          leftDiceContainer.children.whereType<LudoDice>().firstOrNull;
      if (ludoDice != null) {
        leftDiceContainer.remove(ludoDice);
      }
    }
  }

  void blinkGreenBase(bool shouldBlink) {
    final childrenOfLudoBoard = GameState().ludoBoard?.children.toList();
    final child = childrenOfLudoBoard![2];
    final home = child.children.toList();
    final homePlate = home[0] as Home;

    // Initialize effects if they haven't been created yet
    _greenBlinkEffect ??= ColorEffect(
      Colors.lightGreenAccent,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    _greenStaticEffect ??= ColorEffect(
      GameState().green,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    // dice for player green
    final upperController = world.children.whereType<UpperController>().first;
    final upperControllerComponents = upperController.children.toList();
    final rightDice = upperControllerComponents[2]
        .children
        .whereType<RectangleComponent>()
        .first;

    final rightDiceContainer =
        rightDice.children.whereType<RectangleComponent>().first;

    // Add the appropriate effect based on shouldBlink
    homePlate.add(shouldBlink ? _greenBlinkEffect! : _greenStaticEffect!);

    if (shouldBlink) {
      final player = GameState().players[GameState().currentPlayerIndex];
      rightDiceContainer.add(LudoDice(
        player: GameState().players[GameState().currentPlayerIndex],
        faceSize: rightDice.size.x * 0.70,
      ));
      upperController.showPointer(player.playerId);
    } else {
      final ludoDice =
          rightDiceContainer.children.whereType<LudoDice>().firstOrNull;
      if (ludoDice != null) {
        rightDiceContainer.remove(ludoDice);
      }
    }
  }

  Future<void> startGame() async {
    await TokenManager().clearTokens();
    await GameState().clearPlayers();
    await AudioManager.dispose();

    AudioManager.initialize();

    for (var team in teams) {
      if (team == PlayerTeam.blue) {
        if (TokenManager().getBlueTokens().isEmpty) {
          TokenManager().initializeTokens(TokenManager().blueTokensBase);

          const homeSpotSizeFactorX = 0.10;
          const homeSpotSizeFactorY = 0.05;
          const tokenSizeFactorX = 0.80;
          const tokenSizeFactorY = 1.05;

          for (var token in TokenManager().getBlueTokens()) {
            final homeSpot = HomeSpotManager().getHomeSpotById(token.positionId)!;
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
            token.sideColor = const Color(0xFF0D92F4);
            token.topColor = const Color(0xFF77CDFF);

            token.position = spot.position;
            token.size = Vector2(
              homeSpot.size.x * tokenSizeFactorX,
              homeSpot.size.x * tokenSizeFactorY,
            );
            GameState().ludoBoard?.add(token);
          }

          const playerId = PlayerTeam.blue;
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

            addDice() {
              // dice for player blue
              final lowerController =
                  world.children.whereType<LowerController>().first;
              final lowerControllerComponents =
                  lowerController.children.toList();
              final leftDice = lowerControllerComponents[0]
                  .children
                  .whereType<RectangleComponent>()
                  .first;

              final leftDiceContainer =
                  leftDice.children.whereType<RectangleComponent>().first;

              leftDiceContainer.add(LudoDice(
                player: bluePlayer,
                faceSize: leftDice.size.x * 0.70,
              ));
              lowerController.showPointer(bluePlayer.playerId);
            }

            addDice();
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
        }
      } else if (team == PlayerTeam.green) {
        if (TokenManager().getGreenTokens().isEmpty) {
          TokenManager().initializeTokens(TokenManager().greenTokensBase);

          final ludoBoardPosition = GameState().ludoBoardAbsolutePosition;
          const homeSpotSizeFactorX = 0.10;
          const homeSpotSizeFactorY = 0.05;
          const tokenSizeFactorX = 0.80;
          const tokenSizeFactorY = 1.05;

          for (var token in TokenManager().getGreenTokens()) {
            final homeSpot = HomeSpotManager().getHomeSpotById(token.positionId)!;
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
            token.sideColor = const Color(0xFF54C392);
            token.topColor = const Color(0xFF73EC8B);
            token.position = spot.position;
            token.size = Vector2(
              homeSpot.size.x * tokenSizeFactorX,
              homeSpot.size.x * tokenSizeFactorY,
            );
            GameState().ludoBoard?.add(token);
          }

          const playerId = PlayerTeam.green;
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
        }
      } else if (team == PlayerTeam.yellow) {
        if (TokenManager().getYellowTokens().isEmpty) {
          TokenManager().initializeTokens(TokenManager().yellowTokensBase);

          final ludoBoardPosition = GameState().ludoBoardAbsolutePosition;
          const homeSpotSizeFactorX = 0.10;
          const homeSpotSizeFactorY = 0.05;
          const tokenSizeFactorX = 0.80;
          const tokenSizeFactorY = 1.05;

          for (var token in TokenManager().getYellowTokens()) {
            final homeSpot = HomeSpotManager().getHomeSpotById(token.positionId)!;
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
            token.sideColor = const Color(0xffc9a227);
            token.topColor = const Color(0xffFFDF5B);
            token.position = spot.position;
            token.size = Vector2(
              homeSpot.size.x * tokenSizeFactorX,
              homeSpot.size.x * tokenSizeFactorY,
            );
            GameState().ludoBoard?.add(token);
          }

          const playerId = PlayerTeam.yellow;
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
            addDice() {
              // dice for player yellow
              final lowerController =
                  world.children.whereType<LowerController>().first;
              final lowerControllerComponents =
                  lowerController.children.toList();
              final rightDice = lowerControllerComponents[2]
                  .children
                  .whereType<RectangleComponent>()
                  .first;

              final rightDiceContainer =
                  rightDice.children.whereType<RectangleComponent>().first;

              rightDiceContainer.add(LudoDice(
                player: yellowPlayer,
                faceSize: rightDice.size.x * 0.70,
              ));
            }

            addDice();
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
        }
      } else if (team == PlayerTeam.red) {
        if (TokenManager().getRedTokens().isEmpty) {
          TokenManager().initializeTokens(TokenManager().redTokensBase);

          final ludoBoardPosition = GameState().ludoBoardAbsolutePosition;
          const homeSpotSizeFactorX = 0.10;
          const homeSpotSizeFactorY = 0.05;
          const tokenSizeFactorX = 0.80;
          const tokenSizeFactorY = 1.05;

          for (var token in TokenManager().getRedTokens()) {
            final homeSpot = HomeSpotManager().getHomeSpotById(token.positionId)!;
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
            token.sideColor = const Color(0xff780000);
            token.topColor = const Color(0xffFF5B5B);
            token.position = spot.position;
            token.size = Vector2(
              homeSpot.size.x * tokenSizeFactorX,
              homeSpot.size.x * tokenSizeFactorY,
            );
            GameState().ludoBoard?.add(token);
          }

          const playerId = PlayerTeam.red;
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

            addDice() {
              // dice for player red
              final upperController =
                  world.children.whereType<UpperController>().first;
              final upperControllerComponents =
                  upperController.children.toList();
              final leftDice = upperControllerComponents[0]
                  .children
                  .whereType<RectangleComponent>()
                  .first;

              final rightDiceContainer =
                  leftDice.children.whereType<RectangleComponent>().first;
              rightDiceContainer.add(LudoDice(
                player: redPlayer,
                faceSize: leftDice.size.x * 0.70,
              ));
            }

            addDice();
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

