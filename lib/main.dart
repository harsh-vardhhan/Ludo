library;

import 'dart:async';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:ludo/ludo.dart';
import 'package:ludo/models/player_team.dart';

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

// ----------------------------------------------------
// UI Styles & Custom Widgets
// ----------------------------------------------------

class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main dark gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A), // Deep Slate 900
                Color(0xFF1E293B), // Slate 800
                Color(0xFF0F172A),
              ],
            ),
          ),
        ),
        // Top-right soft glow blob
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.08),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        // Bottom-left soft glow blob
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withValues(alpha: 0.06),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double padding;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class ScaleOnTapButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final List<Color> gradientColors;
  final Color borderColor;

  const ScaleOnTapButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.gradientColors,
    required this.borderColor,
  });

  @override
  State<ScaleOnTapButton> createState() => _ScaleOnTapButtonState();
}

class _ScaleOnTapButtonState extends State<ScaleOnTapButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}

class PremiumLudoTitle extends StatelessWidget {
  const PremiumLudoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'LUDO ZONE',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFFFFD700), // Pure Gold
                  Color(0xFFFFA500), // Vibrant Orange
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
              Shadow(
                color: Colors.orange.withValues(alpha: 0.25),
                offset: const Offset(0, 0),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'CHOOSE BATTLE MODE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

class MatchupCard extends StatelessWidget {
  final PlayerTeam team1;
  final PlayerTeam team2;
  final VoidCallback onTap;

  const MatchupCard({
    super.key,
    required this.team1,
    required this.team2,
    required this.onTap,
  });

  Color _getTeamColor(PlayerTeam team) {
    switch (team) {
      case PlayerTeam.blue:
        return const Color(0xFF0D92F4);
      case PlayerTeam.green:
        return const Color(0xFF41B06E);
      case PlayerTeam.red:
        return const Color(0xFFFF5B5B);
      case PlayerTeam.yellow:
        return const Color(0xFFFFD966);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color1 = _getTeamColor(team1);
    final color2 = _getTeamColor(team2);

    return ScaleOnTapButton(
      gradientColors: [
        Colors.white.withValues(alpha: 0.08),
        Colors.white.withValues(alpha: 0.03),
      ],
      borderColor: Colors.white.withValues(alpha: 0.12),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TokenDisplay(color: color1),
              const SizedBox(width: 14),
              Text(
                team1.name.toUpperCase(),
                style: TextStyle(
                  color: color1,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          Text(
            'VS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 15,
            ),
          ),
          Row(
            children: [
              Text(
                team2.name.toUpperCase(),
                style: TextStyle(
                  color: color2,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 14),
              TokenDisplay(color: color2),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Screens
// ----------------------------------------------------

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key, this.selectedPlayerCount});
  final int? selectedPlayerCount;

  @override
  FirstScreenState createState() => FirstScreenState();
}

class FirstScreenState extends State<FirstScreen> {
  int? selectedPlayerCount;

  @override
  void initState() {
    super.initState();
    selectedPlayerCount = widget.selectedPlayerCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GlassmorphicContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PremiumLudoTitle(),
                    const SizedBox(height: 48),
                    ScaleOnTapButton(
                      gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)], // Gold to Bronze
                      borderColor: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SecondScreen(selectedPlayerCount: 2),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, color: Colors.white, size: 22),
                          SizedBox(width: 12),
                          Text(
                            '2 PLAYER GAME',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ScaleOnTapButton(
                      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Blue to Deep Blue
                      borderColor: const Color(0xFF60A5FA).withValues(alpha: 0.5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameApp(
                              selectedTeams: [
                                PlayerTeam.blue,
                                PlayerTeam.red,
                                PlayerTeam.green,
                                PlayerTeam.yellow
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.groups, color: Colors.white, size: 22),
                          SizedBox(width: 12),
                          Text(
                            '4 PLAYER GAME',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final int? selectedPlayerCount;

  const SecondScreen({super.key, this.selectedPlayerCount});

  @override
  SecondScreenState createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GlassmorphicContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'SELECT TEAMS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 34), // Spacing alignment matching back button
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Choose a 2-Player Matchup',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    MatchupCard(
                      team1: PlayerTeam.blue,
                      team2: PlayerTeam.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameApp(
                              selectedTeams: [PlayerTeam.blue, PlayerTeam.green],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    MatchupCard(
                      team1: PlayerTeam.red,
                      team2: PlayerTeam.yellow,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameApp(
                              selectedTeams: [PlayerTeam.red, PlayerTeam.yellow],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameApp extends StatefulWidget {
  final List<PlayerTeam> selectedTeams;

  const GameApp({super.key, required this.selectedTeams});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  Ludo? game;

  @override
  void initState() {
    super.initState();
    game = Ludo(widget.selectedTeams, context); // Initialize game instance
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic) {
        _showExitConfirmationDialog();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Dark slate matching AmbientBackground
                  Color(0xFF1E293B),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Premium Game Header with back/exit button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showExitConfirmationDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                          ).createShader(bounds),
                          child: const Text(
                            'LUDO ZONE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Balanced layout spacing
                        const SizedBox(width: 34),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: FittedBox(
                          child: SizedBox(
                              width: screenWidth,
                              height: screenWidth + screenWidth * 0.70,
                              child: GameWidget(game: game!)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          title: const Text(
            'Exit Game',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          content: const Text(
            'Do you really want to exit the game?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444), // Red
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Yes, Exit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TokenDisplay extends StatelessWidget {
  final Color color;

  const TokenDisplay({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28), // Adjust size as needed
      painter: TokenPainter(
        fillPaint: Paint()..color = color,
        borderPaint: Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.2
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
    final smallerCircleRadius = outerRadius / 1.6;
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
