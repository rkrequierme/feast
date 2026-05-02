// lib/features/auth/screens/forgot_password_screen.dart
//
// Allows a registered user to request a password-reset email.
// Updated to use the refactored LabeledTextField direct-parameter API
// (LabeledFieldType enum) instead of the old LabeledTextFieldConfig class.

import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/legal/widgets/terms_conditions_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _emailController.text.trim().isNotEmpty && _agreedToTerms;
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
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
      await AuthService.instance.sendPasswordReset(_emailController.text.trim().toLowerCase());
      if (!mounted) return;
      
      // Show success dialog instead of just a toast
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: feastSuccess, size: 32),
              SizedBox(width: 12),
              Text(
                'Email Sent',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            'If that email is registered, a password reset link has been sent.\n\nPlease check your inbox and spam folder.',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: feastGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Return to Login',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            FeastLogo(height: 120),
                            const SizedBox(height: 12),
                            const FeastTagline(
                              'F.E.A.S.T.',
                              fontSize: 28,
                              textColor: Colors.white,
                              strokeColor: feastBlue,
                              strokeWidth: 8,
                              fontFamily: 'Ultra',
                            ),
                            const SizedBox(height: 4),
                            const FeastTagline(
                              'Charity Management System',
                              fontSize: 20,
                              strokeWidth: 6,
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
                                fontFamily: 'TitanOne',
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Enter your email address and we\'ll send you a link to reset your password.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  color: feastGray,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Email (Lowercase only) ─────────────────
                              LabeledTextField(
                                label: 'Email Address',
                                hintText: 'name@email.com',
                                prefixIcon: Icons.mail_outline,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textCapitalization: TextCapitalization.none,
                                inputFormatters: [LowerCaseTextFormatter()],
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
                                text: "Yes, I've read the terms. Send the link.",
                                value: _agreedToTerms,
                                linkText: 'terms',
                                linkColor: feastBlue,
                                onChanged: (val) => setState(() {
                                  _agreedToTerms = val ?? false;
                                  _validateForm();
                                }),
                                onLinkTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => TermsConditionsDialog(
                                      onAccept: () {
                                        // I Understand - check the checkbox
                                        setState(() {
                                          _agreedToTerms = true;
                                          _validateForm();
                                        });
                                      },
                                      onDecline: () {
                                        // Decline - uncheck the checkbox
                                        setState(() {
                                          _agreedToTerms = false;
                                          _validateForm();
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // ── Submit button ─────────────────────────
                              _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          color: feastGreen),
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isFormValid ? _requestReset : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isFormValid
                                              ? feastGreen
                                              : feastGreen.withOpacity(0.5),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Text(
                                          'Send Reset Link',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.bold,
                                            color: _isFormValid
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 18),

                              // ── Return to login link ──────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Remember your password? ',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 13,
                                      color: feastGray,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacementNamed(
                                        context, AppRoutes.login),
                                    child: const Text(
                                      'Sign In.',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: feastBlue,
                                      ),
                                    ),
                                  ),
                                ],
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
