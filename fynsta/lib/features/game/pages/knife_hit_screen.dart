// lib/features/game/pages/knife_hit_screen.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../managers/achievement_manager.dart';
import '../models/fruit_model.dart';
import '../models/game_theme_model.dart';
import '../models/knife_model.dart';
import '../painters/aiming_line_painter.dart';
import '../painters/broken_log_and_knives_painter.dart';
import '../painters/explosion_painter.dart';
import '../painters/knife_cover_painter.dart';
import '../painters/knife_painter.dart';
import '../painters/log_painter.dart';
import '../widgets/boss_tutorial_overlay.dart';
import '../widgets/fruit_store.dart';
import '../widgets/game_header.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/knife_store.dart';
import '../widgets/level_complete_overlay.dart';
import '../widgets/pause_menu_overlay.dart';
import '../widgets/spin_the_wheel_overlay.dart';
import 'achievements_screen.dart';

class KnifeHitGame extends StatefulWidget {
  const KnifeHitGame({Key? key}) : super(key: key);

  @override
  _KnifeHitGameState createState() => _KnifeHitGameState();
}

class _KnifeHitGameState extends State<KnifeHitGame>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _throwAnimationController;
  late AnimationController _gameOverAnimationController;
  late AnimationController _logBreakAnimationController;
  late AnimationController _recoilController;
  late AnimationController _particleController;
  late AnimationController _squashController;
  late AnimationController _perfectTimingGlowController;
  late AnimationController _tutorialAnimationController;
  late AnimationController _wobbleController;
  late AnimationController _explosionController;
  late AnimationController _aimAssistController;

  late Animation<double> _throwAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _recoilAnimation;
  late Animation<double> _squashAnimation;
  late Animation<double> _perfectTimingGlowAnimation;
  late Animation<Offset> _tutorialHandAnimation;
  late Animation<double> _wobbleAnimation;
  late Animation<double> _aimAssistAnimation;

  int score = 0;
  int highScore = 0;
  int level = 1;
  int knivesLeft = 7;
  int _totalKnivesForLevel = 7;
  List<double> hitKnivesAngles = [];
  bool isLogRotatingRight = true;
  double rotationSpeed = 1.0;
  double _currentVisualRotationSpeed = 1.0;
  bool gameOver = false;
  bool levelComplete = false;
  List<double> appleAngles = [];
  int collectedApples = 0;
  bool isThrowing = false;
  bool isLogBroken = false;
  List<Particle> particles = [];
  int combo = 0;

  bool _isPerfectTiming = false;
  bool _wasPerfectThrowAttempt = false;
  int _consecutivePerfectHits = 0;
  int _scoreMultiplier = 1;
  String _perfectHitMessage = '';
  Timer? _perfectHitMessageTimer;
  Timer? _inactivityTimer;
  bool _isCriticalPausing = false;

  bool _isDragToThrowMode = false;
  Offset? _dragStartPoint;
  Offset? _dragCurrentPoint;

  bool _isPaused = false;
  bool _isSoundOn = true;
  bool _showDragTutorial = false;
  bool _showBossTutorial = false;

  bool _isExploding = false;
  Offset _explosionCenter = Offset.zero;

  bool _isBossLevel = false;
  List<Map<String, double>> _armoredSections = [];
  List<double> _bombAngles = [];
  Timer? _bossPatternTimer;
  List<Knife> knives = [];
  late Knife currentKnife;
  bool _secondChanceUsedThisGame = false;
  bool _slowingAbilityUsedThisLevel = false;

  bool _isInvincible = false;
  Timer? _invincibilityTimer;
  Timer? _logRotationTimer;

  late GameTheme _currentTheme;
  bool _isFlamingKnifeActive = false;

  int _reviveCount = 0;
  int _slowMoCount = 0;

  final AchievementManager _achievementManager = AchievementManager();

  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<GameTheme> _gameThemes = [
    const GameTheme(
      name: 'Forest',
      backgroundGradient: [Color(0xFF2c3e50), Color(0xFF3498db)],
      logBaseColor: Color(0xFFf5d490),
      logBarkColor: Color(0xFFa1662d),
      logRingColor: Color(0xFF8B4513),
      hitSound: 'throw_sound.mp3',
    ),
    const GameTheme(
      name: 'Sci-Fi',
      backgroundGradient: [Color(0xFF000428), Color(0xFF004e92)],
      logBaseColor: Color(0xFFbdc3c7),
      logBarkColor: Color(0xFF2c3e50),
      logRingColor: Color(0xFF7f8c8d),
      hitSound: 'throw_sound.mp3',
    ),
    const GameTheme(
      name: 'Spooky',
      backgroundGradient: [Color(0xFF434343), Color(0xFF000000)],
      logBaseColor: Color(0xFFa1a1a1),
      logBarkColor: Color(0xFF595959),
      logRingColor: Color(0xFF3b3b3b),
      hitSound: 'throw_sound.mp3',
    ),
  ];

  List<Fruit> fruits = [];
  late Fruit currentFruit;
  Map<String, ui.Image> assetImages = {};
  final Random _random = Random();
  late Future<void> _initializationFuture;

  bool _showSpinWheel = false;
  bool _canClaimDailyBonus = false;
  DateTime? _lastBonusClaimTime;

  @override
  void initState() {
    super.initState();
    _setupAnimationControllers();
    _initializationFuture = _initializeGame();
    _wobbleController.repeat(reverse: true);
    _checkDailyBonusStatus();
  }

  void _setupAnimationControllers() {
    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addListener(() {
            if (knivesLeft <= 2 &&
                !_isCriticalPausing &&
                hitKnivesAngles.isNotEmpty) {
              _checkForCriticalPause();
            }
            setState(() {});
          });

    _throwAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100))
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

    _perfectTimingGlowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _perfectTimingGlowAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .animate(_perfectTimingGlowController);

    _tutorialAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _tutorialHandAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0.5),
    ).animate(CurvedAnimation(
      parent: _tutorialAnimationController,
      curve: Curves.easeInOut,
    ));

    _wobbleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _wobbleAnimation =
        Tween<double>(begin: -0.02, end: 0.02).animate(_wobbleController);

    _explosionController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isExploding = false);
          _gameOver();
        }
      });

    _aimAssistController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _aimAssistAnimation = Tween<double>(begin: 1.0, end: 0.2)
        .animate(CurvedAnimation(
      parent: _aimAssistController,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        _currentVisualRotationSpeed = rotationSpeed * _aimAssistAnimation.value;
        _rotationController.duration = Duration(
            milliseconds: (4000 / _currentVisualRotationSpeed).round());
        if (!_rotationController.isAnimating) {
          _rotationController.repeat();
        }
      });
  }

  Future<void> _checkDailyBonusStatus() async {
    // --- FOR TESTING: This line makes the bonus always available ---
    if (mounted) setState(() => _canClaimDailyBonus = true);
    return;
    // --- END OF TEST CODE ---

    /* --- ORIGINAL 24-HOUR COOLDOWN LOGIC (Comment out for testing) ---
    final prefs = await SharedPreferences.getInstance();
    final lastClaimedString = prefs.getString('lastBonusClaimTime');
    if (lastClaimedString == null) {
      if (mounted) setState(() => _canClaimDailyBonus = true);
      return;
    }
    final lastClaimed = DateTime.parse(lastClaimedString);
    if (mounted) {
      setState(() {
        _lastBonusClaimTime = lastClaimed; // Store the time
        _canClaimDailyBonus =
            DateTime.now().difference(lastClaimed).inHours >= 24;
      });
    }
    */
  }

  void _showBonusCooldownMessage() {
    if (_lastBonusClaimTime == null) return;

    final nextBonusTime = _lastBonusClaimTime!.add(const Duration(hours: 24));
    final remaining = nextBonusTime.difference(DateTime.now());

    if (remaining.isNegative) {
      setState(() => _canClaimDailyBonus = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Your daily bonus is now ready!'),
        backgroundColor: Colors.green,
      ));
      return;
    }

    final formattedTime =
        '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Next bonus available in $formattedTime'),
        backgroundColor: Colors.redAccent));
  }

  void _showDailyBonus() {
    setState(() {
      _showSpinWheel = true;
    });
  }

  void _onRewardClaimed(String reward) async {
    final prefs = await SharedPreferences.getInstance();

    if (reward.contains("Apples")) {
      final amount =
          int.tryParse(reward.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      setState(() => collectedApples += amount);
      await prefs.setInt('collectedApples', collectedApples);
    } else if (reward.contains("Slow-Mo")) {
      setState(() => _slowMoCount++);
      await prefs.setInt('slowMoCount', _slowMoCount);
    } else if (reward.contains("Revive")) {
      setState(() => _reviveCount++);
      await prefs.setInt('reviveCount', _reviveCount);
    }

    final now = DateTime.now();
    await prefs.setString('lastBonusClaimTime', now.toIso8601String());

    setState(() {
      _showSpinWheel = false;
      _canClaimDailyBonus = false;
      _lastBonusClaimTime = now;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('You won: $reward!'), backgroundColor: Colors.green),
    );
  }

  void _showAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AchievementsScreen()),
    );
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('hasSeenDragTutorial') ?? false;

    if (!hasSeen && mounted) {
      setState(() {
        _showDragTutorial = true;
      });
      _tutorialAnimationController.repeat(reverse: true);

      Timer(const Duration(seconds: 4), () {
        if (mounted && _showDragTutorial) {
          setState(() {
            _showDragTutorial = false;
          });
          _tutorialAnimationController.stop();
        }
      });

      await prefs.setBool('hasSeenDragTutorial', true);
    }
  }

  Future<void> _loadSounds() async {}

  Future<void> _initializeGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      collectedApples = prefs.getInt('collectedApples') ?? 0;
      highScore = prefs.getInt('highScore') ?? 0;
      _reviveCount = prefs.getInt('reviveCount') ?? 0;
      _slowMoCount = prefs.getInt('slowMoCount') ?? 0;
      await _achievementManager.loadAchievements();
      await _loadSounds();

      _initializeFruits();
      _initializeKnives();
      await _loadAssetImages();
      _startNewLevel();
    } catch (e) {
      print("Error during game initialization: $e");
    }
  }

  void _initializeFruits() {
    fruits = [
      const Fruit(
          name: 'Apple',
          imageAsset: 'assets/apple.png',
          cost: 0,
          isUnlocked: true),
      const Fruit(
          name: 'Banana', imageAsset: 'assets/banana_full.png', cost: 15),
      const Fruit(name: 'Papaya', imageAsset: 'assets/Papaya.png', cost: 30),
      const Fruit(
          name: 'Orange',
          cost: 50,
          powerUp: PowerUpType.invincibility,
          color: Colors.orange),
      const Fruit(
          name: 'Watermelon',
          cost: 75,
          powerUp: PowerUpType.coinMagnet,
          color: Colors.green),
    ];
    currentFruit = fruits[0];
  }

  void _initializeKnives() {
    knives = [
      const Knife(
          name: 'Standard',
          ability: KnifeAbility.none,
          color: Color(0xFFD0D0D0),
          isUnlocked: true),
      const Knife(
          name: 'Slowing',
          ability: KnifeAbility.slowing,
          color: Colors.cyanAccent,
          cost: 3),
      const Knife(
          name: 'Second Chance',
          ability: KnifeAbility.secondChance,
          color: Colors.amber,
          cost: 5),
    ];
    currentKnife = knives[0];
  }

  Future<void> _loadAssetImages() async {
    final assetsToLoad =
        fruits.where((f) => f.imageAsset != null).map((f) => f.imageAsset!);
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
    _bossPatternTimer?.cancel();
    _logRotationTimer?.cancel();

    setState(() {
      _currentTheme = _gameThemes[((level - 1) ~/ 5) % _gameThemes.length];

      _slowingAbilityUsedThisLevel = false;
      isLogBroken = false;
      _logBreakAnimationController.reset();
      _armoredSections.clear();
      _bombAngles.clear();

      _isBossLevel = level % 10 == 0;
      appleAngles = List.generate(
          1 + _random.nextInt(3), (_) => _random.nextDouble() * 2 * pi);

      if (_isBossLevel) {
        _setupBossLevel();
      } else {
        _setupStandardLevel();
      }

      hitKnivesAngles.clear();
      gameOver = false;
      levelComplete = false;
      _perfectHitMessage = '';
      _perfectHitMessageTimer?.cancel();
      _resetInactivityTimer();
    });
  }

  void _setupStandardLevel() {
    const double totalCircumference = 2 * pi;
    const double knifeSafeZone = pi / 6;
    double occupiedSpace =
        (appleAngles.length + _bombAngles.length) * (pi / 10);
    int maxKnives =
        ((totalCircumference - occupiedSpace) / knifeSafeZone).floor();
    knivesLeft = max(4, min(9, maxKnives));
    _totalKnivesForLevel = knivesLeft;

    if (level <= 10) {
      isLogRotatingRight = true;
      rotationSpeed = 0.8 + (level * 0.1);
      _currentVisualRotationSpeed = rotationSpeed;
      _rotationController.duration =
          Duration(milliseconds: (4000 / _currentVisualRotationSpeed).round());
      _rotationController.repeat();
      _bombAngles = [];
      _armoredSections = [];
    } else {
      _logRotationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          isLogRotatingRight = _random.nextBool();
          rotationSpeed =
              (1.5 + _random.nextDouble() * (level * 0.1)).clamp(1.5, 4.0);
          _currentVisualRotationSpeed = rotationSpeed;
          _rotationController.duration = Duration(
              milliseconds: (4000 / _currentVisualRotationSpeed).round());
          _rotationController.repeat();
        });
      });
      if (_random.nextDouble() < 0.4) {
        _bombAngles = List.generate(1, (_) => _random.nextDouble() * 2 * pi);
      }
      if (level > 15 && _random.nextDouble() < 0.3) {
        _armoredSections = List.generate(1, (index) {
          final start = _random.nextDouble() * 2 * pi;
          final sweep = pi / 5 + _random.nextDouble() * pi / 5;
          return {'start': start, 'sweep': sweep};
        });
      }
    }
  }

  void _setupBossLevel() {
    knivesLeft = 5;
    _totalKnivesForLevel = knivesLeft;

    if (level == 10) {
      setState(() => _showBossTutorial = true);
      _armoredSections = List.generate(1, (index) {
        final start = _random.nextDouble() * 2 * pi;
        return {'start': start, 'sweep': pi / 2};
      });
      rotationSpeed = 1.0;
      _currentVisualRotationSpeed = rotationSpeed;
      isLogRotatingRight = true;
      _rotationController.duration =
          Duration(milliseconds: (4000 / _currentVisualRotationSpeed).round());
    } else {
      _armoredSections = List.generate(2, (index) {
        final start = _random.nextDouble() * 2 * pi;
        final sweep = pi / 3;
        return {'start': start, 'sweep': sweep};
      });
      if (!_showBossTutorial) {
        _changeBossPattern();
        _bossPatternTimer = Timer.periodic(
            const Duration(seconds: 2), (_) => _changeBossPattern());
      }
    }
  }

  void _changeBossPattern() {
    setState(() {
      rotationSpeed = 1.5 + _random.nextDouble() * (level / 5.0);
      _currentVisualRotationSpeed = rotationSpeed;
      isLogRotatingRight = _random.nextBool();
      _rotationController.duration =
          Duration(milliseconds: (4000 / _currentVisualRotationSpeed).round());
      if (_random.nextDouble() > 0.3) {
        _rotationController.repeat(reverse: _random.nextBool());
      } else {
        _rotationController.repeat();
      }
    });
  }

  void _playSound(String soundAsset) {
    if (_isSoundOn) {
      _audioPlayer.play(AssetSource(soundAsset));
    }
  }

  void _triggerExplosion(Offset center) {
    setState(() {
      _explosionCenter = center;
      _isExploding = true;
    });
    _explosionController.forward(from: 0.0);
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_aimAssistController.isAnimating || _aimAssistController.value > 0) {
      _aimAssistController.reverse();
    }
    _inactivityTimer =
        Timer(const Duration(milliseconds: 1500), _activateAimAssist);
  }

  void _activateAimAssist() {
    if (isThrowing || gameOver || _isPaused) return;
    _aimAssistController.forward();
  }

  void _checkForCriticalPause() {
    final sortedAngles = [...hitKnivesAngles]..sort();
    double largestGap = 0;
    double bestAngle = 0;

    if (sortedAngles.isEmpty) {
      return;
    }

    for (int i = 0; i < sortedAngles.length; i++) {
      final currentAngle = sortedAngles[i];
      final nextAngle = sortedAngles[(i + 1) % sortedAngles.length];
      double diff = (nextAngle - currentAngle);
      if (diff < 0) diff += 2 * pi;
      if (diff > largestGap) {
        largestGap = diff;
        bestAngle = currentAngle + (diff / 2);
      }
    }

    final double targetHitAngle = bestAngle;
    final double currentLogAngle = _rotationController.value * 2 * pi;
    final double targetLogAngle = (pi - targetHitAngle) % (2 * pi);

    double diff = (currentLogAngle - targetLogAngle).abs();
    if (diff > pi) diff = 2 * pi - diff;

    if (diff < 0.1) {
      _isCriticalPausing = true;
      _rotationController.stop();
      Timer(const Duration(milliseconds: 400), () {
        if (!gameOver && !_isPaused) {
          _rotationController.repeat();
          _isCriticalPausing = false;
        }
      });
    }
  }

  void _throwKnife() {
    if (knivesLeft > 0 &&
        !gameOver &&
        !levelComplete &&
        !isThrowing &&
        !_isPaused &&
        !_showBossTutorial &&
        !_isExploding) {
      _inactivityTimer?.cancel();
      if (_aimAssistController.isAnimating || _aimAssistController.value > 0) {
        _aimAssistController.reverse();
      }

      _wasPerfectThrowAttempt = _isPerfectTiming;
      setState(() => isThrowing = true);
      _throwAnimationController.forward();
    }
  }

  void _processHit() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final double logPosition = screenHeight * 0.30;
    final double logWidgetSize = screenWidth * 0.45;
    final double logRadius = logWidgetSize / 2;

    final double logRotation =
        _rotationController.value * 2 * pi * (isLogRotatingRight ? 1 : -1);
    final double newKnifeAngleOnLog = pi - logRotation;
    final impactPosition = Offset(screenWidth / 2, logPosition + logRadius);

    for (double bombAngle in _bombAngles) {
      double diff = (newKnifeAngleOnLog - bombAngle + pi) % (2 * pi) - pi;
      if (diff.abs() < (pi / 12)) {
        final bombPosition = impactPosition +
            Offset.fromDirection(bombAngle + logRotation, logRadius * 0.65);
        _triggerExplosion(bombPosition);
        return;
      }
    }

    for (var section in _armoredSections) {
      final start = section['start']!;
      final end = start + section['sweep']!;
      final normalizedHitAngle = (newKnifeAngleOnLog + pi) % (2 * pi);
      final normalizedStart = (start + pi) % (2 * pi);
      final normalizedEnd = (end + pi) % (2 * pi);

      bool hitArmor;
      if (normalizedStart <= normalizedEnd) {
        hitArmor = normalizedHitAngle >= normalizedStart &&
            normalizedHitAngle <= normalizedEnd;
      } else {
        hitArmor = normalizedHitAngle >= normalizedStart ||
            normalizedHitAngle <= normalizedEnd;
      }

      if (hitArmor && _isFlamingKnifeActive) {
        setState(() {
          _armoredSections.remove(section);
          _isFlamingKnifeActive = false;
        });
        _playSound('throw_sound.mp3');
      } else if (hitArmor) {
        _createSparks(impactPosition, color: Colors.grey[400]!);
        _playSound('throw_sound.mp3');
        _gameOver();
        return;
      }
    }

    for (double angle in hitKnivesAngles) {
      double diff = (newKnifeAngleOnLog - angle + pi) % (2 * pi) - pi;
      if (diff.abs() < (pi / 18)) {
        if (_isInvincible) {
          _createSparks(impactPosition, color: Colors.purpleAccent);
          _playSound('throw_sound.mp3');
          return;
        }
        if (_reviveCount > 0) {
          setState(() {
            _reviveCount--;
          });
          _createSparks(impactPosition, color: Colors.amber);
          _playSound('throw_sound.mp3');
          return;
        }
        if (currentKnife.ability == KnifeAbility.secondChance &&
            !_secondChanceUsedThisGame) {
          setState(() {
            _secondChanceUsedThisGame = true;
          });
          _createSparks(impactPosition, color: Colors.amber);
          _playSound('throw_sound.mp3');
          setState(() => knivesLeft--);
          if (knivesLeft == 0) _breakLog();
          return;
        } else {
          _createSparks(impactPosition);
          _playSound('throw_sound.mp3');
          _gameOver();
        }
        return;
      }
    }

    _playSound(_currentTheme.hitSound);
    HapticFeedback.mediumImpact();

    setState(() {
      knivesLeft--;
      combo++;
      if (combo % 10 == 0) {
        collectedApples += 5;
      }
      if (_wasPerfectThrowAttempt) {
        _consecutivePerfectHits++;
        _scoreMultiplier = 1 + (_consecutivePerfectHits / 2).floor();
        score += combo * _scoreMultiplier;
        _perfectHitMessageTimer?.cancel();
        _perfectHitMessage = "PERFECT! x$_scoreMultiplier";
        _perfectHitMessageTimer = Timer(const Duration(seconds: 2),
            () => setState(() => _perfectHitMessage = ''));

        if (_consecutivePerfectHits == 3) {
          setState(() => _isFlamingKnifeActive = true);
        } else if (_consecutivePerfectHits == 5) {
          _appleShower();
        } else if (_consecutivePerfectHits >= 7 &&
            _consecutivePerfectHits % 2 != 0) {
          _activateSlowMotion();
        }
      } else {
        combo = 0;
        _consecutivePerfectHits = 0;
        _isFlamingKnifeActive = false;
        _scoreMultiplier = 1;
        score += combo;
      }
      _wasPerfectThrowAttempt = false;

      _recoilController
          .forward(from: 0.0)
          .then((_) => _recoilController.reverse());
      _squashController
          .forward(from: 0.0)
          .then((_) => _squashController.reverse());

      final Size size = MediaQuery.of(context).size;
      final logCenter = Offset(size.width / 2, size.height * 0.35);

      _createLogParticles(impactPosition, pi / 2);

      appleAngles.removeWhere((appleAngleOnLog) {
        double currentAppleScreenAngle =
            (appleAngleOnLog + logRotation) % (2 * pi);
        double diff = (pi - currentAppleScreenAngle + pi) % (2 * pi) - pi;
        if (diff.abs() < (pi / 15)) {
          _playSound('throw_sound.mp3');
          final double fruitOrbitRadius = logRadius * 0.8;
          final fruitPosition =
              logCenter + Offset.fromDirection(pi / 2, fruitOrbitRadius);
          _createFruitParticles(fruitPosition);
          collectedApples++;
          _achievementManager.updateProgress('apples_1', collectedApples);
          if (currentFruit.powerUp != PowerUpType.none) {
            _activatePowerUp(currentFruit.powerUp);
          }
          return true;
        }
        return false;
      });

      hitKnivesAngles.add(newKnifeAngleOnLog);
      _resetInactivityTimer();

      if (knivesLeft == 0) {
        _breakLog();
      }
    });
  }

  void _appleShower() {
    setState(() => collectedApples += 10);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('+10 Apples!'), backgroundColor: Colors.green),
    );
  }

  void _activateSlowMotion() {
    final originalDuration = _rotationController.duration;
    _rotationController.stop();
    _rotationController.duration = originalDuration! * 2;
    _rotationController.repeat();

    Timer(const Duration(seconds: 3), () {
      if (!gameOver && mounted) {
        _rotationController.stop();
        _rotationController.duration = originalDuration;
        _rotationController.repeat();
      }
    });
  }

  void _activatePowerUp(PowerUpType powerUp) {
    switch (powerUp) {
      case PowerUpType.invincibility:
        _activateInvincibility();
        break;
      case PowerUpType.coinMagnet:
        _activateCoinMagnet();
        break;
      case PowerUpType.none:
        break;
    }
  }

  void _activateInvincibility() {
    setState(() {
      _isInvincible = true;
    });
    _invincibilityTimer?.cancel();
    _invincibilityTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _isInvincible = false;
      });
    });
  }

  void _activateCoinMagnet() {
    setState(() {
      collectedApples += appleAngles.length;
      appleAngles.clear();
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
        size: Size(_random.nextDouble() * 4 + 2, _random.nextDouble() * 4 + 2),
        life: _random.nextDouble() * 0.8 + 0.5,
        rotation: 0,
        rotationSpeed: 0,
      ));
    }
  }

  void _createSparks(Offset position,
      {Color color = Colors.yellowAccent, int count = 15}) {
    for (int i = 0; i < count; i++) {
      final double speed = _random.nextDouble() * 500 + 300;
      final double angle = _random.nextDouble() * 2 * pi;
      final velocity = Offset(cos(angle) * speed, sin(angle) * speed);
      particles.add(Particle(
        position: position,
        velocity: velocity,
        color: color,
        size: Size(_random.nextDouble() * 2 + 1, _random.nextDouble() * 8 + 5),
        life: _random.nextDouble() * 0.4 + 0.2,
        rotation: angle,
        rotationSpeed: 0,
      ));
    }
  }

  void _createLogParticles(Offset position, double impactAngle) {
    for (int i = 0; i < 25; i++) {
      final double speed = _random.nextDouble() * 350 + 200;
      final double angle =
          impactAngle + (_random.nextDouble() - 0.5) * (pi / 1.5);
      final velocity = Offset(cos(angle) * speed, sin(angle) * speed);
      particles.add(Particle(
        position: position,
        velocity: velocity,
        color: Color.lerp(_currentTheme.logBarkColor,
            _currentTheme.logBaseColor, _random.nextDouble())!,
        size: Size(_random.nextDouble() * 5 + 3, _random.nextDouble() * 12 + 6),
        life: _random.nextDouble() * 0.6 + 0.4,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 15,
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
    _playSound('throw_sound.mp3');
    _rotationController.stop();
    if (_isBossLevel) {
      _achievementManager.updateProgress('bosses_1', 1);
    }
    setState(() => isLogBroken = true);
    _logBreakAnimationController.forward();
  }

  void _levelComplete() {
    setState(() {
      levelComplete = true;
      if (_isBossLevel) {
        collectedApples += 3;
      }
    });

    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          level++;
          score += 10;
          _startNewLevel();
        });
      }
    });
  }

  void _gameOver() async {
    HapticFeedback.heavyImpact();
    final prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      highScore = score;
      await prefs.setInt('highScore', highScore);
    }
    await prefs.setInt('collectedApples', collectedApples);
    await prefs.setInt('reviveCount', _reviveCount);
    await prefs.setInt('slowMoCount', _slowMoCount);
    _achievementManager.updateProgress('score_1', score);

    combo = 0;
    _playSound('game_over.mp3');
    _rotationController.stop();
    _gameOverAnimationController.forward(from: 0);
    setState(() => gameOver = true);
  }

  void _restartGame() {
    setState(() {
      score = 0;
      level = 1;
      _secondChanceUsedThisGame = false;
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

  void _showKnifeStore() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => KnifeStore(
        knives: knives,
        currentKnife: currentKnife,
        collectedApples: collectedApples,
        onKnifeSelected: (knife) => setState(() => currentKnife = knife),
        onKnifeUnlocked: (knife, newAppleCount) {
          setState(() {
            collectedApples = newAppleCount;
            currentKnife = knife;
            knives = knives
                .map((k) =>
                    k.name == knife.name ? k.copyWith(isUnlocked: true) : k)
                .toList();
          });
        },
      ),
    );
  }

  void _useSlowingAbility() {
    if ((currentKnife.ability == KnifeAbility.slowing &&
            !_slowingAbilityUsedThisLevel &&
            !_isPaused) ||
        _slowMoCount > 0) {
      if (_slowMoCount > 0) {
        setState(() {
          _slowMoCount--;
        });
      } else {
        setState(() {
          _slowingAbilityUsedThisLevel = true;
        });
      }

      final originalDuration = _rotationController.duration;
      _rotationController.stop();
      _rotationController.duration = originalDuration! * 3;
      _rotationController.repeat(reverse: !isLogRotatingRight);
      Timer(const Duration(seconds: 3), () {
        if (!gameOver) {
          _rotationController.stop();
          _rotationController.duration = originalDuration;
          _rotationController.repeat(reverse: !isLogRotatingRight);
        }
      });
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _rotationController.stop();
        _logRotationTimer?.cancel();
        _inactivityTimer?.cancel();
      } else {
        _rotationController.repeat(reverse: !isLogRotatingRight);
        _resetInactivityTimer();
      }
    });
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
    _perfectTimingGlowController.dispose();
    _tutorialAnimationController.dispose();
    _explosionController.dispose();
    _aimAssistController.dispose();
    _perfectHitMessageTimer?.cancel();
    _bossPatternTimer?.cancel();
    _inactivityTimer?.cancel();
    _invincibilityTimer?.cancel();
    _logRotationTimer?.cancel();
    _wobbleController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildThrowableKnife(
      double logPosition, double knifeStartPosition, double logWidgetSize) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_throwAnimationController, _wobbleController]),
      builder: (context, child) {
        double currentTop;
        final start = knifeStartPosition - 50;
        final end = logPosition + logWidgetSize / 2.2;

        if (isThrowing) {
          currentTop =
              ui.lerpDouble(start, end, _throwAnimationController.value)!;
        } else {
          currentTop = start;
          if (_isDragToThrowMode &&
              _dragStartPoint != null &&
              _dragCurrentPoint != null &&
              !isThrowing) {
            final dragOffsetY =
                (_dragCurrentPoint!.dy - _dragStartPoint!.dy).clamp(0.0, 50.0);
            currentTop += dragOffsetY * 1.5;
          }
        }

        return Positioned(
          top: currentTop,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: knivesLeft > 0 && !isLogBroken ? 1.0 : 0.0,
            child: Transform.rotate(
              angle: isThrowing ? 0 : _wobbleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Center(
        child: SizedBox(
          width: 45,
          height: 135,
          child: CustomPaint(painter: KnifePainter(color: currentKnife.color)),
        ),
      ),
    );
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

        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final double logPosition = screenHeight * 0.25;
        final double logWidgetSize = screenWidth * 0.57;
        final double knifeStartPosition = screenHeight * 0.82;

        return Scaffold(
          body: GestureDetector(
            onTap: () {
              if (!_isDragToThrowMode) {
                _throwKnife();
              }
            },
            onVerticalDragStart: (details) {
              if (_isDragToThrowMode &&
                  !isThrowing &&
                  !gameOver &&
                  !_isPaused) {
                setState(() {
                  _dragStartPoint = details.globalPosition;
                  _dragCurrentPoint = details.globalPosition;
                });
              }
            },
            onVerticalDragUpdate: (details) {
              if (_isDragToThrowMode && _dragStartPoint != null) {
                setState(() {
                  _dragCurrentPoint = details.globalPosition;
                });
              }
            },
            onVerticalDragEnd: (details) {
              if (_isDragToThrowMode && _dragStartPoint != null) {
                final pullDistance =
                    (_dragCurrentPoint!.dy - _dragStartPoint!.dy);
                if (pullDistance > 20) {
                  _throwKnife();
                }
                setState(() {
                  _dragStartPoint = null;
                  _dragCurrentPoint = null;
                });
              }
            },
            onVerticalDragCancel: () {
              if (_isDragToThrowMode) {
                setState(() {
                  _dragStartPoint = null;
                  _dragCurrentPoint = null;
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _currentTheme.backgroundGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
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
                            isBossLevel: _isBossLevel,
                            collectedApples: collectedApples,
                            onStoreTap: _showFruitStore,
                            onPauseTap: _togglePause,
                            combo: combo,
                            reviveCount: _reviveCount,
                            slowMoCount: _slowMoCount,
                          ),
                          Positioned(
                              top: logPosition - 50,
                              left: 20,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      List.generate(_totalKnivesForLevel, (i) {
                                    final bool knifeHasBeenThrown =
                                        i >= knivesLeft;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: SizedBox(
                                        width: 15,
                                        height: 45,
                                        child: CustomPaint(
                                          painter: knifeHasBeenThrown
                                              ? const KnifeCoverPainter()
                                              : KnifePainter(
                                                  color: currentKnife.color),
                                        ),
                                      ),
                                    );
                                  }))),
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              _rotationController,
                              _recoilController,
                              _squashController,
                            ]),
                            builder: (context, child) {
                              return Positioned(
                                top: logPosition,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: ScaleTransition(
                                    scale: _recoilAnimation,
                                    child: ScaleTransition(
                                      scale: _squashAnimation,
                                      child: isLogBroken
                                          ? CustomPaint(
                                              size: Size(logWidgetSize * 1.1,
                                                  logWidgetSize * 1.1),
                                              painter:
                                                  BrokenLogAndKnivesPainter(
                                                animation:
                                                    _logBreakAnimationController,
                                                hitKnivesAngles:
                                                    hitKnivesAngles,
                                              ),
                                            )
                                          : Transform.rotate(
                                              angle: _rotationController.value *
                                                  2 *
                                                  pi *
                                                  (isLogRotatingRight ? 1 : -1),
                                              child: CustomPaint(
                                                size: Size(logWidgetSize,
                                                    logWidgetSize),
                                                painter: LogPainter(
                                                  hitKnivesAngles:
                                                      hitKnivesAngles,
                                                  fruitAngles: appleAngles,
                                                  fruitUiImage: currentFruit
                                                              .imageAsset !=
                                                          null
                                                      ? assetImages[currentFruit
                                                          .imageAsset!]
                                                      : null,
                                                  currentFruit: currentFruit,
                                                  time:
                                                      _rotationController.value,
                                                  baseColor: _currentTheme
                                                      .logBaseColor,
                                                  barkColor: _currentTheme
                                                      .logBarkColor,
                                                  ringColor: _currentTheme
                                                      .logRingColor,
                                                  armoredSections:
                                                      _armoredSections,
                                                  bombAngles: _bombAngles,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (particles.isNotEmpty)
                            CustomPaint(
                              painter: _ParticlePainter(particles: particles),
                            ),
                          if (_isFlamingKnifeActive)
                            Positioned(
                              top: 120,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.orangeAccent,
                                        blurRadius: 15,
                                        spreadRadius: 3)
                                  ],
                                ),
                                child: const Text(
                                  "FLAMING KNIFE!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.store,
                                        color: Colors.white, size: 30),
                                    onPressed: _showKnifeStore,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.my_location,
                                      color: _isDragToThrowMode
                                          ? Colors.cyanAccent
                                          : Colors.white.withOpacity(0.7),
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      final newMode = !_isDragToThrowMode;
                                      setState(() {
                                        _isDragToThrowMode = newMode;
                                      });
                                      if (newMode) {
                                        _checkAndShowTutorial();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (currentKnife.ability == KnifeAbility.slowing ||
                              _slowMoCount > 0)
                            Positioned(
                              bottom: 80,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.hourglass_empty,
                                      color: !_slowingAbilityUsedThisLevel &&
                                              _slowMoCount == 0
                                          ? Colors.grey
                                          : Colors.cyanAccent,
                                      size: 35),
                                  onPressed: _useSlowingAbility,
                                ),
                              ),
                            ),
                          if (!gameOver && !levelComplete)
                            _buildThrowableKnife(
                                logPosition, knifeStartPosition, logWidgetSize),
                          if (_isExploding)
                            CustomPaint(
                              painter: ExplosionPainter(
                                animation: _explosionController,
                                center: _explosionCenter,
                              ),
                            ),
                          if (gameOver)
                            GameOverOverlay(
                                level: level,
                                onRestart: _restartGame,
                                highScore: highScore),
                          if (levelComplete && !gameOver)
                            LevelCompleteOverlay(level: level),
                          if (_isPaused)
                            PauseMenuOverlay(
                              onResume: _togglePause,
                              onQuit: () {
                                Navigator.of(context).pop();
                              },
                              isSoundOn: _isSoundOn,
                              onSoundToggle: (value) {
                                setState(() {
                                  _isSoundOn = value;
                                });
                              },
                              onAchievements: _showAchievements,
                              onDailyBonus: _showDailyBonus,
                              canClaimDailyBonus: _canClaimDailyBonus,
                              onBonusCooldownTap: _showBonusCooldownMessage,
                            ),
                          if (_showDragTutorial)
                            GestureDetector(
                              onTap: () {
                                if (mounted) {
                                  setState(() {
                                    _showDragTutorial = false;
                                  });
                                  _tutorialAnimationController.stop();
                                }
                              },
                              child: Container(
                                color: Colors.black.withOpacity(0.7),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SlideTransition(
                                        position: _tutorialHandAnimation,
                                        child: Transform.rotate(
                                          angle: -pi / 6,
                                          child: const Icon(
                                            Icons.touch_app,
                                            color: Colors.white,
                                            size: 80,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "DRAG DOWN & RELEASE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (_showBossTutorial)
                            BossTutorialOverlay(
                              onStart: () {
                                setState(() {
                                  _showBossTutorial = false;
                                });
                                _rotationController.repeat();
                                _resetInactivityTimer();
                              },
                            ),
                          if (_showSpinWheel)
                            SpinTheWheelOverlay(onReward: _onRewardClaimed),
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

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double life;
  Size size;
  double rotation;
  double rotationSpeed;

  Particle(
      {required this.position,
      required this.velocity,
      required this.color,
      required this.life,
      required this.size,
      required this.rotation,
      required this.rotationSpeed});

  void update(double dt) {
    velocity += Offset(0, 900 * dt);
    position += velocity * dt;
    rotation += rotationSpeed * dt;
    life -= dt * 1.5;
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
        canvas.save();
        canvas.translate(p.position.dx, p.position.dy);
        canvas.rotate(p.rotation);
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size.width, height: p.size.height),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
