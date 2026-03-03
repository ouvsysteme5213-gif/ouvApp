import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:api_clients/api_clients.dart';
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:models/models.dart';
import 'package:ouv_dooks/generated/assets.dart';
import 'package:ouv_dooks/vieux/segnupLogin/ouv_auth_base.dart';
import 'package:ouv_dooks/vieux/segnupLogin/ouv_emails.dart';
import 'package:provider/provider.dart';
import 'package:shared_utils/shared_utils.dart';

class OuvLogin extends StatefulWidget {
  final OuvApp app;

  const OuvLogin({
    super.key,
    required this.app,
  });

  @override
  State<OuvLogin> createState() => OuvLoginState();
}

class OuvLoginState extends OuvAuthBase<OuvLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = context.read<AuthController>();

      final user = await authController.login(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
        app: widget.app,
      );


      if (!mounted) return;

      if (user != null) {
        // Envoyer l'alerte de connexion
        final UserEmailService emailService = UserEmailService();

        final result = await emailService.sendLoginAlertEmail(
          context: context,
          email: _usernameController.text.trim(),
          userId: user.uid,
          deviceInfo: '',
          location: '',
          additionalData: {
            'login_method': 'email_password',
            'is_new_device': true,
          },
        );

        if (result.success) {
          log('Alerte de connexion envoyée à ${result.data?['email']}');
        } else {
          log('Échec envoi alerte: ${result.message}');
          // Ne pas bloquer l'utilisateur pour ça, juste logger l'erreur
        }
        _onLoginSuccess(user);
      } else {
        _showError("Email ou mot de passe incorrect");
      }
    } on AuthException catch (e) {
      _handleLoginError(e);
    } on SocketException {
      _showError("Pas de connexion internet");
    } on TimeoutException {
      _showError("Connexion trop lente, réessayez");
    } catch (e) {
      _showError("Erreur inattendue, veuillez réessayer");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Exemple d'appel après une connexion réussie
  void _handleSuccessfulLogin(UserModel user) async {
    // Envoyer l'alerte de connexion

  }

  void _handleLoginError(AuthException error) {
    String message;

    switch (error.code) {
      case 'invalid-credential':
        message = 'Email ou mot de passe incorrect';
        break;
      case 'user-not-found':
        message = 'Aucun compte associé à cet email';
        break;
      case 'wrong-password':
        message = 'Mot de passe incorrect';
        break;
      case 'invalid-email':
        message = 'Adresse email invalide';
        break;
      case 'user-disabled':
        message = 'Ce compte a été désactivé';
        break;
      case 'too-many-requests':
        message = 'Trop de tentatives. Réessayez plus tard';
        break;
      case 'network-request-failed':
        message = 'Problème de connexion réseau';
        break;
      default:
        message = error.message.isNotEmpty
            ? error.message
            : 'Erreur d’authentification';
    }

    _showError(message);
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() => _errorMessage = message);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }



  void _onLoginSuccess(UserModel user) {
    if (!mounted) return;
    AuthLogger.i('Connexion réussie pour ${user.email}');
    _handleSuccessfulLogin(user);
    // Fermer d'abord le SnackBar actuel s'il y en a un
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Afficher le message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Connexion réussie avec succès !',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Attendre un peu avant la navigation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        // Méthode 1: Vider complètement la pile et aller vers home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false,
        );

        // Méthode 2: Alternative - Replacer la route home
        // Navigator.of(context, rootNavigator: true).pushReplacementNamed('/home');
      }
    });
  }

  void _handleSignupTap() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  void _handleForgotPasswordTap() {
    // Utiliser push pour l'email (pas de replacement)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OuvEmails(
          app: widget.app,
        ),
      ),
    );
  }

  // Méthode pour vérifier si l'utilisateur est déjà connecté
  Future<void> _checkIfAlreadyLoggedIn() async {
    final authController = context.read<AuthController>();

    // Attendre un peu que le contrôleur soit initialisé
    await Future.delayed(const Duration(milliseconds: 100));

    if (authController.isAuthenticated && mounted) {
      AuthLogger.i('Utilisateur déjà connecté, redirection vers /home');

      // Petit délai pour laisser l'interface se charger
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
                (route) => false,
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Vérifier si l'utilisateur est déjà connecté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAlreadyLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OuvLoginAuth(
          controllerUsername: _usernameController,
          controllerPassword: _passwordController,
          formKey: _formKey,
          logoImage: widget.app.logoPath,
          appName: widget.app.displayName,
          isLoading: _isLoading,
          onTapLogin: _handleLogin,
          onTapSignup: _handleSignupTap,
          onTapForgotPassword: _handleForgotPasswordTap,
          googleImage: Assets.socialGoogle,
          facebookImage: Assets.socialFacebook,
          isSocialLoginEnabled: true,
          isGoogleLoginEnabled: true,
          isfacebookLoginEnabled: true,
        ),
      ),
    );
  }

  @override
  void disposeControllers() {
    // Les contrôleurs sont déjà disposés dans la méthode dispose()
  }
}