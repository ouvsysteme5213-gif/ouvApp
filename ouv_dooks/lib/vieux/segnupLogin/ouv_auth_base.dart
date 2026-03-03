// ============================================
// lib/screens/auth/base/ouv_auth_base.dart
// Base class pour la gestion commune de l'auth
// ============================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_utils/shared_utils.dart';

/// Base class pour les écrans d'authentification
/// Fournit des méthodes communes pour la gestion des erreurs et du logging
abstract class OuvAuthBase<T extends StatefulWidget> extends State<T> {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  /// À implémenter pour disposer les contrôleurs
  void disposeControllers();

  /// Définir l'état de chargement
  void setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  /// Afficher une erreur
  void showError(String message) {
    if (mounted) {
      setState(() => _errorMessage = message);
    }
  }

  /// Effacer les erreurs
  void clearError() {
    if (mounted) {
      setState(() => _errorMessage = null);
    }
  }

  /// Afficher un SnackBar de succès
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Afficher un SnackBar d'erreur
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Traiter les erreurs d'authentification
  String handleAuthError(Object error) {
    String errorMessage = 'Une erreur est survenue';

    if (error is AuthException) {
      errorMessage = _mapAuthExceptionToMessage("${error.code}", error.message);
    } else if (error is FormatException) {
      errorMessage = 'Format invalide';
    } else if (error is TimeoutException) {
      errorMessage = 'Délai d\'attente dépassé. Veuillez réessayer.';
    }

    AuthLogger.e('Erreur auth: ${error.toString()}');
    return errorMessage;
  }

  /// Mapper les codes d'erreur d'authentification aux messages
  String _mapAuthExceptionToMessage(String code, String defaultMessage) {
    const errorMap = {
      'user-not-found': 'Utilisateur non trouvé',
      'wrong-password': 'Mot de passe incorrect',
      'user-disabled': 'Compte désactivé',
      'too-many-requests': 'Trop de tentatives. Réessayez plus tard.',
      'USER_NOT_FOUND': 'Aucun compte trouvé avec cet email',
      'INVALID_EMAIL': 'Adresse email invalide',
      'EMAIL_ALREADY_IN_USE': 'Cet email est déjà utilisé',
      'WEAK_PASSWORD': 'Le mot de passe est trop faible',
      'INVALID_CODE': 'Code de vérification invalide',
      'EXPIRED_CODE': 'Le code a expiré. Demandez un nouveau lien.',
      'INVALID_PHONE': 'Numéro de téléphone invalide',
    };

    return errorMap[code] ?? defaultMessage;
  }

  /// Naviguer de manière sécurisée
  void safeNavigate(String routeName, {Object? arguments}) {
    if (mounted) {
      Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
    }
  }

  void safeNavigatePushName(String routeName) {
    if (mounted) {
      Navigator.pushNamed(context, routeName);
    }
  }



  /// Naviguer avec retour possible
  void safeNavigatePush(Widget page) {
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  /// Retour à l'écran précédent
  void safeNavigatePop() {
    if (mounted) {
      Navigator.pop(context);
    }
  }
}