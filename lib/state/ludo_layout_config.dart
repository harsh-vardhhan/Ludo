import 'package:flame/components.dart';

class LudoLayoutConfig {
  final double screenWidth;
  final double screenHeight;

  late final double boardWidth;
  late final double boardHeight;
  late final Vector2 boardPosition;

  late final double upperControllerWidth;
  late final double upperControllerHeight;
  late final Vector2 upperControllerPosition;

  late final double lowerControllerWidth;
  late final double lowerControllerHeight;
  late final Vector2 lowerControllerPosition;

  late final double longDimension;
  late final double shortDimension;

  LudoLayoutConfig({
    required this.screenWidth,
    required this.screenHeight,
  }) {
    boardWidth = screenWidth;
    boardHeight = screenWidth;
    boardPosition = Vector2(0, screenHeight * 0.175);

    upperControllerWidth = screenWidth;
    upperControllerHeight = screenWidth * 0.20;
    upperControllerPosition = Vector2(0, screenWidth * 0.05);

    lowerControllerWidth = screenWidth;
    lowerControllerHeight = screenWidth * 0.20;
    lowerControllerPosition = Vector2(0, screenWidth + (screenWidth * 0.35));

    longDimension = boardWidth * 0.398;
    shortDimension = boardWidth * 0.199;
  }
}
