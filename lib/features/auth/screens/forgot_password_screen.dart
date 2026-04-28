// lib/features/auth/screens/forgot_password_screen.dart
//
// Allows a registered user to request a password-reset email.
// Updated to use the refactored LabeledTextField direct-parameter API
// (LabeledFieldType enum) instead of the old LabeledTextFieldConfig class.

import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _agreedToTerms = false;
  bool _isLoading     = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ── Request reset ─────────────────────────────────────────────────────────

  Future<void> _requestReset() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      FeastToast.showError(context, 'Please accept the terms first.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.sendPasswordReset(_emailController.text);
      if (!mounted) return;
      FeastToast.showSuccess(
        context,
        'If that email is registered, a reset link has been sent.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: feastLighterYellow,
      body: FeastBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ── Logo & tagline ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(top: 72),
                        child: Column(
                          children: [
                            FeastLogo(height: 110),
                            const SizedBox(height: 14),
                            const FeastTagline(
                              'Welcome To The F.E.A.S.T.\nCharity Management System!',
                            ),
                          ],
                        ),
                      ),

                      // ── Form card ─────────────────────────────────────
                      BottomFormBackground(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const FeastTagline(
                                'Reset Your Password',
                                fontSize: 26,
                              ),
                              const SizedBox(height: 28),

                              // ── Email ─────────────────────────────────
                              // type defaults to LabeledFieldType.text,
                              // which shows the clear (×) button automatically.
                              LabeledTextField(
                                label:       'Email',
                                hintText:    'name@email.com',
                                prefixIcon:  Icons.mail_outline,
                                controller:  _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(v.trim())) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // ── Terms checkbox ────────────────────────
                              FeastCheckbox(
                                text:      "Yes, I've read the terms. Send the link.",
                                value:     _agreedToTerms,
                                linkText:  'terms',
                                linkColor: feastLink,
                                onChanged: (val) =>
                                    setState(() => _agreedToTerms = val ?? false),
                                onLinkTap: () => Navigator.pushNamed(
                                    context, AppRoutes.legal),
                              ),
                              const SizedBox(height: 24),

                              // ── Submit button ─────────────────────────
                              _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          color: feastGreen),
                                    )
                                  : FeastButton(
                                      text:      'Request Password Change',
                                      onPressed: _requestReset,
                                    ),
                              const SizedBox(height: 18),

                              // ── Return to login link ──────────────────
                              FeastLink(
                                text:      'Return To Login',
                                alignment: Alignment.center,
                                onPressed: () => Navigator.pushReplacementNamed(
                                    context, AppRoutes.login),
                              ),
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
        ),
      ),
    );
  }
}

// ── REACT.JS INTEGRATION NOTE ─────────────────────────────────────────────────
// Auth method : sendPasswordResetEmail(auth, email)
// Only one outstanding reset per account at a time; link expires after 5 min
// (configure in Firebase Console → Authentication → Templates).
// Show a generic success message regardless of whether the email exists
// to prevent account enumeration.
// ─────────────────────────────────────────────────────────────────────────────
