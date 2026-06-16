import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:ludo/models/player.dart';
import 'package:ludo/components/home/home.dart';
import 'package:ludo/managers/token_manager.dart';
import 'package:ludo/managers/game_state.dart';
import 'package:ludo/managers/audio_manager.dart';
import 'package:ludo/components/controls/upper_controller.dart';
import 'package:ludo/components/controls/lower_controller.dart';
import 'package:ludo/components/board/ludo_board.dart';
import 'package:ludo/components/board/spot.dart';
import 'package:ludo/components/controls/ludo_dice.dart';
import 'package:ludo/components/overlays/rank_modal_component.dart';
import 'package:ludo/managers/tile_manager.dart';
import 'package:ludo/models/player_team.dart';
import 'package:ludo/components/board/token.dart';
import 'package:ludo/managers/ludo_layout_config.dart';

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
    GameState().game = this;
    camera = CameraComponent.withFixedResolution(
      width: width,
      height: height,
    );
    camera.viewfinder.anchor = Anchor.topLeft;

    final layout = LudoLayoutConfig(screenWidth: width, screenHeight: height);
    GameState().layoutConfig = layout;

    world.add(UpperController(
        position: layout.upperControllerPosition,
        width: layout.upperControllerWidth,
        height: layout.upperControllerHeight));
    world.add(LudoBoard());
    world.add(LowerController(
        position: layout.lowerControllerPosition,
        width: layout.lowerControllerWidth,
        height: layout.lowerControllerHeight));

    /*
    add(FpsTextComponent(
      position: Vector2(10, 10), // Adjust position as needed
      anchor: Anchor.topLeft, // Set anchor to align top-left
    ));
    */

    GameState().ludoBoard = world.children.whereType<LudoBoard>().first;
    final ludoBoard = GameState().ludoBoard as PositionComponent;
    GameState().ludoBoardAbsolutePosition = ludoBoard.absolutePosition;

    await startGame();
  }

  void switchOffPointer() {
    final player = GameState().players[GameState().currentPlayerIndex];
    final lowerController = world.children.whereType<LowerController>().first;
    lowerController.hidePointer(player.playerId);
    final upperController = world.children.whereType<UpperController>().first;
    upperController.hidePointer(player.playerId);
  }

  void blinkBaseForTeam(PlayerTeam team) {
    blinkGreenBase(team == PlayerTeam.green);
    blinkBlueBase(team == PlayerTeam.blue);
    blinkRedBase(team == PlayerTeam.red);
    blinkYellowBase(team == PlayerTeam.yellow);
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
            final homeSpot = TileManager().getHomeSpot(token.positionId)!;
            final spot = Spot.findSpotById(token.positionId);
            // update spot position
            spot.position = Vector2(
              homeSpot.absolutePosition.x +
                  (homeSpot.size.x * homeSpotSizeFactorX) -
                  GameState().ludoBoardAbsolutePosition.x,
              homeSpot.absolutePosition.y -
                  (homeSpot.size.x * homeSpotSizeFactorY) -
                  GameState().ludoBoardAbsolutePosition.y,
            );

            final tokenComp = TokenComponent(
              token: token,
              position: spot.position,
              size: Vector2(
                homeSpot.size.x * tokenSizeFactorX,
                homeSpot.size.x * tokenSizeFactorY,
              ),
              topColor: const Color(0xFF77CDFF),
              sideColor: const Color(0xFF0D92F4),
            );
            GameState().registerTokenComponent(tokenComp);
            GameState().ludoBoard?.add(tokenComp);
          }

          const playerId = PlayerTeam.blue;

          if (GameState().players.isEmpty) {
            blinkBlueBase(true);
            Player bluePlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getBlueTokens(),
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
            final homeSpot = TileManager().getHomeSpot(token.positionId)!;
            final spot = Spot.findSpotById(token.positionId);
            // update spot position
            spot.position = Vector2(
              homeSpot.absolutePosition.x +
                  (homeSpot.size.x * homeSpotSizeFactorX) -
                  ludoBoardPosition.x,
              homeSpot.absolutePosition.y -
                  (homeSpot.size.x * homeSpotSizeFactorY) -
                  ludoBoardPosition.y,
            );

            final tokenComp = TokenComponent(
              token: token,
              position: spot.position,
              size: Vector2(
                homeSpot.size.x * tokenSizeFactorX,
                homeSpot.size.x * tokenSizeFactorY,
              ),
              topColor: const Color(0xFF73EC8B),
              sideColor: const Color(0xFF54C392),
            );
            GameState().registerTokenComponent(tokenComp);
            GameState().ludoBoard?.add(tokenComp);
          }

          const playerId = PlayerTeam.green;

          if (GameState().players.isEmpty) {
            blinkGreenBase(true);
            Player greenPlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getGreenTokens(),
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
            final homeSpot = TileManager().getHomeSpot(token.positionId)!;
            final spot = Spot.findSpotById(token.positionId);
            // update spot position
            spot.position = Vector2(
              homeSpot.absolutePosition.x +
                  (homeSpot.size.x * homeSpotSizeFactorX) -
                  ludoBoardPosition.x,
              homeSpot.absolutePosition.y -
                  (homeSpot.size.x * homeSpotSizeFactorY) -
                  ludoBoardPosition.y,
            );

            final tokenComp = TokenComponent(
              token: token,
              position: spot.position,
              size: Vector2(
                homeSpot.size.x * tokenSizeFactorX,
                homeSpot.size.x * tokenSizeFactorY,
              ),
              topColor: const Color(0xffFFDF5B),
              sideColor: const Color(0xffc9a227),
            );
            GameState().registerTokenComponent(tokenComp);
            GameState().ludoBoard?.add(tokenComp);
          }

          const playerId = PlayerTeam.yellow;

          if (GameState().players.isEmpty) {
            blinkYellowBase(true);
            Player yellowPlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getYellowTokens(),
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
            final homeSpot = TileManager().getHomeSpot(token.positionId)!;
            final spot = Spot.findSpotById(token.positionId);
            // update spot position
            spot.position = Vector2(
              homeSpot.absolutePosition.x +
                  (homeSpot.size.x * homeSpotSizeFactorX) -
                  ludoBoardPosition.x,
              homeSpot.absolutePosition.y -
                  (homeSpot.size.x * homeSpotSizeFactorY) -
                  ludoBoardPosition.y,
            );

            final tokenComp = TokenComponent(
              token: token,
              position: spot.position,
              size: Vector2(
                homeSpot.size.x * tokenSizeFactorX,
                homeSpot.size.x * tokenSizeFactorY,
              ),
              topColor: const Color(0xffFF5B5B),
              sideColor: const Color(0xff780000),
            );
            GameState().registerTokenComponent(tokenComp);
            GameState().ludoBoard?.add(tokenComp);
          }

          const playerId = PlayerTeam.red;

          if (GameState().players.isEmpty) {
            blinkRedBase(true);
            Player redPlayer = Player(
              playerId: playerId,
              tokens: TokenManager().getRedTokens(),
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

