import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'player.dart';
import 'event_bus.dart';

class GameState {
  // Private constructor
  GameState._();

  // Singleton instance
  static final GameState _instance = GameState._();

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
      case 'GP':
        EventBus().emit(BlinkGreenBaseEvent());
        break;
      case 'BP':
        EventBus().emit(BlinkBlueBaseEvent());
        break;
      case 'RP':
        EventBus().emit(BlinkRedBaseEvent());
        break;
      case 'YP':
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

  final Map<String, List<String>> tokenPaths = {
    'BP': blueTokenPath,
    'GP': greenTokenPath,
    'RP': redTokenPath,
    'YP': yellowTokenPath,
  };

  List<String> getTokenPath(String playerId) {
    return tokenPaths[playerId] ?? [];
  }
}
