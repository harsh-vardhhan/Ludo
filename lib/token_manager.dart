import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'token.dart';
import 'token_path.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();

  TokenManager._internal();

  factory TokenManager() {
    return _instance;
  }

  List<Token> allTokens = [];
  List<Token> miniTokens = [];

  void initializeTokens(Map<String, String> tokenToHomeSpotMap) {
    for (var entry in tokenToHomeSpotMap.entries) {
      final token = Token(
          tokenId: entry.key,
          positionId: entry.value,
          position: Vector2(100, 100), // Adjust position
          size: Vector2(50, 50), // Adjust size
          innerCircleColor: Colors.transparent);
      allTokens.add(token);
    }
  }

  List<Token> getAllTokens(player) {
    return allTokens
        .where((token) => token.tokenId.startsWith(player))
        .toList();
  }

  List<Token> getOpenTokens(player) {
    return allTokens
        .where((token) =>
            token.tokenId.startsWith(player) && token.positionId.length == 3)
        .toList();
  }

  List<Token> getCloseTokens(player) {
    return allTokens
        .where((token) =>
            token.tokenId.startsWith(player) && token.positionId.length == 2)
        .toList();
  }

  List<String> getTokenPath(player) {
    if (player == 'B') {
      return blueTokenPath;
    } else if (player == 'G') {
      return greenTokenPath;
    } else {
      return [];
    }
  }

  // Get all tokens whose uniqueId starts with 'B'
  List<Token> getBlueTokens() {
    return allTokens.where((token) => token.tokenId.startsWith('B')).toList();
  }

  // Get all tokens whose uniqueId starts with 'B'
  List<Token> getGreenTokens() {
    return allTokens.where((token) => token.tokenId.startsWith('G')).toList();
  }
}
