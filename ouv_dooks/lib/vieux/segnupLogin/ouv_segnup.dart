import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:ouv_dooks/vieux/segnupLogin/ouv_auth_base.dart';
import 'package:provider/provider.dart';
import 'package:shared_utils/shared_utils.dart';

class OuvSegnup extends StatefulWidget {
  final OuvApp app;

  const OuvSegnup({
    super.key,
    required this.app,
  });

  @override
  State<OuvSegnup> createState() => _OuvSegnupState();
}

class _OuvSegnupState extends OuvAuthBase<OuvSegnup> {
  // Contrôleurs pour les champs du formulaire
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Clé pour le formulaire
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // État
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFormatting = false;

  // Centres d'intérêt disponibles
  final List<String> _availableInterests = [
    'Littérature',
    'Poésie',
    'Roman',
    'Philosophie',
    'Histoire',
    'Science',
    'Art',
    'Musique',
    'Cinéma',
    'Théâtre',
    'Sport',
    'Voyage',
    'Cuisine',
    'Technologie',
    'Éducation',
  ];

  // Intérêts sélectionnés
  List<String> _selectedInterests = [];

  // ===== MÉTHODES D'AUTHENTIFICATION =====

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = context.read<AuthController>();

      // Nettoyage du numéro
      final cleanPhone = _phoneController.text.replaceAll(' ', '');

      // Validation de sécurité
      // 2. Double vérification du téléphone
      if (cleanPhone.length < 9) {
        return showErrorDialog(
          context: context,
          title: 'Numéro de téléphone invalide'
        );
      }

      // Effectuer l'inscription
      final user = await authController.register(
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: cleanPhone,
        password: _passwordController.text,
        interests: _selectedInterests,
        app: widget.app,
      );

