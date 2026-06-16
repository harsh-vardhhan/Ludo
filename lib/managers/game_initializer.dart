import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:ludo/models/player.dart';
import 'package:ludo/models/player_team.dart';
import 'package:ludo/models/token.dart';
import 'package:ludo/components/board/token.dart';
import 'package:ludo/components/board/spot.dart';
import 'package:ludo/managers/game_state.dart';
import 'package:ludo/managers/token_manager.dart';
import 'package:ludo/managers/tile_manager.dart';
import 'package:ludo/managers/audio_manager.dart';
import 'package:ludo/ludo.dart';

class GameInitializer {
  static Future<void> run(Ludo game, List<PlayerTeam> teams) async {
    await TokenManager().clearTokens();
    await GameState().clearPlayers();
    await AudioManager.dispose();

    AudioManager.initialize();

    final ludoBoardPosition = GameState().ludoBoardAbsolutePosition;
    const homeSpotSizeFactorX = 0.10;
    const homeSpotSizeFactorY = 0.05;
    const tokenSizeFactorX = 0.80;
    const tokenSizeFactorY = 1.05;

    for (var team in teams) {
      List<Token> tokens;
      Color topColor;
      Color sideColor;
      Map<String, String> baseTokens;

      switch (team) {
        case PlayerTeam.blue:
          baseTokens = TokenManager().blueTokensBase;
          topColor = const Color(0xFF77CDFF);
          sideColor = const Color(0xFF0D92F4);
          break;
        case PlayerTeam.green:
          baseTokens = TokenManager().greenTokensBase;
          topColor = const Color(0xFF73EC8B);
          sideColor = const Color(0xFF54C392);
          break;
        case PlayerTeam.yellow:
          baseTokens = TokenManager().yellowTokensBase;
          topColor = const Color(0xffFFDF5B);
          sideColor = const Color(0xffc9a227);
          break;
        case PlayerTeam.red:
          baseTokens = TokenManager().redTokensBase;
          topColor = const Color(0xffFF5B5B);
          sideColor = const Color(0xff780000);
          break;
      }

      // Initialize tokens for the team if not already initialized
      TokenManager().initializeTokens(baseTokens);

      switch (team) {
        case PlayerTeam.blue:
          tokens = TokenManager().getBlueTokens();
          break;
        case PlayerTeam.green:
          tokens = TokenManager().getGreenTokens();
          break;
        case PlayerTeam.yellow:
          tokens = TokenManager().getYellowTokens();
          break;
        case PlayerTeam.red:
          tokens = TokenManager().getRedTokens();
          break;
      }

      for (var token in tokens) {
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
          topColor: topColor,
          sideColor: sideColor,
        );
        GameState().registerTokenComponent(tokenComp);
        GameState().ludoBoard?.add(tokenComp);
      }

      final isFirstPlayer = GameState().players.isEmpty;
      final player = Player(
        playerId: team,
        tokens: tokens,
      );
      GameState().players.add(player);

      for (var token in tokens) {
        token.playerId = player.playerId;
        token.enableToken = isFirstPlayer;
      }
    }

    // After all players and components are registered, activate the first player's base effects and dice
    if (GameState().players.isNotEmpty) {
      final firstPlayer = GameState().players[0];
      game.blinkBaseForTeam(firstPlayer.playerId);
    }
  }
}
