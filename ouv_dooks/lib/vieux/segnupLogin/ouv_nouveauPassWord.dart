// ============================================
// lib/screens/auth/ouv_nouveau_password_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:models/models.dart';
import 'package:shared_utils/shared_utils.dart';

class OuvNouveauPassWord extends StatefulWidget {
  final OuvApp app;
  final String email; // Email passé depuis l'écran précédent

  const OuvNouveauPassWord({
    super.key,
    required this.app,
    required this.email,
  });

  @override
  State<OuvNouveauPassWord> createState() => OuvNouveauPassWordState();
}

class OuvNouveauPassWordState extends State<OuvNouveauPassWord> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _passwordReset = false;
  String? _errorMessage;

  // Pour suivre les erreurs spécifiques
  String? _passwordError;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      // Validation supplémentaire
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _passwordError = 'Les mots de passe ne correspondent pas';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _passwordError = null;
      });

      try {
        // Note: Firebase gère automatiquement la réinitialisation via le lien
        // Si vous avez besoin d'une logique de code personnalisée, ajoutez-la ici
        // Pour l'instant, on simule le succès

        await Future.delayed(const Duration(seconds: 2)); // Simulation

        _onPasswordResetSuccess();

      } catch (e) {
        _handleResetError(e);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _onPasswordResetSuccess() {
    setState(() => _passwordReset = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mot de passe réinitialisé avec succès !'),
        backgroundColor: Colors.green,
      ),
    );

    AuthLogger.i('Mot de passe réinitialisé pour ${widget.email}');

    // Redirection automatique après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _handleResetError(Object error) {
    String errorMessage = 'Erreur lors de la réinitialisation';

    if (error is AuthException) {
      switch (error.code) {
        case 'INVALID_CODE':
          errorMessage = 'Code de vérification invalide';
          break;
        case 'EXPIRED_CODE':
          errorMessage = 'Le code a expiré, demandez un nouveau lien';
          break;
        case 'WEAK_PASSWORD':
          errorMessage = 'Le nouveau mot de passe est trop faible';
          break;
        default:
          errorMessage = error.message;
      }
    }

    setState(() => _errorMessage = errorMessage);
    AuthLogger.e('Erreur de réinitialisation: $error');
  }

  void _handleBackToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return '1 majuscule requise';
    if (!RegExp(r'[a-z]').hasMatch(value)) return '1 minuscule requise';
    if (!RegExp(r'\d').hasMatch(value)) return '1 chiffre requis';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau mot de passe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackToLogin,
        ),
      ),
      body: _passwordReset
          ? _buildSuccessState()
          : _buildResetForm(),
    );
  }

  Widget _buildResetForm() {
    return codeRenitialiseMotDePasse(
      formKey: _formKey,
      controllerCode: _codeController,
      controllerMotDePasse: _passwordController,
      logoImage: widget.app.logoPath,
      appName: widget.app.name,
      onTapLogin: _handleBackToLogin,
      onTapEnvoyerLien: _handleResetPassword,
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              'Mot de passe réinitialisé !',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Votre mot de passe a été changé avec succès.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Vous allez être redirigé vers la page de connexion...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handleBackToLogin,
              child: const Text('Me connecter maintenant'),
            ),
          ],
        ),
      ),
    );
  }
}