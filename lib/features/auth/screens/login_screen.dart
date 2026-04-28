// lib/features/auth/screens/login_screen.dart
//
// Login screen with Firebase Auth, Remember Me, and inline validation.
// Updated to use the refactored LabeledTextField direct-parameter API
// (LabeledFieldType enum) instead of the old LabeledTextFieldConfig class.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feast/core/core.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading  = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs     = await SharedPreferences.getInstance();
    final remembered = prefs.getBool('remember_me') ?? false;
    final email      = prefs.getString('cached_email') ?? '';
    if (remembered && email.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _emailController.text = email;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signIn(
        email:      _emailController.text,
        password:   _passwordController.text,
        rememberMe: _rememberMe,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on AuthException catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, e.message);
    } catch (_) {
      if (!mounted) return;
      FeastToast.showError(context, 'Something went wrong. Please try again.');
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // ── Logo & tagline ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(top: 80, bottom: 40),
                        child: Column(
                          children: [
                            FeastLogo(height: 120),
                            const SizedBox(height: 12),
                            const FeastTagline(
                              'Welcome To The F.E.A.S.T.\nCharity Management System!',
                            ),
                          ],
                        ),
                      ),

                      // ── Form card ───────────────────────────────────────
                      BottomFormBackground(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(40, 40, 40, 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // isLogin: true → "Login" tab is highlighted.
                              const ToggleLoginRegister(isLogin: true),
                              const SizedBox(height: 32),

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
                              const SizedBox(height: 24),

                              // ── Password ──────────────────────────────
                              // LabeledFieldType.password manages its own
                              // obscureText state internally — no
                              // _isPasswordVisible flag needed here.
                              LabeledTextField(
                                label:      'Password',
                                hintText:   '••••••••',
                                prefixIcon: Icons.lock_outline,
                                controller: _passwordController,
                                type:       LabeledFieldType.password,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // ── Remember Me ───────────────────────────
                              FeastCheckbox(
                                text: 'Remember Me.',
                                value: _rememberMe,
                                onChanged: (val) =>
                                    setState(() => _rememberMe = val ?? false),
                              ),
                              const SizedBox(height: 24),

                              // ── Sign In button ────────────────────────
                              _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          color: feastGreen),
                                    )
                                  : FeastButton(
                                      text:      'Sign In',
                                      onPressed: _signIn,
                                    ),
                              const SizedBox(height: 24),

                              // ── Forgot password link ──────────────────
                              FeastLink(
                                text:      'Forgot Password?',
                                alignment: Alignment.center,
                                onPressed: () => Navigator.pushNamed(
                                    context, AppRoutes.forgotPassword),
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
// Auth method : signInWithEmailAndPassword(auth, email, password)
// Post-login  : check users/{uid}.status === 'active' before routing.
// Remember Me : use browserLocalPersistence vs browserSessionPersistence.
// ─────────────────────────────────────────────────────────────────────────────
