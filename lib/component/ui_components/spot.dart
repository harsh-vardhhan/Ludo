import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SpotManager {
  static final SpotManager _instance = SpotManager._internal();
  final Map<String, Spot> _spotMap = {};
  List<Spot>? _cachedSpots; // Cache for the spots list

  SpotManager._internal();

  factory SpotManager() {
    return _instance;
  }

  void addSpot(Spot spot) {
    _spotMap[spot.uniqueId] = spot;
    _cachedSpots = null; // Invalidate cache when a new spot is added
  }

  // Add a method to remove a spot and invalidate the cache
  void removeSpot(String spotId) {
    if (_spotMap.remove(spotId) != null) {
      _cachedSpots = null; // Invalidate cache when a spot is removed
    }
  }

  Spot? getSpotById(String spotId) {
    return _spotMap[spotId];
  }

  List<Spot> getSpots() {
    if (_cachedSpots == null) {
      // Ensure the cache is populated with a fresh list
      _cachedSpots = List.unmodifiable(_spotMap.values.toList());
    }
    return _cachedSpots!;
  }
}

class Spot extends RectangleComponent {
  final String uniqueId;

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
    SpotManager().addSpot(this);
  }
}

Spot findSpotById(String spotId) {
  SpotManager spotManager = SpotManager();
  Spot? spot = spotManager.getSpotById(spotId);

  // Return the found spot or a default spot if not found
  return spot ?? Spot(
    uniqueId: 'default', // Default spot if not found
    position: Vector2.zero(),
    size: Vector2(10, 10),
    paint: Paint()..color = Colors.grey, // Grey for default spot
  );
}