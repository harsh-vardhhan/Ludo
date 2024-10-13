library;

import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
// user files

import 'ludo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(),
    );
  }
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key, this.selectedPlayerCount});
  final int? selectedPlayerCount;

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  int? selectedPlayerCount;

  @override
  void initState() {
    super.initState();
    selectedPlayerCount = widget.selectedPlayerCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Screen'),
      ),
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
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select Number of Players',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    RadioListTile<int>(
                      title: const Text('2 Players'),
                      value: 2,
                      groupValue: selectedPlayerCount,
                      onChanged: (int? value) {
                        setState(() {
                          selectedPlayerCount = value;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: const Text('4 Players'),
                      value: 4,
                      groupValue: selectedPlayerCount,
                      onChanged: (int? value) {
                        setState(() {
                          selectedPlayerCount = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      if (selectedPlayerCount != null) {
                        if (selectedPlayerCount == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SecondScreen(
                                  selectedPlayerCount: selectedPlayerCount),
                            ),
                          );
                        } else if (selectedPlayerCount == 4) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GameApp(
                                  selectedTeams: ['BP', 'RP', 'GP', 'YP']),
                            ),
                          );
                        }
                      }
                    }, // Button is disabled if no selection
                    child: const Text('Start Game'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final int? selectedPlayerCount;

  SecondScreen({super.key, this.selectedPlayerCount});

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<String> selectedTeams = [];
  int? selectedOption; // New state variable to track selected radio option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Teams'),
      ),
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
          child: Builder(
            builder: (context) {
              switch (widget.selectedPlayerCount) {
                case 2:
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RadioListTile<int>(
                        title: const Row(
                          children: [
                            TokenDisplay(color: Colors.blue),
                            SizedBox(width: 4),
                            Text('Player 1'),
                            SizedBox(width: 30),
                            TokenDisplay(color: Colors.green),
                            SizedBox(width: 4),
                            Text('Player 2'),
                          ],
                        ),
                        value: 1,
                        groupValue:
                            selectedOption, // Use the new state variable
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value;
                            selectedTeams = ['BP', 'GP'];
                          });
                        },
                      ),
                      RadioListTile<int>(
                        title: const Row(
                          children: [
                            TokenDisplay(color: Colors.red),
                            SizedBox(width: 4),
                            Text('Player 1'),
                            SizedBox(width: 30),
                            TokenDisplay(color: Colors.yellow),
                            SizedBox(width: 4),
                            Text('Player 2'),
                          ],
                        ),
                        value: 2,
                        groupValue:
                            selectedOption, // Use the new state variable
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value;
                            selectedTeams = ['RP', 'YP'];
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GameApp(selectedTeams: selectedTeams),
                            ),
                          );
                        },
                        child: const Text('Start Game'),
                      )
                    ],
                  );
                case 4:
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GameApp(selectedTeams: selectedTeams),
                        ),
                      );
                    },
                    child: const Text('4 Players Selected'),
                  );
                default:
                  return const Text('Invalid Player Count');
              }
            },
          ),
        ),
      ),
    );
  }
}

class GameApp extends StatefulWidget {
  final List<String> selectedTeams;

  const GameApp({super.key, required this.selectedTeams});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  Ludo? game;

  @override
  void initState() {
    super.initState();
    game = Ludo(widget.selectedTeams);
    // You can now use widget.selectedTeams here
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                      child: GameWidget(game: game!)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TokenDisplay extends StatelessWidget {
  final Color color;

  const TokenDisplay({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 30), // Adjust size as needed
      painter: TokenPainter(
        fillPaint: Paint()..color = color,
        borderPaint: Paint()
          ..color = Colors.black
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
      ),
    );
  }
}

class TokenPainter extends CustomPainter {
  final Paint fillPaint;
  final Paint borderPaint;

  TokenPainter({
    required this.fillPaint,
    required this.borderPaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outerRadius = size.width / 2;
    final smallerCircleRadius = outerRadius / 1.7;
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, outerRadius, Paint()..color = Colors.white);
    canvas.drawCircle(center, outerRadius, borderPaint);
    canvas.drawCircle(center, smallerCircleRadius, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlayArea extends RectangleComponent with HasGameReference<Ludo> {
  PlayArea() : super(children: [RectangleHitbox()]);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);
  }
}
