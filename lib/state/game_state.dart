import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:ludo/component/ui_components/token.dart';
import 'package:ludo/state/token_manager.dart';
import 'token.dart';
import 'ludo_game_state.dart';
import 'ludo_layout_config.dart';
import 'package:ludo/component/ui_components/spot.dart';
import 'package:ludo/component/controller/lower_controller.dart';
import 'package:ludo/component/controller/upper_controller.dart';

import 'player.dart';
import 'player_team.dart';
import 'event_bus.dart';

class GameState {
  // Private constructor
  GameState._();

  // Singleton instance
  static final GameState _instance = GameState._();

  late final LudoLayoutConfig layoutConfig;
  LudoGameState state = LudoGameState.needRoll;

  final Map<String, TokenComponent> _tokenComponentMap = {};

  void registerTokenComponent(TokenComponent component) {
    _tokenComponentMap[component.token.tokenId] = component;
  }

  TokenComponent? getComponentForToken(Token token) {
    return _tokenComponentMap[token.tokenId];
  }

  List<int> diceChances =
      List.filled(3, 0, growable: false); // Track consecutive 6s
  var diceNumber = 5;

  List<Player> players = [];
  int currentPlayerIndex = 0;

  bool canMoveTokenFromBase = false;
  bool canMoveTokenOnBoard = false;

  Vector2 ludoBoardAbsolutePosition = Vector2.zero();
  Component? ludoBoard;

  final red = const Color(0xffFF5B5B);
  final green = const Color(0xFF41B06E);
  final blue = const Color(0xFF0D92F4);
  final yellow = const Color(0xFFFFD966);

  // Factory method to access the instance
  factory GameState() {
    return _instance;
  }

  void enableMoveFromBase() {
    canMoveTokenFromBase = true;
    canMoveTokenOnBoard = false;
  }

  void enableMoveOnBoard() {
    canMoveTokenFromBase = false;
    canMoveTokenOnBoard = true;
  }

  void enableMoveFromBoth() {
    canMoveTokenFromBase = true;
    canMoveTokenOnBoard = true;
  }

  void resetTokenMovement() {
    canMoveTokenFromBase = false;
    canMoveTokenOnBoard = false;
  }

  void hidePointer() {
    EventBus().emit(SwitchPointerEvent());
  }

  void switchToNextPlayer() {
    state = LudoGameState.needRoll;
    var current = currentPlayer;
    current.isCurrentTurn = false;
    current.enableDice = false;
    EventBus().emit(SwitchPointerEvent());
    current.resetExtraTurns();

    // Loop to find the next player who hasn't won
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } while (players[currentPlayerIndex].hasWon);

    var nextPlayer = players[currentPlayerIndex];
    nextPlayer.isCurrentTurn = true;
    nextPlayer.enableDice = true;

    // Disable tokens of the current player
    for (var token in currentPlayer.tokens) {
      token.enableToken = false;
    }

