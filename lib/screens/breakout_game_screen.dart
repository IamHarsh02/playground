import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../games/breakout_game.dart';

class BreakoutGameScreen extends StatelessWidget {
  const BreakoutGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Breakout Game',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            onPressed: () {
              // Pause game functionality can be added here
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9, // Game aspect ratio
            child: GameWidget<BreakoutGame>.controlled(
              gameFactory: BreakoutGame.new,
            ),
          ),
        ),
      ),
    );
  }
}
