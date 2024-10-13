import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../ludo.dart';

// user files
import 'controller_block.dart';

class LowerController extends RectangleComponent with HasGameReference<Ludo> {
  LowerController({
    required double width,
    required double height,
    Vector2? position, // Add position parameter
  }) : super(
          size: Vector2(width, height),
          paint: Paint()..color = Colors.transparent, // Adjust color as needed
        ) {
    final double innerWidth = width * 0.45; // Width of the inner rectangles
    final double innerHeight = height; // Same height as the outer rectangle

    final leftToken = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
        position: Vector2(2.2, innerWidth * 0.05), // Sticks to the left
        paint: Paint()..color = Color(0xFFA0DEFF),
        children: [
          ControllerBlock(
              transparentRight: true,
              transparentLeft: false,
              size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
              position: Vector2(0, 0),
              paint: Paint()
                ..color = Colors.black
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0
                ..color = Color(0xFF03346E),
              children: []),
        ]);

    final leftDice = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight),
        position: Vector2(innerWidth * 0.4, 0), // Sticks to the left
        paint: Paint()..color = Color(0xFFA0DEFF),
        children: [
          RectangleComponent(
              size: Vector2(innerWidth * 0.4, innerHeight),
              paint: Paint()
                ..color = Colors.transparent
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4.0
                ..color = Color(0xFF03346E),
              children: [
                RectangleComponent(
                    position: Vector2(innerWidth * 0.20, innerHeight * 0.5)),
              ]),
        ] // Adjust color as needed
        );

    final rightDice = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight),
        position: Vector2(width - innerWidth * 0.8, 0), // Sticks to the right
        paint: Paint()..color = Color(0xFFFCDE70),
        children: [
          RectangleComponent(
              size: Vector2(innerWidth * 0.4, innerHeight),
              paint: Paint()
                ..color = Colors.transparent
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4.0
                ..color = Color(0xFF03346E),
              children: [
                RectangleComponent(
                    position: Vector2(innerWidth * 0.20, innerHeight * 0.5)),
              ])
        ]);

    final rightToken = RectangleComponent(
        size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
        position: Vector2(width - innerWidth * 0.4 - 2.5, innerWidth * 0.05),
        paint: Paint()..color = Color(0xFFFCDE70),
        children: [
          ControllerBlock(
              transparentLeft: true,
              size: Vector2(innerWidth * 0.4, innerHeight * 0.8),
              position: Vector2(0, 0),
              paint: Paint()
                ..color = Colors.black
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0
                ..color = Color(0xFF03346E),
              children: []),
        ]);

    addAll([leftDice, leftToken, rightDice, rightToken]);

    // Set the position of the UpperController
    this.position = position ??
        Vector2.zero(); // Default to (0, 0) if no position is provided
  }
}
