import 'package:ludo/components/board/spot.dart';
import 'package:ludo/components/home/home_spot.dart';

class TileManager {
  static final TileManager _instance = TileManager._internal();
  final Map<String, Spot> _spotMap = {};
  final Map<String, HomeSpot> _homeSpotMap = {};

  TileManager._internal();

  factory TileManager() {
    return _instance;
  }

  void registerSpot(String id, Spot spot) {
    _spotMap[id] = spot;
  }

  void registerHomeSpot(String id, HomeSpot homeSpot) {
    _homeSpotMap[id] = homeSpot;
  }

  Spot? getSpot(String id) {
    return _spotMap[id];
  }

  HomeSpot? getHomeSpot(String id) {
    return _homeSpotMap[id];
  }

  List<Spot> getSpots() {
    return _spotMap.values.toList();
  }

  void clear() {
    _spotMap.clear();
  }
}
