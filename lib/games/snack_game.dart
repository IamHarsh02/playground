import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { up, down, left, right }

enum SnakeGameState { playing, gameOver }

class SnakeGame extends FlameGame
    with HasKeyboardHandlerComponents, TapCallbacks {
  final VoidCallback? onQuit;
  SnakeGame({this.onQuit});
  static const int gridSize = 20;
  late int gridWidth;
  late int gridHeight;

  List<Vector2> snake = [];
  Direction direction = Direction.right;
  Direction? nextDirection;
  Vector2 food = Vector2.zero();

  SnakeGameState gameState = SnakeGameState.playing;
  int score = 0;
  int highScore = 0;

  double moveTimer = 0;
  final double moveInterval = 0.2; // Snake moves every 0.2 seconds

  // UI Components
  late TextComponent scoreText;
  late RectangleComponent gameOverOverlay;
  late TextComponent gameOverText;
  late TextComponent finalScoreText;
  late TextComponent highScoreText;
  late RectangleComponent playAgainButton;
  late RectangleComponent quitButton;
  late TextComponent playAgainText;
  late TextComponent quitText;

  bool _isOnSnake(Vector2 position) {
    for (final segment in snake) {
      if (segment.x == position.x && segment.y == position.y) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    gridWidth = (size.x / gridSize).floor();
    gridHeight = (size.y / gridSize).floor();

    _initializeUI();
    _initializeGame();
  }

  void _initializeUI() {
    // Score display
    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

    // Game over overlay (initially hidden)
    gameOverOverlay = RectangleComponent(
      size: Vector2(400, 300),
      position: Vector2(size.x / 2 - 200, size.y / 2 - 150),
      paint: Paint()..color = Colors.black.withOpacity(0.8),
    );

    gameOverText = TextComponent(
      text: 'GAME OVER',
      position: Vector2(size.x / 2, size.y / 2 - 100),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    finalScoreText = TextComponent(
      text: 'Your Score: $score',
      position: Vector2(size.x / 2, size.y / 2 - 40),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );

    highScoreText = TextComponent(
      text: 'High Score: $highScore',
      position: Vector2(size.x / 2, size.y / 2 - 10),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.yellow, fontSize: 24),
      ),
    );

    // Play Again button
    playAgainButton = RectangleComponent(
      size: Vector2(120, 40),
      position: Vector2(size.x / 2 - 70, size.y / 2 + 30),
      paint: Paint()..color = Colors.green,
    );

    playAgainText = TextComponent(
      text: 'PLAY AGAIN',
      position: Vector2(size.x / 2, size.y / 2 + 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Quit button
    quitButton = RectangleComponent(
      size: Vector2(120, 40),
      position: Vector2(size.x / 2 + 10, size.y / 2 + 30),
      paint: Paint()..color = Colors.red,
    );

    quitText = TextComponent(
      text: 'QUIT',
      position: Vector2(size.x / 2 + 70, size.y / 2 + 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _initializeGame() {
    // Initialize snake in the middle of the screen
    snake.clear();
    final int startX = gridWidth ~/ 2;
    final int startY = gridHeight ~/ 2;
    snake.add(Vector2(startX.toDouble(), startY.toDouble()));
    snake.add(Vector2((startX - 1).toDouble(), startY.toDouble()));
    snake.add(Vector2((startX - 2).toDouble(), startY.toDouble()));

    direction = Direction.right;
    nextDirection = null;
    score = 0;
    gameState = SnakeGameState.playing;

    _generateFood();
    _updateUI();
  }

  void _generateFood() {
    final random = Random();
    do {
      food = Vector2(
        random.nextInt(gridWidth).toDouble(),
        random.nextInt(gridHeight).toDouble(),
      );
    } while (_isOnSnake(food));
  }

  void _updateUI() {
    scoreText.text = 'Score: $score';
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState != SnakeGameState.playing) return;

    moveTimer += dt;
    if (moveTimer >= moveInterval) {
      moveTimer = 0;
      _moveSnake();
    }
  }

  void _moveSnake() {
    if (nextDirection != null) {
      direction = nextDirection!;
      nextDirection = null;
    }

    Vector2 head = snake.first.clone();

    switch (direction) {
      case Direction.up:
        head.y -= 1;
        break;
      case Direction.down:
        head.y += 1;
        break;
      case Direction.left:
        head.x -= 1;
        break;
      case Direction.right:
        head.x += 1;
        break;
    }

    // Check wall collision
    if (head.x < 0 ||
        head.x >= gridWidth ||
        head.y < 0 ||
        head.y >= gridHeight) {
      _gameOver();
      return;
    }

    // Check self collision
    for (final segment in snake) {
      if (segment.x == head.x && segment.y == head.y) {
        _gameOver();
        return;
      }
    }

    snake.insert(0, head);

    // Check food collision
    if (head.x == food.x && head.y == food.y) {
      score++;
      _updateUI();
      _generateFood();
    } else {
      snake.removeLast();
    }
  }

  void _gameOver() {
    gameState = SnakeGameState.gameOver;

    // Update high score
    if (score > highScore) {
      highScore = score;
    }

    // Update game over text
    finalScoreText.text = 'Your Score: $score';
    highScoreText.text = 'High Score: $highScore';

    // Show game over overlay
    add(gameOverOverlay);
    add(gameOverText);
    add(finalScoreText);
    add(highScoreText);
    add(playAgainButton);
    add(playAgainText);
    add(quitButton);
    add(quitText);
  }

  void _hideGameOverScreen() {
    gameOverOverlay.removeFromParent();
    gameOverText.removeFromParent();
    finalScoreText.removeFromParent();
    highScoreText.removeFromParent();
    playAgainButton.removeFromParent();
    playAgainText.removeFromParent();
    quitButton.removeFromParent();
    quitText.removeFromParent();
  }

  void playAgain() {
    _hideGameOverScreen();
    _initializeGame();
  }

  void quitGame() {
    // This will be handled by the game screen to navigate back
    onQuit?.call();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (gameState == SnakeGameState.playing) {
      _drawGame(canvas);
    }
  }

  void _drawGame(Canvas canvas) {
    // Draw snake
    final snakePaint = Paint()..color = Colors.green;
    for (final segment in snake) {
      canvas.drawRect(
        Rect.fromLTWH(
          segment.x * gridSize,
          segment.y * gridSize,
          gridSize.toDouble(),
          gridSize.toDouble(),
        ),
        snakePaint,
      );
    }

    // Draw food
    final foodPaint = Paint()..color = Colors.red;
    canvas.drawRect(
      Rect.fromLTWH(
        food.x * gridSize,
        food.y * gridSize,
        gridSize.toDouble(),
        gridSize.toDouble(),
      ),
      foodPaint,
    );
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    if (gameState != SnakeGameState.playing) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      Direction? newDirection;

      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) &&
          direction != Direction.down) {
        newDirection = Direction.up;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown) &&
          direction != Direction.up) {
        newDirection = Direction.down;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
          direction != Direction.right) {
        newDirection = Direction.left;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) &&
          direction != Direction.left) {
        newDirection = Direction.right;
      }

      if (newDirection != null) {
        nextDirection = newDirection;
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameState == SnakeGameState.gameOver) {
      final tapPosition = event.localPosition;

      // Check if play again button was tapped
      if (tapPosition.x >= playAgainButton.position.x &&
          tapPosition.x <=
              playAgainButton.position.x + playAgainButton.size.x &&
          tapPosition.y >= playAgainButton.position.y &&
          tapPosition.y <=
              playAgainButton.position.y + playAgainButton.size.y) {
        playAgain();
        event.handled = true;
        return;
      }

      // Check if quit button was tapped
      if (tapPosition.x >= quitButton.position.x &&
          tapPosition.x <= quitButton.position.x + quitButton.size.x &&
          tapPosition.y >= quitButton.position.y &&
          tapPosition.y <= quitButton.position.y + quitButton.size.y) {
        quitGame();
        event.handled = true;
        return;
      }
    }
    // ignore taps during gameplay for now
  }
}