    // Emit events based on the next player's ID
    switch (nextPlayer.playerId) {
      case PlayerTeam.green:
        EventBus().emit(BlinkGreenBaseEvent());
        break;
      case PlayerTeam.blue:
        EventBus().emit(BlinkBlueBaseEvent());
        break;
      case PlayerTeam.red:
        EventBus().emit(BlinkRedBaseEvent());
        break;
      case PlayerTeam.yellow:
        EventBus().emit(BlinkYellowBaseEvent());
        break;
    }
  }

  // Get the current player
  Player get currentPlayer => players[currentPlayerIndex];

  Future<void> clearPlayers() async {
    players.clear();
    currentPlayerIndex = 0;
    diceNumber = 5;
    resetTokenMovement();
    _tokenComponentMap.clear();
    state = LudoGameState.needRoll;
    return Future.value();
  }

  static const blueTokenPath = [
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
    'BF',
  ];

  static const greenTokenPath = [
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
    'GF',
  ];

  static const redTokenPath = [
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
    'R11',
    'R21',
    'R31',
    'R41',
    'R51',
    'RF',
  ];

  static const yellowTokenPath = [
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
    'Y41',
    'Y31',
    'Y21',
    'Y11',
    'Y01',
    'YF',
  ];

  final Map<PlayerTeam, List<String>> tokenPaths = {
    PlayerTeam.blue: blueTokenPath,
    PlayerTeam.green: greenTokenPath,
    PlayerTeam.red: redTokenPath,
    PlayerTeam.yellow: yellowTokenPath,
  };

  List<String> getTokenPath(PlayerTeam playerId) {
    return tokenPaths[playerId] ?? [];
  }

  Future<void> _applyEffect(PositionComponent component, Effect effect) {
    final completer = Completer<void>();
    effect.onComplete = completer.complete;
    component.add(effect);
    return completer.future;
  }

  void moveOutOfBase({
    required World world,
    required Token token,
    required List<String> tokenPath,
  }) async {
    token.positionId = tokenPath.first;
    token.state = TokenState.onBoard;

    await _applyEffect(
        getComponentForToken(token)!,
        MoveToEffect(SpotManager().findSpotById(tokenPath.first).tokenPosition,
            EffectController(duration: 0.1, curve: Curves.easeInOut)));

    tokenCollision(world, token);
  }

  void tokenCollision(World world, Token attackerToken) async {
    final tokensOnSpot = TokenManager()
        .allTokens
        .where((token) => token.positionId == attackerToken.positionId)
        .toList();

    bool wasTokenAttacked = false;

    // Safe spots list (replaces inline magic array check)
    const safeSpots = ['B04', 'B23', 'R22', 'R10', 'G02', 'G21', 'Y30', 'Y42'];

    if (tokensOnSpot.length > 1 &&
        !safeSpots.contains(attackerToken.positionId)) {
      final tokensToMove = tokensOnSpot
          .where((token) => token.playerId != attackerToken.playerId)
          .toList();

      if (tokensToMove.isNotEmpty) {
        wasTokenAttacked = true;
      }

      await Future.wait(tokensToMove.map((token) => moveBackward(
            world: world,
            token: token,
            tokenPath: getTokenPath(token.playerId),
            ludoBoard: ludoBoard as PositionComponent,
          )));
    }

    final player = players.firstWhere((p) => p.playerId == attackerToken.playerId);

    if (wasTokenAttacked) {
      if (player.hasRolledThreeConsecutiveSixes()) {
        player.resetExtraTurns();
      }
      player.grantAnotherTurn();
    } else {
      if (diceNumber != 6) {
        switchToNextPlayer();
      }
    }

    player.enableDice = true;

    if (diceNumber == 6 || wasTokenAttacked) {
      final lowerController = world.children.whereType<LowerController>().first;
      final upperController = world.children.whereType<UpperController>().first;
      lowerController.showPointer(player.playerId);
      upperController.showPointer(player.playerId);
    }

    for (var token in player.tokens) {
      token.enableToken = false;
    }

    resizeTokensOnSpot(world);
  }

  void resizeTokensOnSpot(World world) {
    const positionIncrements = {
      1: 0,
      2: 10,
      3: 5,
    };

    final Map<String, List<Token>> tokensByPositionId = {};
    for (var token in TokenManager().allTokens) {
      if (!tokensByPositionId.containsKey(token.positionId)) {
        tokensByPositionId[token.positionId] = [];
      }
      tokensByPositionId[token.positionId]!.add(token);
    }

    tokensByPositionId.forEach((positionId, tokenList) {
      final spot = SpotManager().findSpotById(positionId);
      final positionIncrement = positionIncrements[tokenList.length] ?? 5;

      for (var i = 0; i < tokenList.length; i++) {
        final token = tokenList[i];
        final tokenComp = getComponentForToken(token);
        if (tokenComp != null) {
          if (token.state == TokenState.inBase) {
            tokenComp.position = spot.position;
          } else if (token.state == TokenState.onBoard ||
              token.state == TokenState.inHome) {
            tokenComp.position = Vector2(
                spot.tokenPosition.x + i * positionIncrement, spot.tokenPosition.y);
          }
        }
      }
    });
  }

  void addTokenTrail(List<Token> tokensInBase, List<Token> tokensOnBoard) {
    final trailingTokens = <Token>[];

    for (var token in tokensOnBoard) {
      if (!token.spaceToMove()) {
        continue;
      }
      trailingTokens.add(token);
    }

    if (diceNumber == 6) {
      for (var token in tokensInBase) {
        trailingTokens.add(token);
      }
    }

    for (var token in trailingTokens) {
      getComponentForToken(token)?.enableCircleAnimation();
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
    bool audioPlayed = false;

    for (int i = currentIndex; i >= finalIndex; i--) {
      token.positionId = tokenPath[i];

      if (!audioPlayed) {
        FlameAudio.play('move.mp3');
        audioPlayed = true;
      }

      await _applyEffect(
        getComponentForToken(token)!,
        MoveToEffect(
          SpotManager()
              .getSpots()
              .firstWhere((spot) => spot.uniqueId == token.positionId)
              .tokenPosition,
          EffectController(duration: 0.1, curve: Curves.easeInOut),
        ),
      );
    }

    if (token.playerId == PlayerTeam.blue) {
      await moveTokenToBase(
        world: world,
        token: token,
        tokenBase: TokenManager().blueTokensBase,
        homeSpotIndex: 6,
        ludoBoard: ludoBoard,
      );
    } else if (token.playerId == PlayerTeam.green) {
      await moveTokenToBase(
        world: world,
        token: token,
        tokenBase: TokenManager().greenTokensBase,
        homeSpotIndex: 2,
        ludoBoard: ludoBoard,
      );
    } else if (token.playerId == PlayerTeam.red) {
      await moveTokenToBase(
        world: world,
        token: token,
        tokenBase: TokenManager().redTokensBase,
        homeSpotIndex: 0,
        ludoBoard: ludoBoard,
      );
    } else if (token.playerId == PlayerTeam.yellow) {
      await moveTokenToBase(
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
  }) async {
    final currentIndex = tokenPath.indexOf(token.positionId);
    final finalIndex = currentIndex + diceNumber;

    for (int i = currentIndex + 1; i <= finalIndex && i < tokenPath.length; i++) {
      token.positionId = tokenPath[i];
      await _applyEffect(
        getComponentForToken(token)!,
        MoveToEffect(
          SpotManager()
              .getSpots()
              .firstWhere((spot) => spot.uniqueId == token.positionId)
              .tokenPosition,
          EffectController(duration: 0.12, curve: Curves.easeInOut),
        ),
      );

      // Add a small delay to reduce CPU strain and smooth the animation
      await Future.delayed(const Duration(milliseconds: 120));
    }

    bool isTokenInHome = await checkTokenInHomeAndHandle(token, world);

    if (isTokenInHome) {
      resizeTokensOnSpot(world);
    } else {
      tokenCollision(world, token);
    }
    clearTokenTrail();
  }

  void clearTokenTrail() {
    for (var token in TokenManager().allTokens) {
      getComponentForToken(token)?.disableCircleAnimation();
    }
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
      getComponentForToken(token)!,
      MoveToEffect(
        SpotManager().findSpotById(token.positionId).position,
        EffectController(duration: 0.03, curve: Curves.easeInOut),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 30));
  }

  Future<bool> checkTokenInHomeAndHandle(Token token, World world) async {
    const homePositions = ['BF', 'GF', 'YF', 'RF'];

    if (!homePositions.contains(token.positionId)) return false;

    token.state = TokenState.inHome;

    final player = players.firstWhere((p) => p.playerId == token.playerId);
    player.totalTokensInHome++;

    if (player.totalTokensInHome == 4) {
      player.hasWon = true;

      final playersWhoWon = players.where((p) => p.hasWon).toList();
      final playersWhoNotWon = players.where((p) => !p.hasWon).toList();

      if (playersWhoWon.length == players.length - 1) {
        playersWhoNotWon.first.rank = players.length;
        player.rank = playersWhoWon.length;
        for (var p in players) {
          p.enableDice = false;
        }
        for (var t in TokenManager().allTokens) {
          t.enableToken = false;
        }
        EventBus().emit(OpenPlayerModalEvent());
      } else {
        player.rank = playersWhoWon.length;
      }
      return true;
    }

    player.enableDice = true;
    final lowerController = world.children.whereType<LowerController>().first;
    lowerController.showPointer(player.playerId);
    final upperController = world.children.whereType<UpperController>().first;
    upperController.showPointer(player.playerId);

    for (var t in player.tokens) {
      t.enableToken = false;
    }

    if (player.hasRolledThreeConsecutiveSixes()) {
      await player.resetExtraTurns();
    }

    player.grantAnotherTurn();
    return true;
  }

  int rollDice() {
    state = LudoGameState.rolling;
    diceNumber = Random().nextInt(6) + 1;
    return diceNumber;
  }

  void resolveDiceRoll(World world) {
    state = LudoGameState.resolving;
    final handleRoll = diceNumber == 6 ? _handleSixRoll : _handleNonSixRoll;
    handleRoll(world);
  }

  void _handleSixRoll(World world) {
    final player = currentPlayer;
    player.grantAnotherTurn();

    if (player.hasRolledThreeConsecutiveSixes()) {
      switchToNextPlayer();
      return;
    }

    final tokensInBase = player.tokens
        .where((token) => token.state == TokenState.inBase)
        .toList();

    final tokensOnBoard = player.tokens
        .where((token) => token.state == TokenState.onBoard)
        .toList();

    final movableTokens =
        tokensOnBoard.where((token) => token.spaceToMove()).toList();

    final allMovableTokens = [...movableTokens, ...tokensInBase];

    if (allMovableTokens.length == 1) {
      if (allMovableTokens.first.state == TokenState.inBase) {
        moveOutOfBase(
          world: world,
          token: allMovableTokens.first,
          tokenPath: getTokenPath(player.playerId),
        );
      } else if (allMovableTokens.first.state == TokenState.onBoard) {
        moveForward(
          world: world,
          token: allMovableTokens.first,
          tokenPath: getTokenPath(player.playerId),
          diceNumber: diceNumber,
        );
      }
      return;
    } else if (allMovableTokens.length > 1) {
      _enableManualTokenSelection(world, tokensInBase, tokensOnBoard);
    } else if (allMovableTokens.isEmpty) {
      switchToNextPlayer();
      return;
    }
  }

  void _handleNonSixRoll(World world) {
    final player = currentPlayer;
    final tokensOnBoard = player.tokens
        .where((token) => token.state == TokenState.onBoard)
        .toList();

    if (tokensOnBoard.isEmpty) {
      switchToNextPlayer();
      return;
    }

    final movableTokens =
        tokensOnBoard.where((token) => token.spaceToMove()).toList();
    final tokensInBase = player.tokens
        .where((token) => token.state == TokenState.inBase)
        .toList();

    if (movableTokens.length == 1) {
      moveForward(
        world: world,
        token: movableTokens.first,
        tokenPath: getTokenPath(player.playerId),
        diceNumber: diceNumber,
      );
      return;
    } else if (movableTokens.length > 1) {
      _enableManualTokenSelection(world, tokensInBase, tokensOnBoard);
    } else if (movableTokens.isEmpty) {
      switchToNextPlayer();
      return;
    }
  }

  void _enableManualTokenSelection(
      World world, List<Token> tokensInBase, List<Token> tokensOnBoard) {
    state = LudoGameState.needMove;
    final player = currentPlayer;
    hidePointer();
    player.enableDice = false;

    for (var token in player.tokens) {
      token.enableToken = true;
    }
    if (tokensInBase.isNotEmpty && tokensOnBoard.isNotEmpty) {
      enableMoveFromBoth();
      addTokenTrail(tokensInBase, tokensOnBoard);
    } else if (tokensInBase.isNotEmpty) {
      enableMoveFromBase();
      addTokenTrail(tokensInBase, tokensOnBoard);
    } else if (tokensOnBoard.isNotEmpty) {
      addTokenTrail(tokensInBase, tokensOnBoard);
      enableMoveOnBoard();
    }
  }

  void handleTokenTap(World world, Token token) {
    if (!token.spaceToMove() ||
        !token.enableToken ||
        (token.isInBase() && diceNumber != 6) ||
        token.isInHome()) {
      return;
    }

    token.enableToken = false;

    if (currentPlayer.playerId != token.playerId) {
      return;
    }

    state = LudoGameState.moving;

    for (var t in TokenManager().allTokens) {
      getComponentForToken(t)?.disableCircleAnimation();
      t.enableToken = false;
    }

    if (diceNumber == 6) {
      if (token.state == TokenState.inBase && canMoveTokenFromBase) {
        moveOutOfBase(
            world: world,
            token: token,
            tokenPath: getTokenPath(token.playerId));
      } else if (token.state == TokenState.onBoard && canMoveTokenOnBoard) {
        moveForward(
            world: world,
            token: token,
            tokenPath: getTokenPath(token.playerId),
            diceNumber: diceNumber);
      }
      return;
    }

    if (token.state == TokenState.onBoard && canMoveTokenOnBoard) {
      moveForward(
          world: world,
          token: token,
          tokenPath: getTokenPath(token.playerId),
          diceNumber: diceNumber);
    }
  }
}
