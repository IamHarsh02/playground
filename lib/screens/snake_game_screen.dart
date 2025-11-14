import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../games/snack_game.dart';

class SnakeGameScreen extends StatelessWidget {
  const SnakeGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Snake Game', style: TextStyle(color: Colors.white)),
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
            child: GameWidget<SnakeGame>.controlled(
              gameFactory:
                  () => SnakeGame(onQuit: () => Navigator.of(context).pop()),
            ),
          ),
        ),
      ),
    );
  }
}
