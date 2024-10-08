library;

import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
// user files

import 'ludo.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late Ludo game;
  int? selectedPlayerCount;

  @override
  void initState() {
    super.initState();
    // Don't initialize the game yet; wait for player selection
  }

  void startGame(int? playerCount) {
    setState(() {
      if (playerCount != null) {
        selectedPlayerCount = playerCount;
        game = Ludo(selectedPlayerCount!); // Use the non-nullable value
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // If the player count hasn't been selected, show the menu
    if (selectedPlayerCount == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff98DED9),
                  Color(0xffFFFFFF),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Number of Players',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => startGame(2),
                    child: Text('2 Players'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => startGame(3),
                    child: Text('3 Players'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => startGame(4),
                    child: Text('4 Players'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // If the player count is selected, display the game
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff98DED9),
                Color(0xffFFFFFF),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: FittedBox(
                  child: SizedBox(
                    width: screenWidth,
                    height: screenWidth + screenWidth * 0.70,
                    child: GameWidget(
                      game: game,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayArea extends RectangleComponent with HasGameReference<Ludo> {
  PlayArea() : super(children: [RectangleHitbox()]);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);
  }
}
