import 'dart:async';
import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final OuvApp myApp = OuvApp.dooks;
  late AnimationController _animationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Color?> _colorAnimation;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  bool _checkingConnection = true;
  double _progressValue = 0.0;
  Timer? _progressTimer;
  Timer? _quoteTimer;

  final List<String> _inspirationalQuotes = [
    "Les livres sont des jardins portatifs que l'on peut emporter partout",
    "Une citation peut illuminer votre journée entière, partagez-la",
    "Chaque histoire de vie est un livre qui mérite d'être lu",
    "Dans chaque livre se cache une nouvelle aventure à découvrir",
    "La sagesse n'attend que d'être partagée entre les pages",
    "Votre expérience peut inspirer des générations à venir",
    "Lisez pour grandir, partagez pour inspirer",
    "La connaissance est la seule richesse qui augmente quand on la partage",
    "Un livre ouvert est un esprit qui s'élargit",
    "Partagez vos lectures, enrichissez votre communauté"
  ];

  String _currentQuote = "";
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentQuote = _inspirationalQuotes[0];

    _initAnimations();
    _checkConnectivity();
    _startQuoteRotation();
    _simulateProgress();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: myApp.primaryColor,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkConnectivity() async {
    try {
      // Initial check
      var connectivity = Connectivity();
      _connectionStatus = await connectivity.checkConnectivity();

      // Listen for changes
      _connectivitySubscription = connectivity.onConnectivityChanged.listen(
            (List<ConnectivityResult> result) {
          setState(() {
            _connectionStatus = result;
          });
        },
      );
    } catch (e) {
      // En cas d'erreur avec connectivity_plus, on continue sans cette fonctionnalité
      print('Erreur connectivity_plus: $e');
      _connectionStatus = [ConnectivityResult.other];
    }

    // Simuler un délai pour la vérification
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _checkingConnection = false;
      _progressValue = 0.3;
    });

    // Continuer vers l'app
    _continueToApp();
  }

  void _simulateProgress() {
    const totalDuration = Duration(seconds: 8);
    const interval = Duration(milliseconds: 100);
    final steps = totalDuration.inMilliseconds ~/ interval.inMilliseconds;
    final increment = 1.0 / steps;

    _progressTimer = Timer.periodic(interval, (timer) {
      if (_progressValue < 0.95) {
        setState(() {
          _progressValue += increment;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startQuoteRotation() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _inspirationalQuotes.length;
          _currentQuote = _inspirationalQuotes[_quoteIndex];
        });
      }
    });
  }

  Future<void> _continueToApp() async {
    // Attendre que la barre de progression atteigne au moins 80%
    await Future.delayed(const Duration(milliseconds: 500));

    while (_progressValue < 0.8) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Délai supplémentaire
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Animation de sortie
    await _animationController.reverse();

    if (!mounted) return;

    // Nettoyer les timers
    _progressTimer?.cancel();
    _quoteTimer?.cancel();
    _connectivitySubscription.cancel();

    // Naviguer
    final authController = context.read<AuthController>();
    final user = authController.isFirebaseAuthenticated;
    print('User authenticated: $user');

    if (user) {
      try {
        // Optionnel mais recommandé : Vérifier si le profil utilisateur existe vraiment
        // avant d'aller sur le Home.
        final profile = await authController.currentUserF;

        if (profile != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Si Auth est ok mais profil inexistant, on force la déconnexion ou le login
          await authController.logout(context);
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        print('Erreur lors de la récupération du profil: $e');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressTimer?.cancel();
    _quoteTimer?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  String _getConnectionStatusText() {
    if (_connectionStatus.isEmpty) {
      return 'Aucune connexion';
    }

    // Vérifier les différents types de connexion
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return 'Connecté au Wi-Fi';
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return 'Connecté au réseau mobile';
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return 'Connecté via Ethernet';
    } else if (_connectionStatus.contains(ConnectivityResult.vpn)) {
      return 'Connecté via VPN';
    } else if (_connectionStatus.contains(ConnectivityResult.bluetooth)) {
      return 'Connecté via Bluetooth';
    } else if (_connectionStatus.contains(ConnectivityResult.other)) {
      return 'Connecté';
    } else {
      return 'Aucune connexion internet';
    }
  }

  IconData _getConnectionStatusIcon() {
    if (_connectionStatus.isEmpty) {
      return Icons.wifi_off;
    }

    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return Icons.wifi;
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return Icons.network_cell;
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return Icons.lan;
    } else if (_connectionStatus.contains(ConnectivityResult.vpn)) {
      return Icons.vpn_lock;
    } else if (_connectionStatus.contains(ConnectivityResult.bluetooth)) {
      return Icons.bluetooth;
    } else if (_connectionStatus.contains(ConnectivityResult.other)) {
      return Icons.network_check;
    } else {
      return Icons.wifi_off;
    }
  }

  Color _getConnectionStatusColor() {
    if (_connectionStatus.isEmpty ||
        _connectionStatus.contains(ConnectivityResult.none)) {
      return Colors.orange; // Orange pour "pas de connexion" au lieu de rouge
    } else {
      return Colors.green; // Vert pour toute autre connexion
    }
  }

  bool _hasConnection() {
    return _connectionStatus.isNotEmpty &&
        !_connectionStatus.contains(ConnectivityResult.none);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = myApp.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white,
                primaryColor.withOpacity(0.03),
                primaryColor.withOpacity(0.06),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo avec animation
                  AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + (_logoAnimation.value * 0.2),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                primaryColor.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.15),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            myApp.logoPath,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Nom de l'app
                  AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 25 * (1 - _textAnimation.value)),
                        child: Opacity(
                          opacity: _textAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                myApp.displayName,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: primaryColor.withOpacity(0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                myApp.slogan,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // État de la connexion
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _checkingConnection
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Vérification de la connexion...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                        : Container(
                      key: ValueKey(_hasConnection()),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getConnectionStatusColor()
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getConnectionStatusColor()
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getConnectionStatusIcon(),
                            size: 18,
                            color: _getConnectionStatusColor(),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getConnectionStatusText(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _getConnectionStatusColor(),
                                ),
                              ),
                              if (!_hasConnection())
                                Text(
                                  'Fonctionnalités limitées',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Citation inspirante
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey(_currentQuote),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            color: primaryColor.withOpacity(0.4),
                            size: 24,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _currentQuote,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 10),
                          Icon(
                            Icons.format_quote_rounded,
                            color: primaryColor.withOpacity(0.4),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Progress indicator
                  Column(
                    children: [
                      Container(
                        width: 200,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _progressAnimation,
                          ]),
                          builder: (context, child) {
                            return Stack(
                              children: [
                                // Barre de fond
                                Container(
                                  width: 200,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                // Barre de progression
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 200 * _progressValue,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor.withOpacity(0.8),
                                        primaryColor,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _progressAnimation,
                        ]),
                        builder: (context, child) {
                          return Text(
                            _hasConnection()
                                ? 'Chargement des bibliothèques... ${(_progressValue * 100).toInt()}%'
                                : 'Mode hors ligne... ${(_progressValue * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Informations de version
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 15 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Version ${myApp.minVersion}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.copyright_outlined,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Partagez vos citations • Inspirez la communauté • Grandissez ensemble',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
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
    );
  }
}