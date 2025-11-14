import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BreakoutGame extends FlameGame with HasKeyboardHandlerComponents {
  late Ball ball;
  late Paddle paddle;
  final List<Brick> bricks = [];

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Create paddle
    paddle = Paddle()..position = Vector2(size.x / 2 - 60, size.y - 80);
    add(paddle);

    // Create ball and start the game
    ball = Ball()..position = Vector2(size.x / 2, size.y / 2);
    add(ball);

    // Start ball movement after a short delay to ensure everything is loaded
    Future.delayed(const Duration(milliseconds: 100), () {
      ball.startMoving();
    });

    // Create bricks
    createBricks();
  }

  void createBricks() {
    const brickWidth = 80.0;
    const brickHeight = 30.0;
    const bricksPerRow = 10;
    const rows = 3;

    final colors = [Colors.red, Colors.yellow, Colors.blue];

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < bricksPerRow; col++) {
        final brick = Brick(colors[row])
          ..position = Vector2(
            col * (brickWidth + 5) + 20,
            row * (brickHeight + 5) + 50,
          );
        bricks.add(brick);
        add(brick);
      }
    }
  }

  void resetBall() {
    ball.position = Vector2(size.x / 2, size.y / 2);
    ball.startMoving();
  }

  void brickDestroyed(Brick brick) {
    bricks.remove(brick);
    brick.removeFromParent();

    if (bricks.isEmpty) {
      createBricks();
      resetBall();
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    paddle.handleInput(keysPressed);
    return KeyEventResult.handled;
  }
}

class Ball extends CircleComponent {
  Vector2 velocity = Vector2.zero();
  bool isMoving = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    radius = 12;
    paint = Paint()..color = Colors.white;
  }

  void startMoving() {
    velocity = Vector2(150, -200);
    isMoving = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isMoving) return;

    // Store old position for collision checking
    final oldPosition = position.clone();

    // Move ball
    position += velocity * dt;

    final game = findParent<BreakoutGame>()!;
    final gameSize = game.size;

    // Check wall collisions
    if (position.x <= radius || position.x >= gameSize.x - radius) {
      velocity.x = -velocity.x;
      position.x = position.x.clamp(radius, gameSize.x - radius);
    }

    if (position.y <= radius) {
      velocity.y = -velocity.y;
      position.y = radius;
    }

    // Check paddle collision
    if (_checkPaddleCollision(game.paddle)) {
      _handlePaddleCollision(game.paddle);
    }

    // Check brick collisions
    for (final brick in List.from(game.bricks)) {
      if (_checkBrickCollision(brick)) {
        velocity.y = -velocity.y;
        game.brickDestroyed(brick);
        break; // Only hit one brick per frame
      }
    }

    // Reset if ball goes below screen
    if (position.y > gameSize.y + 50) {
      isMoving = false;
      game.resetBall();
    }
  }

  bool _checkPaddleCollision(Paddle paddle) {
    final ballLeft = position.x - radius;
    final ballRight = position.x + radius;
    final ballTop = position.y - radius;
    final ballBottom = position.y + radius;

    final paddleLeft = paddle.position.x;
    final paddleRight = paddle.position.x + paddle.size.x;
    final paddleTop = paddle.position.y;
    final paddleBottom = paddle.position.y + paddle.size.y;

    return ballRight > paddleLeft &&
        ballLeft < paddleRight &&
        ballBottom > paddleTop &&
        ballTop < paddleBottom &&
        velocity.y > 0; // Only check if ball is moving down
  }

  void _handlePaddleCollision(Paddle paddle) {
    // Make sure ball bounces up
    velocity.y = -velocity.y.abs();

    // Add angle based on where ball hits paddle
    final paddleCenter = paddle.position.x + paddle.size.x / 2;
    final ballCenter = position.x;
    final diff = (ballCenter - paddleCenter) / (paddle.size.x / 2);
    velocity.x = diff * 200;

    // Ensure minimum upward velocity
    if (velocity.y > -150) {
      velocity.y = -200;
    }

    // Move ball above paddle to prevent sticking
    position.y = paddle.position.y - radius - 2;
  }

  bool _checkBrickCollision(Brick brick) {
    final ballLeft = position.x - radius;
    final ballRight = position.x + radius;
    final ballTop = position.y - radius;
    final ballBottom = position.y + radius;

    final brickLeft = brick.position.x;
    final brickRight = brick.position.x + brick.size.x;
    final brickTop = brick.position.y;
    final brickBottom = brick.position.y + brick.size.y;

    return ballRight > brickLeft &&
        ballLeft < brickRight &&
        ballBottom > brickTop &&
        ballTop < brickBottom;
  }
}

class Paddle extends RectangleComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(120, 20);
    paint = Paint()..color = Colors.cyan;
  }

  void handleInput(Set<LogicalKeyboardKey> keysPressed) {
    const moveDistance = 10.0;
    final gameSize = (findParent<BreakoutGame>())!.size;

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      position.x = (position.x - moveDistance).clamp(0, gameSize.x - size.x);
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      position.x = (position.x + moveDistance).clamp(0, gameSize.x - size.x);
    }
  }
}

class Brick extends RectangleComponent {
  final Color brickColor;

  Brick(this.brickColor);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(80, 30);
    paint = Paint()..color = brickColor;
  }
}
