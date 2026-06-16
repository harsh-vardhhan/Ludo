import 'package:flame/components.dart';

class TileManager {
  static final TileManager _instance = TileManager._internal();
  final Map<String, PositionComponent> _tileMap = {};

  TileManager._internal();

  factory TileManager() {
    return _instance;
  }

  void registerTile(String id, PositionComponent component) {
    _tileMap[id] = component;
  }

  void unregisterTile(String id) {
    _tileMap.remove(id);
  }

  PositionComponent? getTile(String id) {
    return _tileMap[id];
  }

  List<PositionComponent> getAllTiles() {
    return _tileMap.values.toList();
  }

  void clear() {
    _tileMap.clear();
  }
}
