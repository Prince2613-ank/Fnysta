import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Game Configuration ---
const List<Color> kGameColors = [
  Color(0xFFF70088), // Magenta
  Color(0xFF00DDFF), // Cyan
  Color(0xFFFFC300), // Yellow
  Color(0xFF8B00F7), // Purple
];

// --- Gameplay Constants ---
const double kBallRadius = 15.0;
const double kSwitcherRadius = 12.0;
const double kObstacleGap = 400.0;
const double kCircleRadius = 100.0;
const double kCircleThickness = 20.0;

// --- Physics Constants ---
const double kGravity = 1700.0;
const double kJumpStrength = -650.0;

// --- Enums for Game Logic ---
enum GameStatus { playing, gameOver }

enum ObstacleType { standard, moving, doubleLayer, withGap }

enum PowerUpType { rainbow, slowMo, shrink, shield }

// Class to represent a power-up item on screen
class PowerUp {
  final PowerUpType type;
  final double y;
  bool isCollected = false;

  PowerUp({required this.type, required this.y});

  IconData get icon {
    switch (type) {
      case PowerUpType.rainbow:
        return Icons.all_inclusive;
      case PowerUpType.slowMo:
        return Icons.slow_motion_video;
      case PowerUpType.shrink:
        return Icons.compress;
      case PowerUpType.shield:
        return Icons.shield;
    }
  }

  Color get color {
    switch (type) {
      case PowerUpType.rainbow:
        return Colors.redAccent;
      case PowerUpType.slowMo:
        return Colors.blueAccent;
      case PowerUpType.shrink:
        return Colors.greenAccent;
      case PowerUpType.shield:
        return Colors.orangeAccent;
    }
  }
}

class Particle {
  Offset position;
  double radius;
  double opacity;
  double speed;
  double direction;

  Particle({
    required this.position,
    required this.radius,
    required this.opacity,
    required this.speed,
  }) : direction = Random().nextBool() ? 1 : -1;

  void update(double dt) {
    opacity += speed * direction * dt;
    if (opacity < 0.0) {
      opacity = 0.0;
      direction *= -1;
    } else if (opacity > 1.0) {
      opacity = 1.0;
      direction *= -1;
    }
  }
}

class ColorSwitchScreen extends StatefulWidget {
  const ColorSwitchScreen({Key? key}) : super(key: key);

  @override
  _ColorSwitchScreenState createState() => _ColorSwitchScreenState();
}

