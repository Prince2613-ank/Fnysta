// lib/features/game/pages/slot_machine_screen.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fynsta/features/game/widgets/tutorial_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SlotMachineScreen extends StatefulWidget {
  const SlotMachineScreen({super.key});

  @override
  State<SlotMachineScreen> createState() => _SlotMachineScreenState();
}

class _SlotMachineScreenState extends State<SlotMachineScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _reelControllers;
  late List<Animation<double>> _reelAnimations;

  late AnimationController _spinButtonPulseController;
  late AnimationController _glossController;
  late AnimationController _backgroundController;
  late AnimationController _giftGlowController;

  final List<String> _finalItems = ['', '', ''];
  final Random _random = Random();

  int _coins = 100;
  int _highScore = 100;
  bool _isSpinning = false;
  int _selectedBet = 10; // Default bet is 10
  bool _showTutorial = false;

  final List<bool> _isAnticipationReel = [false, false, false];

  DateTime? _lastBonusClaimTime;
  bool _canClaimBonus = false;

  final List<String> _assetPaths = [
    'assets/bell.png',
    'assets/cherry.png',
    'assets/grapes.png',
    'assets/7.png',
    'assets/strawberry.png',
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _winAudioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _checkIfFirstTime();
    _loadBonusState();

    _backgroundController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(reverse: true);

    _giftGlowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);

    _reelControllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1500 + (index * 200)),
      )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() => _isAnticipationReel[index] = false);
            if (_reelControllers
                .every((c) => c.status == AnimationStatus.completed)) {
              _checkWin();
            }
          }
        });
    });

    _reelAnimations = _reelControllers.map((controller) {
      return Tween<double>(begin: 0, end: 20.0 + _random.nextDouble() * 10)
          .animate(CurvedAnimation(
              parent: controller, curve: Curves.elasticOut.flipped));
    }).toList();

    _spinButtonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _glossController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    for (var controller in _reelControllers) {
      controller.dispose();
    }
    _spinButtonPulseController.dispose();
    _glossController.dispose();
    _backgroundController.dispose();
    _giftGlowController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _winAudioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;
    if (!hasSeenTutorial) {
      setState(() {
        _showTutorial = true;
      });
    }
  }

  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenTutorial', true);
    setState(() {
      _showTutorial = false;
    });
  }

  Future<void> _loadBonusState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaimString = prefs.getString('lastBonusClaimTime');
    if (lastClaimString != null) {
      _lastBonusClaimTime = DateTime.parse(lastClaimString);
      if (DateTime.now().difference(_lastBonusClaimTime!).inHours >= 24) {
        setState(() => _canClaimBonus = true);
      }
    } else {
      setState(() => _canClaimBonus = true);
    }
  }

  void _spin() {
    // --- NEW LOGIC ---
    // If the player can't afford the selected bet, automatically revert to the default 10 coin bet.
    if (_coins < _selectedBet) {
      setState(() {
        _selectedBet = 10;
      });
    }
    // --- END NEW LOGIC ---

    if (_isSpinning || _coins < _selectedBet) return;
    _audioPlayer.setVolume(1.0);
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(AssetSource('spineffect.mp3'));

    setState(() {
      _isSpinning = true;
      _coins -= _selectedBet;
    });

    for (int i = 0; i < 3; i++) {
      _finalItems[i] = _assetPaths[_random.nextInt(_assetPaths.length)];
    }

    bool isAnticipation = _finalItems[0] == _finalItems[1];

    for (int i = 0; i < 3; i++) {
      if (i == 2 && isAnticipation) {
        _reelControllers[i].duration = const Duration(milliseconds: 3500);
        setState(() => _isAnticipationReel[i] = true);
      } else {
        _reelControllers[i].duration = Duration(milliseconds: 1500 + (i * 200));
      }
      _reelControllers[i].forward(from: 0);
    }
  }

  void _checkWin() {
    _audioPlayer.stop();
    setState(() {
      _isSpinning = false;
    });

    Map<String, int> counts = {};
    for (String item in _finalItems) {
      counts[item] = (counts[item] ?? 0) + 1;
    }

    // Jackpot: 3 of a kind
    if (counts.values.any((count) => count == 3)) {
      _winAudioPlayer.setVolume(1.0);
      _winAudioPlayer.play(AssetSource('yayy.mp3'));
      int winnings = 100;
      setState(() {
        _coins += winnings;
        if (_coins > _highScore) _highScore = _coins;
      });
      _showWinOverlay(winnings, isJackpot: true);
      return;
    }

    // Mini-Win: 2 of a kind
    if (counts.values.any((count) => count == 2)) {
      _winAudioPlayer.setVolume(1.0);
      _winAudioPlayer.play(AssetSource('yayy.mp3'));
      int scoreIncrease = 3 * _selectedBet;
      setState(() {
        _highScore += scoreIncrease;
      });
      _showWinOverlay(scoreIncrease, isScoreWin: true);
    }
  }

  void _showWinOverlay(int amountWon,
      {bool isJackpot = false, bool isScoreWin = false}) {
    final screenSize = MediaQuery.of(context).size;
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return WinOverlay(
        screenSize: screenSize,
        amountWon: amountWon,
        isJackpot: isJackpot,
        isScoreWin: isScoreWin,
        onClose: () {
          overlayEntry?.remove();
        },
      );
    });
    Overlay.of(context).insert(overlayEntry);
  }

  Future<void> _claimDailyBonus() async {
    if (_canClaimBonus) {
      setState(() {
        _coins += 50;
        _canClaimBonus = false;
        _lastBonusClaimTime = DateTime.now();
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'lastBonusClaimTime', _lastBonusClaimTime!.toIso8601String());

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Daily Bonus! +50 coins!'),
          backgroundColor: Colors.green));
    } else {
      if (_lastBonusClaimTime == null) return;
      final nextBonusTime = _lastBonusClaimTime!.add(const Duration(hours: 24));
      final remaining = nextBonusTime.difference(DateTime.now());
      final formattedTime =
          '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Next bonus available in $formattedTime'),
          backgroundColor: Colors.redAccent));
    }
  }

  Widget _buildReel(int index) {
    return AnimatedBuilder(
      animation: Listenable.merge([_reelAnimations[index], _glossController]),
      builder: (context, child) {
        final reelValue = _reelAnimations[index].value;
        final glossValue = _glossController.value;
        final isSpinningFast = _reelControllers[index].isAnimating;
        final itemIndex = (reelValue.floor() % _assetPaths.length);
        final isCompleted =
            _reelControllers[index].status == AnimationStatus.completed;
        final currentAsset =
            isCompleted ? _finalItems[index] : _assetPaths[itemIndex];

        final glowColor =
            Colors.yellow.withOpacity(_isAnticipationReel[index] ? 0.8 : 0.0);

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(0.05),
          alignment: FractionalOffset.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: glowColor, blurRadius: 20, spreadRadius: 5),
              ],
            ),
            child: PhysicalModel(
              color: Colors.transparent,
              elevation: 12,
              shape: BoxShape.circle,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.blue[800]!, const Color(0xFF00223E)],
                  ),
                  border: Border.all(
                      color: Colors.cyanAccent.withOpacity(0.8), width: 4),
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: isSpinningFast && !isCompleted ? 3.0 : 0.0,
                            sigmaY: isSpinningFast && !isCompleted ? 3.0 : 0.0,
                          ),
                          child: Image.asset(currentAsset,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error, color: Colors.white)),
                        ),
                      ),
                      Transform.rotate(
                        angle: glossValue * 2 * pi,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.2),
                              ],
                              stops: const [0.0, 0.25, 0.75, 1.0],
                              tileMode: TileMode.clamp,
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
      },
    );
  }

  Widget _buildBetSelector(int amount) {
    bool isSelected = _selectedBet == amount;
    return GestureDetector(
      onTap: () {
        if (!_isSpinning) {
          setState(() {
            _selectedBet = amount;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyanAccent : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyanAccent, width: 2),
        ),
        child: Text(
          amount.toString(),
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slot Machine',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              setState(() {
                _showTutorial = true;
              });
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [Color(0xFF00223E), Color(0xFF0A4859)],
                    begin: AlignmentTween(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)
                        .lerp(_backgroundController.value),
                    end: AlignmentTween(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft)
                        .lerp(_backgroundController.value),
                  ),
                ),
                child: child,
              );
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreDisplay('YOUR COINS', _coins),
                        _buildScoreDisplay('HIGH SCORE', _highScore),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildReel(0),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildReel(1),
                            const SizedBox(width: 15),
                            _buildReel(2),
                          ],
                        ),
                      ],
                    ),
                    ScaleTransition(
                      scale: _spinButtonPulseController,
                      child: GestureDetector(
                        onTap: _spin,
                        onTapDown: (_) => _spinButtonPulseController.reverse(
                            from: _spinButtonPulseController.upperBound),
                        onTapUp: (_) => _spinButtonPulseController.forward(
                            from: _spinButtonPulseController.lowerBound),
                        onTapCancel: () => _spinButtonPulseController.forward(
                            from: _spinButtonPulseController.lowerBound),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: _isSpinning || _coins < _selectedBet
                                  ? [Colors.grey[700]!, Colors.grey[900]!]
                                  : [Colors.lightBlue[400]!, Colors.blue[800]!],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.lightBlue.withOpacity(0.5),
                                blurRadius: 25,
                                spreadRadius: 3,
                              )
                            ],
                          ),
                          child: const Center(
                            child: Text('SPIN',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5)),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBetSelector(30),
                        GestureDetector(
                          onTap: _claimDailyBonus,
                          child: AnimatedBuilder(
                            animation: _giftGlowController,
                            builder: (context, child) {
                              final glowValue = _canClaimBonus
                                  ? _giftGlowController.value
                                  : 0.0;
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.yellow
                                          .withOpacity(0.7 * glowValue),
                                      blurRadius: 15 * glowValue,
                                      spreadRadius: 3 * glowValue,
                                    )
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: Icon(Icons.card_giftcard,
                                color: _canClaimBonus
                                    ? Colors.yellow
                                    : Colors.cyanAccent,
                                size: 40),
                          ),
                        ),
                        _buildBetSelector(50),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showTutorial) TutorialOverlay(onDismiss: _dismissTutorial),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(String title, int score) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, color: Colors.white70, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(score.toString(),
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }
}

