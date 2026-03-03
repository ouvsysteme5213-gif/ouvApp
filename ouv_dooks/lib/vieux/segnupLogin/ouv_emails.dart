// ============================================
// lib/screens/auth/ouv_emails_screen.dart
// ============================================

import 'package:api_clients/api_clients.dart';
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:models/models.dart';
import 'package:ouv_dooks/vieux/segnupLogin/ouv_auth_base.dart';
import 'package:provider/provider.dart';
import 'package:shared_utils/shared_utils.dart';

class OuvEmails extends StatefulWidget {
  final OuvApp app;

  const OuvEmails({
    super.key,
    required this.app,
  });

  @override
  State<OuvEmails> createState() => OuvEmailsState();
}

class OuvEmailsState extends OuvAuthBase<OuvEmails> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late bool _emailSent;



  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _emailSent = false;
  }

  @override
  void disposeControllers() {
    _emailController.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    clearError();
    setLoading(true);

    try {
      final authRepository = context.read<AuthController>();

      await authRepository.requestPasswordReset(
        _emailController.text.trim(),
      );


      if (!mounted) return;

      _onEmailSentSuccess();
      AuthLogger.i('Lien de réinitialisation envoyé à ${_emailController.text}');

    } catch (e) {
      final errorMessage = handleAuthError(e);
      showError(context, errorMessage);
      showErrorSnackBar(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  void _onEmailSentSuccess() {
    setState(() => _emailSent = true);
    showSuccessSnackBar('Lien de réinitialisation envoyé!');
  }

  void _handleBackToLogin() => safeNavigatePop();

  void _handleOpenResetCodeScreen() {
    safeNavigate(
      '/reset-password',
      arguments: _emailController.text,
    );
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Email requis';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!)) {
      return 'Email invalide';
    }
    return null;
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.lock_reset_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mot de passe oublié?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Entrez votre email pour recevoir un lien de réinitialisation',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Error message
            if (errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Email field
            TextFormField(
              controller: _emailController,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
              decoration: InputDecoration(
                labelText: 'Adresse email',
                hintText: 'exemple@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 32),

            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSendResetLink,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.send_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Envoyer le lien', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Back button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isLoading ? null : _handleBackToLogin,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retour à la connexion', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_read_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              'Email envoyé!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nous avons envoyé un lien de réinitialisation à:',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _emailController.text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleBackToLogin,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Retour'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleOpenResetCodeScreen,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Continuer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : _handleBackToLogin,
        ),
      ),
      body: _emailSent ? _buildSuccessState() : _buildEmailForm(),
    );
  }
}