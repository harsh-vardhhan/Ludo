import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SpotManager {
  static final SpotManager _instance = SpotManager._internal();
  final List<Spot> spots = [];

  SpotManager._internal();

  factory SpotManager() {
    return _instance;
  }

  void addSpot(Spot spot) {
    spots.add(spot);
  }

  List<Spot> getSpots() {
    return List.unmodifiable(spots);
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
  List<Spot> allSpots = SpotManager().getSpots();

  // Find the spot corresponding to the provided ID
  return allSpots.firstWhere(
    (spot) => spot.uniqueId == spotId,
    orElse: () => Spot(
      uniqueId: 'default', // Default spot if not found
      position: Vector2.zero(),
      size: Vector2(10, 10),
      paint: Paint()..color = Colors.grey, // Grey for default spot
    ),
  );
}