class _ColorSwitchScreenState extends State<ColorSwitchScreen>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  final Random _random = Random();
  DateTime? _lastUpdateTime;

  final AudioPlayer _audioPlayer = AudioPlayer();

  late double _ballY;
  late double _ballVelocityY;
  late Color _ballColor;
  late double _jumpBaseY;
  late double _currentJumpPeakY;
  late double _currentBallRadius;

  double _cameraY = 0.0;
  int _score = 0;
  int _highScore = 0;
  GameStatus _gameStatus = GameStatus.playing;
  bool _isInitialized = false;

  List<_CircleObstacle> _obstacles = [];
  List<PowerUp> _powerUps = [];

  bool _isRainbowActive = false;
  bool _isSlowMoActive = false;
  bool _hasShield = false;
  Timer? _rainbowTimer;
  Timer? _slowMoTimer;
  Timer? _shrinkTimer;

  List<Particle> _particles = [];
  late AnimationController _starfieldController;

  late AnimationController _gameOverController;
  late Animation<double> _gameOverAnimation;

  // 🎯 ADDED: State for showing the tutorial
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    // 🎯 ADDED: Check if we need to show the tutorial when the game starts
    _checkIfFirstTime();

    _ticker = createTicker((elapsed) {
      _updateGame(elapsed);
    });

    _starfieldController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            final double dt = 1 / 60.0;
            for (var p in _particles) {
              p.update(dt);
            }
          })
          ..repeat();

    _gameOverController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _gameOverAnimation =
        CurvedAnimation(parent: _gameOverController, curve: Curves.elasticOut);

    for (int i = 0; i < 100; i++) {
      _particles.add(
        Particle(
          position: Offset(_random.nextDouble(), _random.nextDouble()),
          radius: _random.nextDouble() * 2.0 + 1.0,
          opacity: _random.nextDouble(),
          speed: _random.nextDouble() * 0.2 + 0.1,
        ),
      );
    }
  }

  // 🎯 ADDED: A function to check SharedPreferences for the tutorial flag
  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // If the flag is not true, show the tutorial.
    if (prefs.getBool('hasSeenColorSwitchTutorial') != true) {
      if (mounted) {
        setState(() {
          _showTutorial = true;
        });
      }
    }
  }

  // 🎯 ADDED: A function to dismiss the tutorial and start the game
  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenColorSwitchTutorial', true);
    if (mounted) {
      setState(() {
        _showTutorial = false;
      });
      _startGame();
    }
  }

  // 🎯 ADDED: A function to start the game ticker
  void _startGame() {
    _lastUpdateTime = DateTime.now();
    if (mounted && !_ticker.isTicking) {
      _ticker.start();
    }
  }

  void _playSound(String fileName) {
    _audioPlayer.play(AssetSource('$fileName'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _restartGame();
      _isInitialized = true;
    }
  }

  void _restartGame() {
    _gameOverController.reset();
    _rainbowTimer?.cancel();
    _slowMoTimer?.cancel();
    _shrinkTimer?.cancel();

    final currentHighScore = _highScore;
    final screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      _ballY = screenHeight / 2 + 100;
      _ballVelocityY = 0.0;
      _jumpBaseY = _ballY;
      _currentJumpPeakY = _ballY;
      _cameraY = _ballY;
      _ballColor = kGameColors[_random.nextInt(kGameColors.length)];
      _score = 0;
      _highScore = currentHighScore;
      _gameStatus = GameStatus.playing;
      _obstacles.clear();
      _powerUps.clear();
      _currentBallRadius = kBallRadius;
      _isRainbowActive = false;
      _isSlowMoActive = false;
      _hasShield = false;

      _obstacles.add(_createObstacle(y: _ballY - 260));
      for (int i = 0; i < 4; i++) {
        _addObstacle();
      }
    });

    // 🎯 MODIFIED: Only start the game if the tutorial isn't showing
    if (!_showTutorial) {
      _startGame();
    }
  }

  _CircleObstacle _createObstacle({required double y}) {
    ObstacleType type = ObstacleType.standard;
    double rand = _random.nextDouble();
    if (_score > 5 && rand < 0.15) {
      type = ObstacleType.moving;
    } else if (_score > 10 && rand < 0.3) {
      type = ObstacleType.doubleLayer;
    } else if (_score > 15 && rand < 0.45) {
      type = ObstacleType.withGap;
    }

    final double speedMultiplier = (_score < 10) ? 0.2 : 0.8;
    final speed = (0.5 + _random.nextDouble() * speedMultiplier) *
        (_random.nextBool() ? 1 : -1);
    final startAngle = _random.nextDouble() * 2 * pi;

    bool hasFakeSwitcher = _random.nextDouble() < 0.2;

    return _CircleObstacle(
        y: y,
        rotateSpeed: speed,
        startAngle: startAngle,
        type: type,
        hasFakeSwitcher: hasFakeSwitcher,
        screenWidth: MediaQuery.of(context).size.width);
  }

  void _addObstacle() {
    final lastY = _obstacles.last.y;
    final newY = lastY - kObstacleGap;
    _obstacles.add(_createObstacle(y: newY));

    if (_random.nextDouble() < 0.15) {
      final powerUpType =
          PowerUpType.values[_random.nextInt(PowerUpType.values.length)];
      _powerUps.add(PowerUp(type: powerUpType, y: newY + kObstacleGap / 2));
    }
  }

  void _handleTap() {
    if (_gameStatus == GameStatus.playing) {
      _playSound('jump.mp3');
      setState(() {
        _jumpBaseY = _ballY;
        _currentJumpPeakY = _ballY;
        _ballVelocityY = kJumpStrength;
      });
    }
  }

  void _updateGame(Duration elapsed) {
    if (_gameStatus != GameStatus.playing || !_isInitialized) return;
    final now = DateTime.now();
    final double dt = _lastUpdateTime != null
        ? now.difference(_lastUpdateTime!).inMilliseconds / 1000.0
        : (1 / 60);
    _lastUpdateTime = now;
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      _ballVelocityY += kGravity * dt;
      _ballY += _ballVelocityY * dt;
      if (_ballVelocityY < 0) {
        _currentJumpPeakY = min(_currentJumpPeakY, _ballY);
      }
      if (_ballVelocityY > 0) {
        final double stopY = (_currentJumpPeakY + _jumpBaseY) / 2;
        if (_ballY > stopY) {
          _ballY = stopY;
          _ballVelocityY = 0;
        }
      }
      if (_ballY < _cameraY) {
        _cameraY = _ballY;
      }
      if (_obstacles.last.y > _ballY - screenSize.height) {
        _addObstacle();
      }
      _obstacles.removeWhere((o) => o.y > _cameraY + screenSize.height + 200);
      _powerUps.removeWhere((p) => p.y > _cameraY + screenSize.height + 200);
      _checkCollisions();
      for (var obstacle in _obstacles) {
        obstacle.update(dt, _isSlowMoActive);
      }
    });
  }

  void _checkCollisions() {
    final ballX = MediaQuery.of(context).size.width / 2;
    final ballCenter = Offset(ballX, _ballY);
    for (var obstacle in _obstacles) {
      final obstacleCenter = Offset(obstacle.x, obstacle.y);
      _handleRimCollision(obstacle, ballCenter, obstacleCenter);
      _handleStarCollection(obstacle, ballCenter, obstacleCenter);
      _handleGapBallCollection(obstacle, ballCenter, obstacleCenter);
    }
    _handlePowerUpCollection(ballCenter);
  }

  void _handlePowerUpCollection(Offset ballCenter) {
    _powerUps.removeWhere((powerUp) {
      if (powerUp.isCollected) return false;
      final powerUpCenter = Offset(ballCenter.dx, powerUp.y);
      if ((ballCenter - powerUpCenter).distance < _currentBallRadius + 20) {
        powerUp.isCollected = true;
        _activatePowerUp(powerUp.type);
        return true;
      }
      return false;
    });
  }

  void _activatePowerUp(PowerUpType type) {
    _playSound('powerup.mp3');
    switch (type) {
      case PowerUpType.rainbow:
        setState(() => _isRainbowActive = true);
        _rainbowTimer?.cancel();
        _rainbowTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) setState(() => _isRainbowActive = false);
        });
        break;
      case PowerUpType.slowMo:
        setState(() => _isSlowMoActive = true);
        _slowMoTimer?.cancel();
        _slowMoTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) setState(() => _isSlowMoActive = false);
        });
        break;
      case PowerUpType.shrink:
        setState(() => _currentBallRadius = kBallRadius * 0.6);
        _shrinkTimer?.cancel();
        _shrinkTimer = Timer(const Duration(seconds: 8), () {
          if (mounted) setState(() => _currentBallRadius = kBallRadius);
        });
        break;
      case PowerUpType.shield:
        setState(() => _hasShield = true);
        break;
    }
  }

  void _handleGapBallCollection(
      _CircleObstacle obstacle, Offset ballCenter, Offset obstacleCenter) {
    if (obstacle.gapBallCollected) return;

    final gapBallCenter =
        Offset(obstacleCenter.dx, obstacleCenter.dy + kObstacleGap / 2);

    if ((ballCenter - gapBallCenter).distance <
        _currentBallRadius + kSwitcherRadius) {
      if (obstacle.hasFakeSwitcher) {
        obstacle.triggerFakeSwitcherAnimation();
      } else {
        setState(() {
          obstacle.gapBallCollected = true;
          Color newColor;
          do {
            newColor = kGameColors[_random.nextInt(kGameColors.length)];
          } while (newColor == _ballColor && kGameColors.length > 1);
          _ballColor = newColor;
        });
      }
    }
  }

  void _handleStarCollection(
      _CircleObstacle obstacle, Offset ballCenter, Offset obstacleCenter) {
    if (obstacle.starCollected) return;
    if ((ballCenter - obstacleCenter).distance < _currentBallRadius * 2) {
      _playSound('score.mp3');
      setState(() {
        obstacle.starCollected = true;
        _score += 1;
      });
    }
  }

  void _handleRimCollision(
      _CircleObstacle obstacle, Offset ballCenter, Offset obstacleCenter) {
    if (obstacle.passed) return;

    if (_isRainbowActive) {
      if (_ballY < obstacle.y &&
          (ballCenter - obstacleCenter).distance < kCircleRadius) {
        if (!obstacle.passed) {
          _playSound('score.mp3');
          if (mounted)
            setState(() {
              _score += 1;
              obstacle.passed = true;
            });
        }
      }
      return;
    }

    final toBall = ballCenter - obstacleCenter;
    final dist = toBall.distance;
    final innerR = kCircleRadius - (kCircleThickness / 2);
    final outerR = kCircleRadius + (kCircleThickness / 2);

    if (obstacle.type == ObstacleType.withGap) {
      double angle = atan2(toBall.dy, toBall.dx);
      if (angle < 0) angle += 2 * pi;
      double relativeAngle = (angle - obstacle.rotation) % (2 * pi);
      if (relativeAngle < 0) relativeAngle += 2 * pi;

      if (relativeAngle > obstacle.gapSize) {
        if (dist >= innerR - _currentBallRadius &&
            dist <= outerR + _currentBallRadius) {
          _handleWrongColor();
        }
      }
    } else if (dist >= innerR - _currentBallRadius &&
        dist <= outerR + _currentBallRadius) {
      double angle = atan2(toBall.dy, toBall.dx);
      if (angle < 0) angle += 2 * pi;

      final segment = obstacle.getColorSegment(angle);
      if (segment != null && segment != _ballColor) {
        _handleWrongColor();
      }
    } else if (_ballY < obstacle.y && dist < innerR) {
      if (!obstacle.passed) {
        _playSound('score.mp3');
        if (mounted)
          setState(() {
            _score += 1;
            obstacle.passed = true;
          });
      }
    }
  }

  void _handleWrongColor() {
    if (_hasShield) {
      _playSound('shield_break.mp3');
      if (mounted) setState(() => _hasShield = false);
    } else {
      _endGame();
    }
  }

  void _endGame() {
    if (_gameStatus == GameStatus.gameOver) return;
    _playSound('game_over.mp3');
    _ticker.stop();
    setState(() {
      _gameStatus = GameStatus.gameOver;
      if (_score > _highScore) _highScore = _score;
    });
    _gameOverController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audioPlayer.dispose();
    _starfieldController.dispose();
    _gameOverController.dispose();
    _rainbowTimer?.cancel();
    _slowMoTimer?.cancel();
    _shrinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      // 🎯 MODIFIED: The main tap handler is disabled during the tutorial
      onTap: _showTutorial ? null : _handleTap,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              painter: StarfieldPainter(
                particles: _particles,
                animation: _starfieldController,
              ),
              size: Size.infinite,
            ),
            CustomPaint(
              painter: ColorSwitchPainter(
                ballY: _ballY,
                ballColor: _ballColor,
                obstacles: _obstacles,
                cameraY: _cameraY,
                powerUps: _powerUps,
                currentBallRadius: _currentBallRadius,
                isRainbowActive: _isRainbowActive,
                hasShield: _hasShield,
              ),
              size: Size.infinite,
            ),
            _buildHUD(),
            if (_gameStatus == GameStatus.gameOver) _buildGameOverMenu(),
            // 🎯 ADDED: Conditionally show the tutorial overlay
            if (_showTutorial) _TutorialOverlay(onDismiss: _dismissTutorial),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Positioned(
      top: 38,
      child: Text('Score: $_score',
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildGameOverMenu() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: ScaleTransition(
          scale: _gameOverAnimation,
          child: FadeTransition(
            opacity: _gameOverAnimation,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              margin: const EdgeInsets.symmetric(horizontal: 30.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2c3e50), Color(0xFF141E30)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.redAccent.withOpacity(0.8), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      'Game Over',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(blurRadius: 10.0, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreDisplay("SCORE", _score),
                      _buildScoreDisplay("BEST", _highScore),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _restartGame,
                        icon: const Icon(Icons.refresh, color: Colors.black),
                        label: const Text(
                          'RESTART',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      IconButton(
                        onPressed: () {
                          /* TODO: Implement share functionality */
                        },
                        icon: const Icon(Icons.share, color: Colors.white),
                        iconSize: 30,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(String title, int score) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: const TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;

  StarfieldPainter({required this.particles, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(
          particle.position.dx * size.width,
          particle.position.dy * size.height,
        ),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) => false;
}

class ColorSwitchPainter extends CustomPainter {
  final double ballY;
  final Color ballColor;
  final List<_CircleObstacle> obstacles;
  final double cameraY;
  final List<PowerUp> powerUps;
  final double currentBallRadius;
  final bool isRainbowActive;
  final bool hasShield;

  ColorSwitchPainter({
    required this.ballY,
    required this.ballColor,
    required this.obstacles,
    required this.cameraY,
    required this.powerUps,
    required this.currentBallRadius,
    required this.isRainbowActive,
    required this.hasShield,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, size.height / 2 - cameraY);
    for (final o in obstacles) {
      o.draw(canvas, size);
    }

    for (final p in powerUps) {
      if (!p.isCollected) {
        final textPainter = TextPainter(
          text: TextSpan(
              text: String.fromCharCode(p.icon.codePoint),
              style: TextStyle(
                  fontSize: 30, fontFamily: 'MaterialIcons', color: p.color)),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
            canvas,
            Offset(size.width / 2 - textPainter.width / 2,
                p.y - textPainter.height / 2));
      }
    }

    final ballPaint = Paint();
    if (isRainbowActive) {
      ballPaint.shader = const SweepGradient(colors: kGameColors).createShader(
          Rect.fromCircle(
              center: Offset(size.width / 2, ballY),
              radius: currentBallRadius));
    } else {
      ballPaint.color = ballColor;
    }
    canvas.drawCircle(
        Offset(size.width / 2, ballY), currentBallRadius, ballPaint);

    if (hasShield) {
      final shieldPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(
          Offset(size.width / 2, ballY), currentBallRadius + 8, shieldPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ColorSwitchPainter oldDelegate) => true;
}

class _CircleObstacle {
  double y;
  final double rotateSpeed;
  double rotation;
  bool starCollected = false;
  bool gapBallCollected = false;
  bool passed = false;
  final ObstacleType type;
  double x;
  final double screenWidth;
  double direction = 1;
  double innerRotation = 0;
  final double gapSize = pi / 2;
  final bool hasFakeSwitcher;
  double fakeSwitcherOpacity = 1.0;
  bool isFadingOut = false;

  _CircleObstacle(
      {required this.y,
      required this.rotateSpeed,
      required double startAngle,
      required this.type,
      required this.hasFakeSwitcher,
      required this.screenWidth})
      : rotation = startAngle,
        x = screenWidth / 2;

  void update(double dt, bool isSlowMo) {
    final speed = isSlowMo ? rotateSpeed * 0.3 : rotateSpeed;
    rotation += dt * 2 * pi * speed;
    innerRotation -= dt * 2 * pi * speed * 1.5;

    if (type == ObstacleType.moving) {
      x += 80 * direction * dt;
      if (x < screenWidth * 0.2 || x > screenWidth * 0.8) {
        direction *= -1;
      }
    }

    if (isFadingOut) {
      fakeSwitcherOpacity = max(0.0, fakeSwitcherOpacity - dt * 3);
      if (fakeSwitcherOpacity == 0.0) {
        gapBallCollected = true;
      }
    }
  }

  void triggerFakeSwitcherAnimation() {
    isFadingOut = true;
  }

  Color? getColorSegment(double angle) {
    if (type == ObstacleType.withGap) return null;

    double relativeAngle = (angle - rotation) % (2 * pi);
    if (relativeAngle < 0) relativeAngle += 2 * pi;
    final segment = (relativeAngle / (2 * pi) * kGameColors.length).floor();

    if (type == ObstacleType.doubleLayer) {
      double innerRelativeAngle = (angle - innerRotation) % (2 * pi);
      if (innerRelativeAngle < 0) innerRelativeAngle += 2 * pi;
      final innerSegment =
          (innerRelativeAngle / (2 * pi) * kGameColors.length).floor();
      if (kGameColors[segment] != kGameColors[innerSegment]) return null;
    }
    return kGameColors[segment];
  }

  void draw(Canvas canvas, Size size) {
    final center = Offset(x, y);
    _drawCircleRim(canvas, center);
    if (!starCollected) {
      _drawStar(canvas, center);
    }
    if (!gapBallCollected) {
      _drawGapBall(canvas, center);
    }
  }

  void _drawGapBall(Canvas canvas, Offset obstacleCenter) {
    final gapBallCenter =
        Offset(obstacleCenter.dx, obstacleCenter.dy + kObstacleGap / 2);
    final paint = Paint()
      ..color = Colors.white.withOpacity(fakeSwitcherOpacity);
    canvas.drawCircle(gapBallCenter, kSwitcherRadius, paint);
  }

  void _drawCircleRim(Canvas canvas, Offset center) {
    final rect = Rect.fromCircle(center: center, radius: kCircleRadius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = kCircleThickness;

    if (type == ObstacleType.withGap) {
      paint.color = kGameColors[0];
      canvas.drawArc(rect, rotation + gapSize, 2 * pi - gapSize, false, paint);
      return;
    }

    final sweep = 2 * pi / kGameColors.length;
    for (int i = 0; i < kGameColors.length; i++) {
      paint.color = kGameColors[i];
      final start = rotation + (i * sweep);
      canvas.drawArc(rect, start, sweep, false, paint);
    }

    if (type == ObstacleType.doubleLayer) {
      final innerRect = Rect.fromCircle(
          center: center, radius: kCircleRadius - kCircleThickness);
      for (int i = 0; i < kGameColors.length; i++) {
        paint.color = kGameColors.reversed.toList()[i];
        final start = innerRotation + (i * sweep);
        canvas.drawArc(innerRect, start, sweep, false, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center) {
    final starPaint = Paint()..color = Colors.white;
    final path = Path();
    double radius = kBallRadius * 1.2;
    double angle = pi / 2;
    path.moveTo(
        center.dx + radius * cos(angle), center.dy + radius * sin(angle));
    for (int i = 1; i <= 5; i++) {
      double innerRadius = radius / 2.5;
      angle += (2 * pi / 10);
      path.lineTo(center.dx + innerRadius * cos(angle),
          center.dy + innerRadius * sin(angle));
      angle += (2 * pi / 10);
      path.lineTo(
          center.dx + radius * cos(angle), center.dy + radius * sin(angle));
    }
    path.close();
    canvas.drawPath(path, starPaint);
  }
}

// 🎯 ADDED: The new Tutorial Overlay widget
class _TutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  const _TutorialOverlay({required this.onDismiss});

  @override
  __TutorialOverlayState createState() => __TutorialOverlayState();
}

class __TutorialOverlayState extends State<_TutorialOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();

    _tapController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    _tapAnimation = Tween<double>(begin: -10, end: 10).animate(
        CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'How to Play',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 60),
            _buildRule(
              icon: Icons.touch_app,
              text: 'Tap anywhere to make the ball jump',
            ),
            const SizedBox(height: 30),
            AnimatedBuilder(
              animation: _tapAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _tapAnimation.value),
                  child: child,
                );
              },
              child: const Icon(Icons.arrow_downward,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 30),
            _buildRule(
              icon: Icons.flip_to_front,
              text: 'Match the ball color with the circle segment to pass',
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: widget.onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                'Got It!',
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRule({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.yellowAccent, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
