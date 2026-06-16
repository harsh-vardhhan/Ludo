import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ludo/managers/game_state.dart';
import 'package:ludo/managers/tile_manager.dart';

class Spot extends RectangleComponent {
  final String uniqueId;
  late final Vector2 tokenPosition;

  static final Spot defaultSpot = Spot(
    uniqueId: 'default',
    position: Vector2.zero(),
    size: Vector2(10, 10),
    paint: Paint()..color = Colors.grey,
  );

  static Spot findSpotById(String spotId) {
    final tile = TileManager().getTile(spotId);
    if (tile is Spot) return tile;
    return defaultSpot;
  }

  static List<Spot> getSpots() {
    return TileManager().getAllTiles().whereType<Spot>().toList();
  }

  Spot({
    required this.uniqueId,
    required Vector2 position,
    required Vector2 size,
    required Paint paint,
    List<Component>? children,
  }) : super(
          position: position,
          size: size,
          paint: paint,
          children: children ?? [],
        ) {
    TileManager().registerTile(uniqueId, this);
  }

  @override
  void onLoad() {
    super.onLoad();
    final tokenWidth = size.x * 0.80;
    final tokenSizeAdjustmentX = tokenWidth * 0.10;
    final tokenSizeAdjustmentY = tokenWidth * 0.15;
    final spotGlobalPosition = absolutePositionOf(Vector2.zero());
    final ludoBoardGlobalPosition = GameState().ludoBoardAbsolutePosition;
    tokenPosition = Vector2(
        spotGlobalPosition.x + tokenSizeAdjustmentX - ludoBoardGlobalPosition.x,
        spotGlobalPosition.y - tokenSizeAdjustmentY - ludoBoardGlobalPosition.y);
  }
}
