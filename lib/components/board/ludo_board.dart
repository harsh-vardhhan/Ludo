import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ludo/managers/game_state.dart';
import 'package:ludo/components/board/ludo_grid_component.dart';
import 'package:ludo/models/player_team.dart';
import 'package:ludo/components/home/home.dart';
import 'package:ludo/components/board/spot.dart';

class LudoBoard extends PositionComponent {
  LudoBoard() {
    final layout = GameState().layoutConfig;
    final double longDimension = layout.longDimension;
    final double shortDimension = layout.shortDimension;

    size = Vector2(layout.boardWidth, layout.boardHeight);
    position = layout.boardPosition;

    final firstComponent = RectangleComponent(
        size: Vector2(longDimension, longDimension),
        position: Vector2.zero(),
        children: [
          Home(
            size: longDimension,
            paint: Paint()..color = GameState().red,
            homeSpotColor: Paint()..color = GameState().red,
            teamCode: 'R',
          )
        ]);

    final secondComponent = RectangleComponent(
        size: Vector2(shortDimension, longDimension),
        position: Vector2(longDimension, 0),
        children: [
          LudoGridComponent(
              team: PlayerTeam.green, cellSize: shortDimension * 0.3333)
        ]);

    final thirdComponent = RectangleComponent(
        size: Vector2(longDimension, longDimension),
        position: Vector2(longDimension + shortDimension, 0),
        children: [
          Home(
            size: longDimension,
            paint: Paint()..color = GameState().green,
            homeSpotColor: Paint()..color = GameState().green,
            teamCode: 'G',
          )
        ]);

    final fourthComponent = RectangleComponent(
        size: Vector2(longDimension, shortDimension),
        position: Vector2(0, longDimension),
        children: [
          LudoGridComponent(
              team: PlayerTeam.red, cellSize: longDimension * 0.1666)
        ]);

    final fifthComponent = RectangleComponent(
        size: Vector2(shortDimension, shortDimension),
        position: Vector2(longDimension, longDimension),
        children: [
          DiagonalRectangleComponent(size: Vector2.all(shortDimension))
        ]);

    final sixthComponent = RectangleComponent(
        size: Vector2(longDimension, shortDimension),
        position: Vector2(longDimension + shortDimension, longDimension),
        children: [
          LudoGridComponent(
              team: PlayerTeam.yellow, cellSize: longDimension * 0.1666)
        ]);

    final seventhComponent = RectangleComponent(
        size: Vector2(longDimension, longDimension),
        position: Vector2(0, longDimension + shortDimension),
        children: [
          Home(
            size: longDimension,
            paint: Paint()..color = GameState().blue,
            homeSpotColor: Paint()..color = GameState().blue,
            teamCode: 'B',
          )
        ]);

    final eighthComponent = RectangleComponent(
        size: Vector2(shortDimension, longDimension),
        position: Vector2(longDimension, longDimension + shortDimension),
        children: [
          LudoGridComponent(
              team: PlayerTeam.blue, cellSize: shortDimension * 0.3333)
        ]);

    final ninthComponent = RectangleComponent(
        size: Vector2(longDimension, longDimension),
        position: Vector2(longDimension + shortDimension,
            longDimension + shortDimension),
        children: [
          Home(
            size: longDimension,
            paint: Paint()..color = GameState().yellow,
            homeSpotColor: Paint()..color = GameState().yellow,
            teamCode: 'Y',
          )
        ]);

    addAll([
      firstComponent,
      secondComponent,
      thirdComponent,
      fourthComponent,
      fifthComponent,
      sixthComponent,
      seventhComponent,
      eighthComponent,
      ninthComponent
    ]);
  }
}

class DiagonalRectangleComponent extends PositionComponent {
  late final Vector2 centerRedTriangle;
  late final Vector2 centerYellowTriangle;
  late final Vector2 centerBlueTriangle;
  late final Vector2 centerGreenTriangle;

