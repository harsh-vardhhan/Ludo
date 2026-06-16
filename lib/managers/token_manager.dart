import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ludo/models/player_team.dart';
import 'package:ludo/models/token.dart';
import 'package:ludo/components/board/spot.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();

  TokenManager._internal();

  factory TokenManager() {
    return _instance;
  }

  List<Token> allTokens = [];
  List<Token> miniTokens = [];

  // Cache for player-specific tokens
  final Map<PlayerTeam, List<Token>> _playerTokensCache = {};

  final blueTokensBase = {
    'BT1': 'B1',
    'BT2': 'B2',
    'BT3': 'B3',
    'BT4': 'B4',
  };

  final greenTokensBase = {
    'GT1': 'G1',
    'GT2': 'G2',
    'GT3': 'G3',
    'GT4': 'G4',
  };

  final redTokensBase = {
    'RT1': 'R1',
    'RT2': 'R2',
    'RT3': 'R3',
    'RT4': 'R4',
  };

  final yellowTokensBase = {
    'YT1': 'Y1',
    'YT2': 'Y2',
    'YT3': 'Y3',
    'YT4': 'Y4',
  };

  void initializeTokens(Map<String, String> tokenToHomeSpotMap) {
    for (var entry in tokenToHomeSpotMap.entries) {
      PlayerTeam team;
      if (entry.key.startsWith('B')) {
        team = PlayerTeam.blue;
      } else if (entry.key.startsWith('G')) {
        team = PlayerTeam.green;
      } else if (entry.key.startsWith('R')) {
        team = PlayerTeam.red;
      } else {
        team = PlayerTeam.yellow;
      }

      final token = Token(
          playerId: team,
          enableToken: false,
          tokenId: entry.key,
          positionId: entry.value,
          state: TokenState.inBase);
      allTokens.add(token);
      SpotManager().addSpot(Spot(
          uniqueId: entry.value,
          position: Vector2(100, 100),
          size: Vector2(50, 50),
          paint: Paint()));
    }
    _cachePlayerTokens();
  }

  void _cachePlayerTokens() {
    _playerTokensCache.clear();
    for (var token in allTokens) {
      _playerTokensCache.putIfAbsent(token.playerId, () => []).add(token);
    }
  }

  List<Token> getAllTokens(PlayerTeam player) {
    return _playerTokensCache[player] ?? [];
  }

  List<Token> getOpenTokens(PlayerTeam player) {
    return getAllTokens(player)
        .where((token) => token.positionId.length == 3)
        .toList();
  }

  List<Token> getCloseTokens(PlayerTeam player) {
    return getAllTokens(player)
        .where((token) => token.positionId.length == 2)
        .toList();
  }

  List<Token> getBlueTokens() => getAllTokens(PlayerTeam.blue);
  List<Token> getGreenTokens() => getAllTokens(PlayerTeam.green);
  List<Token> getYellowTokens() => getAllTokens(PlayerTeam.yellow);
  List<Token> getRedTokens() => getAllTokens(PlayerTeam.red);

  Future<void> clearTokens() async {
    allTokens.clear();
    miniTokens.clear();
    _playerTokensCache.clear();
    return Future.value();
  }
}