class WinOverlay extends StatefulWidget {
  final int amountWon;
  final bool isJackpot;
  final VoidCallback onClose;
  final Size screenSize;
  final bool isScoreWin;

  const WinOverlay(
      {super.key,
      required this.amountWon,
      required this.isJackpot,
      required this.onClose,
      required this.screenSize,
      this.isScoreWin = false});

  @override
  _WinOverlayState createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _particleController;
  List<_ConfettiParticle> particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);
    _scaleController.forward();

    if (widget.isJackpot) {
      _particleController = AnimationController(
          vsync: this, duration: const Duration(seconds: 2));
      for (int i = 0; i < 50; i++) {
        particles.add(_ConfettiParticle(
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
          startPos: Offset(_random.nextDouble() * widget.screenSize.width, -20),
        ));
      }
      _particleController.forward();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _scaleController.reverse().then((_) => widget.onClose());
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    if (widget.isJackpot) _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String rewardType = widget.isScoreWin ? 'SCORE' : 'COINS';

    return Material(
      color: Colors.black.withOpacity(0.7),
      child: GestureDetector(
        onTap: () => _scaleController.reverse().then((_) => widget.onClose()),
        child: Stack(
          children: [
            if (widget.isJackpot)
              AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _ConfettiPainter(particles, widget.screenSize),
                    );
                  }),
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.isJackpot ? 'JACKPOT!' : 'YOU WIN!',
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyanAccent,
                            shadows: [
                              Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ])),
                    const SizedBox(height: 10),
                    Text('+${widget.amountWon} $rewardType',
                        style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final Offset startPos;
  double x, y, vx, vy;
  double rotation;
  double rotationSpeed;
  _ConfettiParticle({required this.color, required this.startPos})
      : x = startPos.dx,
        y = startPos.dy,
        vx = (Random().nextDouble() - 0.5) * 100,
        vy = Random().nextDouble() * 150 + 50,
        rotation = Random().nextDouble() * 2 * pi,
        rotationSpeed = (Random().nextDouble() - 0.5) * 4;

  void update() {
    vy += 200 * (1 / 60);
    x += vx * (1 / 60);
    y += vy * (1 / 60);
    rotation += rotationSpeed * (1 / 60);
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final Size canvasSize;

  _ConfettiPainter(this.particles, this.canvasSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      p.update();
      if (p.y > canvasSize.height) continue;

      paint.color = p.color;
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.drawRect(Rect.fromLTWH(-5, -5, 10, 10), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
