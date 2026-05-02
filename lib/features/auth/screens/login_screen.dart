// lib/features/auth/screens/login_screen.dart

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
    
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final emailValid = _emailController.text.trim().isNotEmpty;
    final passwordValid = _passwordController.text.isNotEmpty;
    final isValid = emailValid && passwordValid;
    
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getBool('remember_me') ?? false;
    final email = prefs.getString('cached_email') ?? '';
    if (remembered && email.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _emailController.text = email.toLowerCase();
      });
      _validateForm();
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signIn(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on AuthException catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, e.message);
    } catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, 'Network error. Please check your connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                      BottomFormBackground(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(40, 40, 40, 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ToggleLoginRegister(isLogin: true),
                              const SizedBox(height: 32),

                              // ── Email (Lowercase only) ─────────────────
                              LabeledTextField(
                                label: 'Email',
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
                              const SizedBox(height: 24),

                              // ── Password ──────────────────────────────
                              LabeledTextField(
                                label: 'Password',
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                controller: _passwordController,
                                type: LabeledFieldType.password,
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
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isFormValid ? _signIn : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isFormValid
                                              ? feastGreen
                                              : feastGreen.withOpacity(0.5),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Text(
                                          'Sign In',
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
                              const SizedBox(height: 24),

                              // ── Forgot password link ──────────────────
                              FeastLink(
                                text: 'Forgot Password?',
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
