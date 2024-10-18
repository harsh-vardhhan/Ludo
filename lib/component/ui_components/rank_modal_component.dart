import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../state/player.dart';
import '../../main.dart';

class RankModalComponent extends PositionComponent with TapCallbacks {
  final List<Player> players;
  final BuildContext context;

  RankModalComponent({
    required this.players,
    required this.context,
    super.position,
    super.size,
  }) : super();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Add the background rectangle
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xff002fa7), // Background color
        position: Vector2.zero(),
      ),
    );

    // Center the text content
    _createPlayerList();

    // Add a button at the bottom
    _addCloseButton();
  }

  void _createPlayerList() {
    final sortedPlayers = players..sort((a, b) => a.rank.compareTo(b.rank));
    double yOffset = 20.0; // Start some padding from the top

    for (var entry in sortedPlayers.asMap().entries) {
      final index = entry.key; // Get the index
      final player = entry.value; // Get the player

      // Calculate the width of the rectangle as 80% of the parent's width
      final rectangleWidth = size.x * 0.8;
      const rectangleHeight = 40.0; // Set a fixed height for the rectangle

      final backgroundColor =
          index == 0 ? const Color(0xff08C2FF) : const Color(0xff006BFF);

      // Create the rectangle component
      var playerRectangle = RectangleComponent(
        size: Vector2(rectangleWidth, rectangleHeight),
        paint: Paint()..color = backgroundColor,
        position: Vector2(
            (size.x - rectangleWidth) / 2, yOffset), // Center horizontally
      );

      // Create the text components for the rank and suffix
      final rankText = TextComponent(
        text: '${player.rank}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      final suffixText = TextComponent(
        text: getOrdinalSuffix(player.rank),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 12, // Smaller font size for the suffix
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      // Position the rank and suffix text components
      rankText.position = Vector2(
        (rectangleWidth - rankText.width - suffixText.width) * 0.10,
        (rectangleHeight - rankText.height) / 2,
      );

      suffixText.position = Vector2(
        rankText.position.x + rankText.width,
        (rectangleHeight - suffixText.height) / 2,
      );

      // Add the text components to the rectangle
      playerRectangle.add(rankText);
      playerRectangle.add(suffixText);

      // Add the player ID text component
      final playerIdText = TextComponent(
        text: ' ${player.playerId}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      playerIdText.position = Vector2(
        suffixText.position.x + suffixText.width,
        (rectangleHeight - playerIdText.height) / 2,
      );

      playerRectangle.add(playerIdText);

      // Add the rectangle to the parent
      add(playerRectangle);

      yOffset += rectangleHeight + 10; // Space between player entries
    }
  }

  String getOrdinalSuffix(int number) {
    if (number == 1) {
      return 'st';
    } else if (number == 2) {
      return 'nd';
    } else if (number == 3) {
      return 'rd';
    } else {
      return 'th';
    }
  }

  void _addCloseButton() {
    // Calculate button size and position
    final buttonWidth = size.x * 0.9;
    const buttonHeight = 50.0;
    final buttonX = (size.x - buttonWidth) / 2;
    final buttonY = size.y - buttonHeight - 20; // 20 pixels from the bottom

    // Create the button as a PositionComponent
    final button = PositionComponent(
      size: Vector2(buttonWidth, buttonHeight),
      position: Vector2(buttonX, buttonY),
    );

    // Set the background color of the button
    button.add(
      RectangleComponent(
        size: Vector2(buttonWidth, buttonHeight),
        paint: Paint()..color = Colors.yellow, // Button color
      ),
    );

    // Add the text to the button
    final buttonText = TextComponent(
      text: 'Go to lobby',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Set the position of the buttonText after its declaration
    buttonText.position = Vector2(
      buttonWidth / 2 - buttonText.width / 2,
      buttonHeight / 2 - buttonText.height / 2,
    ); // Center the text in the button

    // Add the button and text components
    button.add(buttonText);
    add(button);
  }

  @override
  void onTapDown(TapDownEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen()),
    );
  }

  void closeModal() {
    removeFromParent();
  }
}