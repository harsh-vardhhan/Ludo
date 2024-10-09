import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../component/ui_components/token.dart';
import 'token_path.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();

  TokenManager._internal();

  factory TokenManager() {
    return _instance;
  }

  List<Token> allTokens = [];
  List<Token> miniTokens = [];

  // Cache for player-specific tokens
  final Map<String, List<Token>> _playerTokensCache = {};

  void initializeTokens(Map<String, String> tokenToHomeSpotMap) {
    for (var entry in tokenToHomeSpotMap.entries) {
      final token = Token(
          playerId: 'ID',
          enableToken: false,
          tokenId: entry.key,
          positionId: entry.value,
          position: Vector2(100, 100), // Adjust position
          size: Vector2(50, 50), // Adjust size
          innerCircleColor: Colors.transparent);
      allTokens.add(token);
    }
    _cachePlayerTokens();
  }

  void _cachePlayerTokens() {
    _playerTokensCache.clear();
    for (var token in allTokens) {
      final player = token.tokenId[0];
      _playerTokensCache.putIfAbsent(player, () => []).add(token);
    }
  }

  List<Token> getAllTokens(String player) {
    return _playerTokensCache[player] ?? [];
  }

  List<Token> getOpenTokens(String player) {
    return getAllTokens(player)
        .where((token) => token.positionId.length == 3)
        .toList();
  }

  List<Token> getCloseTokens(String player) {
    return getAllTokens(player)
        .where((token) => token.positionId.length == 2)
        .toList();
  }

  List<String> getTokenPath(String player) {
    if (player == 'B') {
      return blueTokenPath;
    } else if (player == 'G') {
      return greenTokenPath;
    } else {
      return [];
    }
  }

  List<Token> getBlueTokens() {
    return getAllTokens('B');
  }

  List<Token> getGreenTokens() {
    return getAllTokens('G');
  }
}