  late final Spot redSpot;
  late final Spot yellowSpot;
  late final Spot blueSpot;
  late final Spot greenSpot;

  DiagonalRectangleComponent({required Vector2 size}) {
    this.size = size;

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final topLeft = rect.topLeft;
    final topRight = rect.topRight;
    final bottomLeft = rect.bottomLeft;
    final bottomRight = rect.bottomRight;
    final center = Offset(
        (topLeft.dx + bottomRight.dx) / 2, (topLeft.dy + bottomRight.dy) / 2);

    centerRedTriangle = Vector2((topLeft.dx + center.dx + bottomLeft.dx) / 3,
        (topLeft.dy + center.dy + bottomLeft.dy) / 3);
    centerYellowTriangle = Vector2(
        (bottomRight.dx + center.dx + topRight.dx) / 3,
        (bottomRight.dy + center.dy + topRight.dy) / 3);
    centerBlueTriangle = Vector2(
        (bottomLeft.dx + center.dx + bottomRight.dx) / 3,
        (bottomLeft.dy + center.dy + bottomRight.dy) / 3);
    centerGreenTriangle = Vector2((topRight.dx + center.dx + topLeft.dx) / 3,
        (topRight.dy + center.dy + topLeft.dy) / 3);
  }

  @override
  void onLoad() {
    super.onLoad();

    double rectWidth = size.x / 6;
    double rectHeight = size.y / 6;

    redSpot = Spot(
      uniqueId: 'RF',
      position: centerRedTriangle - Vector2(rectWidth / 2, rectHeight / 2),
      size: Vector2(rectWidth, rectHeight),
      paint: Paint()..color = GameState().red,
    );
    yellowSpot = Spot(
      uniqueId: 'YF',
      position: centerYellowTriangle - Vector2(rectWidth / 2, rectHeight / 2),
      size: Vector2(rectWidth, rectHeight),
      paint: Paint()..color = GameState().yellow,
    );
    blueSpot = Spot(
      uniqueId: 'BF',
      position: centerBlueTriangle - Vector2(rectWidth / 2, rectHeight / 2),
      size: Vector2(rectWidth, rectHeight),
      paint: Paint()..color = GameState().blue,
    );
    greenSpot = Spot(
      uniqueId: 'GF',
      position: centerGreenTriangle - Vector2(rectWidth / 2, rectHeight / 2),
      size: Vector2(rectWidth, rectHeight),
      paint: Paint()..color = GameState().green,
    );

    addAll([redSpot, yellowSpot, blueSpot, greenSpot]);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final topLeft = rect.topLeft;
    final topRight = rect.topRight;
    final bottomLeft = rect.bottomLeft;
    final bottomRight = rect.bottomRight;
    final center = Offset(
        (topLeft.dx + bottomRight.dx) / 2, (topLeft.dy + bottomRight.dy) / 2);

    Paint yellowPaint = Paint()..color = GameState().yellow;
    Paint redPaint = Paint()..color = GameState().red;
    Paint bluePaint = Paint()..color = GameState().blue;
    Paint greenPaint = Paint()..color = GameState().green;

    Paint borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    _drawTriangle(canvas, redPaint, borderPaint, topLeft, center, bottomLeft);
    _drawTriangle(
        canvas, yellowPaint, borderPaint, bottomRight, center, topRight);
    _drawTriangle(
        canvas, bluePaint, borderPaint, bottomLeft, center, bottomRight);
    _drawTriangle(canvas, greenPaint, borderPaint, topRight, center, topLeft);
  }

  void _drawTriangle(Canvas canvas, Paint fillPaint, Paint borderPaint,
      Offset p1, Offset p2, Offset p3) {
    Path triangle = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy);
    canvas.drawPath(triangle, fillPaint);
    canvas.drawPath(triangle, borderPaint);
  }
}

final Paint transparentPaint = Paint()..color = const Color(0x00000000);
