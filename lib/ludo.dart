import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:ludo/components/home/home.dart';
import 'package:ludo/managers/game_state.dart';
import 'package:ludo/components/controls/upper_controller.dart';
import 'package:ludo/components/controls/lower_controller.dart';
import 'package:ludo/components/board/ludo_board.dart';
import 'package:ludo/components/controls/ludo_dice.dart';
import 'package:ludo/components/overlays/rank_modal_component.dart';
import 'package:ludo/models/player_team.dart';
import 'package:ludo/managers/ludo_layout_config.dart';
import 'package:ludo/managers/game_initializer.dart';

class Ludo extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  List<PlayerTeam> teams;
  final BuildContext context;

  // Add an unnamed constructor
  Ludo(this.teams, this.context);

  final rand = Random();
  double get width => size.x;
  double get height => size.y;

  late UpperController _upperController;
  late LowerController _lowerController;

  final Map<PlayerTeam, ColorEffect> _blinkEffects = {};
  final Map<PlayerTeam, ColorEffect> _staticEffects = {};

  static final Map<PlayerTeam, TeamBaseConfig> _teamConfigs = {
    PlayerTeam.red: TeamBaseConfig(
      homePlateIndex: 0,
      blinkColor: const Color(0xffa3333d),
      staticColor: GameState().red,
      isUpper: true,
      diceComponentIndex: 0,
    ),
    PlayerTeam.green: TeamBaseConfig(
      homePlateIndex: 2,
      blinkColor: Colors.lightGreenAccent,
      staticColor: GameState().green,
      isUpper: true,
      diceComponentIndex: 2,
    ),
    PlayerTeam.blue: TeamBaseConfig(
      homePlateIndex: 6,
      blinkColor: Colors.lightBlueAccent,
      staticColor: GameState().blue,
      isUpper: false,
      diceComponentIndex: 0,
    ),
    PlayerTeam.yellow: TeamBaseConfig(
      homePlateIndex: 8,
      blinkColor: Colors.yellowAccent,
      staticColor: GameState().yellow,
      isUpper: false,
      diceComponentIndex: 2,
    ),
  };

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

    _upperController = UpperController(
      position: layout.upperControllerPosition,
      width: layout.upperControllerWidth,
      height: layout.upperControllerHeight,
    );
    world.add(_upperController);

    world.add(LudoBoard());

    _lowerController = LowerController(
      position: layout.lowerControllerPosition,
      width: layout.lowerControllerWidth,
      height: layout.lowerControllerHeight,
    );
    world.add(_lowerController);

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
    _lowerController.hidePointer(player.playerId);
    _upperController.hidePointer(player.playerId);
  }

  void blinkBaseForTeam(PlayerTeam team) {
    for (final t in PlayerTeam.values) {
      _updateBaseBlinkAndDice(t, t == team);
    }
  }

  void _updateBaseBlinkAndDice(PlayerTeam team, bool shouldBlink) {
    final config = _teamConfigs[team]!;

    final childrenOfLudoBoard = GameState().ludoBoard?.children.toList();
    if (childrenOfLudoBoard == null || childrenOfLudoBoard.length <= config.homePlateIndex) {
      return;
    }
    final child = childrenOfLudoBoard[config.homePlateIndex];
    final homePlate = child.children.whereType<Home>().firstOrNull;
    if (homePlate == null) return;

    // Initialize effects if they haven't been created yet
    _blinkEffects[team] ??= ColorEffect(
      config.blinkColor,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    _staticEffects[team] ??= ColorEffect(
      config.staticColor,
      EffectController(
        duration: 0.2,
        reverseDuration: 0.2,
        infinite: true,
        alternate: true,
      ),
    );

    // Add the appropriate effect based on shouldBlink
    homePlate.add(shouldBlink ? _blinkEffects[team]! : _staticEffects[team]!);

    // Dice configuration
    final PositionComponent controller = config.isUpper ? _upperController : _lowerController;
    final controllerComponents = controller.children.toList();
    if (controllerComponents.length <= config.diceComponentIndex) return;

    final diceBlock = controllerComponents[config.diceComponentIndex]
        .children
        .whereType<RectangleComponent>()
        .firstOrNull;
    if (diceBlock == null) return;

    final diceContainer = diceBlock.children.whereType<RectangleComponent>().firstOrNull;
    if (diceContainer == null) return;

    if (shouldBlink) {
      final ludoDice = diceContainer.children.whereType<LudoDice>().firstOrNull;
      if (ludoDice == null) {
        final playerList = GameState().players.where((p) => p.playerId == team).toList();
        if (playerList.isNotEmpty) {
          final player = playerList.first;
          diceContainer.add(LudoDice(
            player: player,
            faceSize: diceBlock.size.x * 0.70,
          ));
          if (config.isUpper) {
            _upperController.showPointer(player.playerId);
          } else {
            _lowerController.showPointer(player.playerId);
          }
        }
      }
    } else {
      final ludoDice = diceContainer.children.whereType<LudoDice>().firstOrNull;
      if (ludoDice != null) {
        diceContainer.remove(ludoDice);
      }
    }
  }

  Future<void> startGame() async {
    await GameInitializer.run(this, teams);
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

class TeamBaseConfig {
  final int homePlateIndex;
  final Color blinkColor;
  final Color staticColor;
  final bool isUpper;
  final int diceComponentIndex;

  const TeamBaseConfig({
    required this.homePlateIndex,
    required this.blinkColor,
    required this.staticColor,
    required this.isUpper,
    required this.diceComponentIndex,
  });
}

