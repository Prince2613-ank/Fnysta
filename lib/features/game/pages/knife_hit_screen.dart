import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/fruit_model.dart';
import '../painters/broken_log_and_knives_painter.dart';
import '../painters/log_painter.dart';
import '../painters/knife_painter.dart';
import '../widgets/fruit_store.dart';
import '../widgets/game_header.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/level_complete_overlay.dart';

// A simple particle class for effects
class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life;

  Particle({
    required this.position,
    required this.velocity,
    this.color = Colors.white,
    this.size = 2.0,
    this.life = 1.0,
  });

  void update(double dt) {
    velocity += Offset(0, 200 * dt); // Gravity on particles
    position += velocity * dt;
    life -= dt * 0.8; // Slower decay
  }
}

class KnifeHitGame extends StatefulWidget {
  const KnifeHitGame({Key? key}) : super(key: key);

  @override
  _KnifeHitGameState createState() => _KnifeHitGameState();
}

class _KnifeHitGameState extends State<KnifeHitGame>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _rotationController;
  late AnimationController _throwAnimationController;
  late AnimationController _gameOverAnimationController;
  late AnimationController _logBreakAnimationController;
  late AnimationController _recoilController;
  late AnimationController _particleController;
  late AnimationController _squashController;

  late Animation<double> _throwAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _recoilAnimation;
  late Animation<double> _squashAnimation;

  // Game state variables
  int score = 0;
  int highScore = 0;
  int level = 1;
  int knivesLeft = 7;
  List<double> hitKnivesAngles = [];
  bool isLogRotatingRight = true;
  double rotationSpeed = 1.0;
  bool gameOver = false;
  bool levelComplete = false;
  List<double> appleAngles = [];
  int collectedApples = 0;
  bool isThrowing = false;
  bool isLogBroken = false;
  List<Particle> particles = [];
  int combo = 0;

  // Assets
  List<Fruit> fruits = [];
  late Fruit currentFruit;
  Map<String, ui.Image> assetImages = {};
  final Random _random = Random();

  final AudioPlayer _throwSfxPlayer = AudioPlayer();
  final AudioPlayer _hitSfxPlayer = AudioPlayer();
  final AudioPlayer _gameOverSfxPlayer = AudioPlayer();

  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _throwSfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    _hitSfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    _gameOverSfxPlayer.setPlayerMode(PlayerMode.lowLatency);

    _setupAnimationControllers();
    _initializationFuture = _initializeGame();
  }

  void _setupAnimationControllers() {
    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addListener(() => setState(() {}));

    _throwAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100)) // Faster throw
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _processHit();
          isThrowing = false;
          _throwAnimationController.reset();
        }
      });

    _throwAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _throwAnimationController, curve: Curves.easeOut));

    _gameOverAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _shakeAnimation = Tween<double>(begin: 0, end: 40).animate(CurvedAnimation(
        parent: _gameOverAnimationController, curve: Curves.elasticOut));

    _logBreakAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _levelComplete();
        }
      });

    _recoilController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _recoilAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(parent: _recoilController, curve: Curves.easeInOut));

    _particleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(_updateParticles)
          ..repeat();

    _squashController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _squashAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
        CurvedAnimation(parent: _squashController, curve: Curves.easeInOut));
  }

  Future<void> _initializeGame() async {
    try {
      _initializeFruits();
      await _loadAssetImages();
      await AudioCache(prefix: 'assets/')
          .loadAll(['throw_sound.mp3', 'hit.mp3', 'game_over.mp3']);
      _startNewLevel();
    } catch (e) {
      print("Error during game initialization: $e");
    }
  }

  void _initializeFruits() {
    fruits = [
      Fruit(
          name: 'Apple',
          imageAsset: 'assets/apple.png',
          cost: 0,
          isUnlocked: true),
      Fruit(name: 'Banana', imageAsset: 'assets/banana_full.png', cost: 15),
      Fruit(name: 'Papaya', imageAsset: 'assets/Papaya.png', cost: 30),
    ];
    currentFruit = fruits[0];
  }

  Future<void> _loadAssetImages() async {
    final assetsToLoad = fruits.map((f) => f.imageAsset).toList();
    for (String assetPath in assetsToLoad.toSet()) {
      assetImages[assetPath] = await _loadImage(assetPath);
    }
  }

  Future<ui.Image> _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  void _startNewLevel() {
    setState(() {
      hitKnivesAngles.clear();
      knivesLeft = 7;
      gameOver = false;
      levelComplete = false;
      isLogRotatingRight = _random.nextBool();
      rotationSpeed = 1.0 + (_random.nextDouble() * level * 0.25);
      _rotationController.duration =
          Duration(milliseconds: (4000 / rotationSpeed).round());

      appleAngles = List.generate(
          _random.nextInt(3), (_) => _random.nextDouble() * 2 * pi);

      if (level > 2 && _random.nextDouble() < 0.35) {
        _rotationController.repeat(reverse: true);
      } else {
        _rotationController.repeat(reverse: !isLogRotatingRight);
      }
    });
  }

  void _throwKnife() {
    if (knivesLeft > 0 && !gameOver && !levelComplete && !isThrowing) {
      _throwSfxPlayer.play(AssetSource('throw_sound.mp3'));
      setState(() => isThrowing = true);
      _throwAnimationController.forward();
    }
  }

  void _processHit() {
    setState(() {
      knivesLeft--;
      double newKnifeAngle =
          _rotationController.value * 2 * pi * (isLogRotatingRight ? 1 : -1);

      for (double angle in hitKnivesAngles) {
        if ((newKnifeAngle - angle).abs() % (2 * pi) < (pi / 12)) {
          _gameOver();
          return;
        }
      }

      HapticFeedback.mediumImpact();
      _recoilController
          .forward(from: 0.0)
          .then((_) => _recoilController.reverse());
      _squashController
          .forward(from: 0.0)
          .then((_) => _squashController.reverse());
      _hitSfxPlayer.play(AssetSource('hit.mp3'));

      final Size size = MediaQuery.of(context).size;
      final logCenter = Offset(size.width / 2, size.height * 0.35);

      appleAngles.removeWhere((appleAngle) {
        if ((newKnifeAngle - appleAngle).abs() % (2 * pi) < (pi / 15)) {
          final fruitPosition = logCenter +
              Offset.fromDirection(appleAngle - (pi / 2), size.width * 0.24);
          _createFruitParticles(fruitPosition);
          collectedApples++;
          return true;
        }
        return false;
      });

      hitKnivesAngles.add(newKnifeAngle);
      combo++;
      score += combo;

      if (knivesLeft == 0) {
        _breakLog();
      }
    });
  }

  void _createFruitParticles(Offset position) {
    for (int i = 0; i < 20; i++) {
      final velocity = Offset(
        (_random.nextDouble() - 0.5) * 350,
        (_random.nextDouble() - 0.5) * 350,
      );
      particles.add(Particle(
        position: position,
        velocity: velocity,
        color: Colors.redAccent,
        size: _random.nextDouble() * 4 + 2,
        life: _random.nextDouble() * 0.8 + 0.5,
      ));
    }
  }

  void _updateParticles() {
    if (particles.isEmpty) return;
    final dt = 1 / 60.0;
    setState(() {
      for (var p in particles) {
        p.update(dt);
      }
      particles.removeWhere((p) => p.life <= 0);
    });
  }

  void _breakLog() {
    _rotationController.stop();
    setState(() => isLogBroken = true);
    _logBreakAnimationController.forward();
  }

  void _levelComplete() {
    setState(() => levelComplete = true);
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          level++;
          score += 10;
          isLogBroken = false;
          _logBreakAnimationController.reset();
          _startNewLevel();
        });
      }
    });
  }

  void _gameOver() {
    HapticFeedback.heavyImpact();
    if (score > highScore) {
      highScore = score;
    }
    combo = 0;
    _gameOverSfxPlayer.play(AssetSource('game_over.mp3'));
    _rotationController.stop();
    _gameOverAnimationController.forward(from: 0);
    setState(() => gameOver = true);
  }

  void _restartGame() {
    setState(() {
      score = 0;
      level = 1;
      collectedApples = 0;
      _startNewLevel();
    });
  }

  void _showFruitStore() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => FruitStore(
        fruits: fruits,
        currentFruit: currentFruit,
        collectedApples: collectedApples,
        onFruitSelected: (fruit) => setState(() => currentFruit = fruit),
        onFruitUnlocked: (fruit, newAppleCount) {
          setState(() {
            collectedApples = newAppleCount;
            currentFruit = fruit;
            fruits = fruits
                .map((f) =>
                    f.name == fruit.name ? f.copyWith(isUnlocked: true) : f)
                .toList();
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _throwAnimationController.dispose();
    _gameOverAnimationController.dispose();
    _logBreakAnimationController.dispose();
    _recoilController.dispose();
    _particleController.dispose();
    _squashController.dispose();
    _throwSfxPlayer.dispose();
    _hitSfxPlayer.dispose();
    _gameOverSfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              backgroundColor: Color(0xFF0C2434),
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
              backgroundColor: const Color(0xFF0C2434),
              body: Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent))));
        }

        final double logPosition = MediaQuery.of(context).size.height * 0.35;
        final double knifeStartPosition =
            MediaQuery.of(context).size.height * 0.8;

        return Scaffold(
          body: GestureDetector(
            onTap: _throwKnife,
            // ** CODE REPLACED AS REQUESTED **
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black, // fallback
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/dynamic.png', // Make sure this path is correct
                    fit: BoxFit.cover,
                  ),
                  // Game content comes here
                  SafeArea(
                    child: AnimatedBuilder(
                      animation: _gameOverAnimationController,
                      builder: (context, child) {
                        if (_gameOverAnimationController.isAnimating) {
                          final shakeValue = _shakeAnimation.value;
                          final offset = Offset(
                              shakeValue * (_random.nextDouble() - 0.5),
                              shakeValue * (_random.nextDouble() - 0.5));
                          return Transform.translate(
                              offset: offset, child: child);
                        }
                        return child!;
                      },
                      child: Stack(
                        children: [
                          GameHeader(
                            score: score,
                            level: level,
                            collectedApples: collectedApples,
                            onStoreTap: _showFruitStore,
                            combo: combo,
                          ),
                          Positioned(
                              top: logPosition - 50,
                              left: 20,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                      knivesLeft,
                                      (i) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: SizedBox(
                                                width: 15,
                                                height: 45,
                                                child: CustomPaint(
                                                    painter: KnifePainter())),
                                          )))),
                          AnimatedBuilder(
                            animation: _throwAnimationController,
                            builder: (context, child) {
                              final shake =
                                  sin(_throwAnimationController.value * pi) *
                                      -8;
                              return Transform.translate(
                                  offset: Offset(0, shake), child: child);
                            },
                            child: Center(
                              child: ScaleTransition(
                                scale: _recoilAnimation,
                                child: ScaleTransition(
                                  scale: _squashAnimation,
                                  child: isLogBroken
                                      ? CustomPaint(
                                          size: Size(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6),
                                          painter: BrokenLogAndKnivesPainter(
                                            animation:
                                                _logBreakAnimationController,
                                            hitKnivesAngles: hitKnivesAngles,
                                          ),
                                        )
                                      : Transform.rotate(
                                          angle: _rotationController.value *
                                              2 *
                                              pi *
                                              (isLogRotatingRight ? 1 : -1),
                                          child: CustomPaint(
                                            size: Size(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6,
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6),
                                            painter: LogPainter(
                                              hitKnivesAngles: hitKnivesAngles,
                                              fruitAngles: appleAngles,
                                              fruitUiImage: assetImages[
                                                  currentFruit.imageAsset],
                                              time: _rotationController.value,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          if (particles.isNotEmpty)
                            CustomPaint(
                              size: Size.infinite,
                              painter: _ParticlePainter(particles: particles),
                            ),
                          if (level == 1 && knivesLeft == 7)
                            const Positioned(
                              bottom: 100,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Text(
                                  "Tap to throw!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (!gameOver && !levelComplete)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              top: logPosition +
                                  100 +
                                  ((knifeStartPosition - logPosition - 200) *
                                      (1 - _throwAnimation.value)),
                              child: Center(
                                  child: SizedBox(
                                      width: 45,
                                      height: 135,
                                      child: CustomPaint(
                                          painter: KnifePainter()))),
                            ),
                          if (gameOver)
                            GameOverOverlay(
                                level: level,
                                onRestart: _restartGame,
                                highScore: highScore),
                          if (levelComplete && !gameOver)
                            LevelCompleteOverlay(level: level),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      if (p.life > 0) {
        paint.color = p.color.withOpacity(p.life);
        canvas.drawCircle(
            p.position, p.size * p.life, paint); // Size shrinks with life
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