      if (user != null) {
        _onRegistrationSuccess(user);
      } else {
        return showErrorDialog(
          context: context,
          title: 'Erreur lors de l\'inscription',
        );
      }

    } catch (e) {
      // Ici on utilise votre méthode de gestion d'erreur existante
      _handleRegistrationError(e);

      // Afficher un SnackBar avec le vrai message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// -----------------------
  void _onSignup() async {
    if (!_formKey.currentState!.validate()) return;

    // On vérifie que le nom complet a une longueur minimale pour les suggestions
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      setState(() => _errorMessage = "Veuillez entrer votre nom complet");
      print('Nom complet vide');
      return;
    }

    try {
      setState(() => _isLoading = true);
      print('Nom complet: $fullName');

      await showUsernameDialogWithSuggestions(
        context: context,
        controller: _usernameController,
        onValidation: () {
          // Fermer le dialogue avant de lancer l'inscription
          Navigator.pop(context);
          _handleSignup();
        },
        fullName: fullName,
        interests: _selectedInterests,
      );
    } on AuthException catch (e) {
      // Afficher un message d'erreur spécifique
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getUserFriendlyError(e)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Erreur générique
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  String _getUserFriendlyError(AuthException e) {
    switch (e.code) {
      case 'EMAIL_ALREADY_IN_USE':
        return 'This email is already registered. Please use a different email or login.';
      case 'USERNAME_TAKEN':
        return 'This username is already taken. Please choose another one.';
      case 'INVALID_EMAIL':
        return 'Please enter a valid email address.';
      case 'WEAK_PASSWORD':
        return 'Password must be at least 8 characters long.';
      case 'NO_INTERESTS':
        return 'Please select at least one interest.';
      default:
        return e.message;
    }
  }

  void _onRegistrationSuccess(UserModel user) {
    AuthLogger.i('Inscription réussie pour ${user.email}');

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Compte créé avec succès ! Vérifiez votre email.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Naviguer vers la page de vérification ou l'accueil
    // Exemple: Navigator.pushReplacementNamed(context, '/email-verification');
    Navigator.pushReplacementNamed(context, '/');
  }

  void _handleRegistrationError(Object error) {
    String errorMessage = 'Erreur lors de l\'inscription';

    if (error is AuthException) {
      errorMessage = error.message;

      // Gestion spécifique des erreurs
      switch (error.code) {
        case 'EMAIL_ALREADY_IN_USE':
          errorMessage = 'Cet email est déjà utilisé.';
          break;
        case 'INVALID_EMAIL':
          errorMessage = 'Format d\'email invalide.';
          break;
        case 'WEAK_PASSWORD':
          errorMessage = 'Le mot de passe est trop faible.';
          break;
        case 'EMAIL_NOT_ALLOWED':
          errorMessage = 'Cette adresse email n\'est pas autorisée.';
          break;
        case 'INVALID_PHONE':
          errorMessage = 'Numéro de téléphone invalide.';
          break;
      }
    }

    setState(() {
      _errorMessage = errorMessage;
    });

    AuthLogger.e('Erreur d\'inscription: $error');
  }

  void _handleLoginTap() {
    // Naviguer vers l'écran de connexion
    Navigator.pushReplacementNamed(context, '/login');
  }

  // 1. Ajoutez cette variable en haut de votre classe _OuvSegnupState

  // 2. Modifiez la méthode _handlePhoneChanged comme ceci :
  void _handlePhoneChanged(String phone) {
    if (_isFormatting) return; // Sortir si on est déjà en train de formater

    final formattedPhone = _formatPhoneNumber(phone);

    if (formattedPhone != phone) {
      _isFormatting = true; // Activer le verrou
      _phoneController.text = formattedPhone;
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: formattedPhone.length),
      );
      _isFormatting = false; // Libérer le verrou
    }
  }

  String _formatPhoneNumber(String phone) {
    // Enlever tous les caractères non numériques
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.isEmpty) return '';

    // Format: +224 612 34 56 78
    if (digits.startsWith('224')) {
      final rest = digits.substring(3);
      if (rest.length <= 2) return '+224 $rest';
      if (rest.length <= 4) return '+224 ${rest.substring(0, 2)} ${rest.substring(2)}';
      if (rest.length <= 6) return '+224 ${rest.substring(0, 2)} ${rest.substring(2, 4)} ${rest.substring(4)}';
      return '+224 ${rest.substring(0, 2)} ${rest.substring(2, 4)} ${rest.substring(4, 6)} ${rest.substring(6)}';
    }

    // Format local simple
    if (digits.length <= 2) return digits;
    if (digits.length <= 4) return '${digits.substring(0, 2)} ${digits.substring(2)}';
    if (digits.length <= 6) return '${digits.substring(0, 2)} ${digits.substring(2, 4)} ${digits.substring(4)}';
    return '${digits.substring(0, 2)} ${digits.substring(2, 4)} ${digits.substring(4, 6)} ${digits.substring(6)}';
  }

  void _handleInterestsChanged(List<String> interests) {
    setState(() {
      _selectedInterests = interests;
    });
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Politique de confidentialité'),
        content: const SingleChildScrollView(
          child: Text(
            'Cette application respecte votre vie privée. Nous collectons uniquement les informations nécessaires au fonctionnement du service et ne partageons jamais vos données avec des tiers sans votre consentement.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'En utilisant cette application, vous acceptez :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTermItem('Respecter les autres utilisateurs'),
              _buildTermItem('Ne pas publier de contenu inapproprié'),
              _buildTermItem('Protéger vos identifiants de connexion'),
              _buildTermItem('Utiliser l\'application à des fins légales'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Inscription - ${widget.app.displayName}'),
      ),
      body: OuvSignupAuth(
        formKey: _formKey,
        controllerUsername: _fullNameController,
        controllerEmail: _emailController,
        controllerPhone: _phoneController,
        controllerPassword: _passwordController,
        controllerConfirmPassword: _confirmPasswordController,
        logoImage: widget.app.logoPath,
        appName: widget.app.displayName,
        centerInterests: _availableInterests,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        // Callbacks
        onTapSignup: _handleSignup,
        onTapLogin: _handleLoginTap,
        onInterestsChanged: _handleInterestsChanged,
        onPhoneChanged: _handlePhoneChanged,
        onPrivacyPolicyTap: _showPrivacyPolicy,
        onTermsOfServiceTap: _showTermsOfService,
      ),
    );
  }

  @override
  void disposeControllers() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }
}