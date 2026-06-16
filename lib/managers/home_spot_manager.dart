import 'package:ludo/components/home/home_spot.dart';

class HomeSpotManager {
  static final HomeSpotManager _instance = HomeSpotManager._internal();
  final Map<String, HomeSpot> _homeSpotMap = {};

  HomeSpotManager._internal();

  factory HomeSpotManager() {
    return _instance;
  }

  void addHomeSpot(HomeSpot spot) {
    _homeSpotMap[spot.uniqueId] = spot;
  }

  HomeSpot? getHomeSpotById(String uniqueId) {
    return _homeSpotMap[uniqueId];
  }

  void clearHomeSpots() {
    _homeSpotMap.clear();
  }
}
