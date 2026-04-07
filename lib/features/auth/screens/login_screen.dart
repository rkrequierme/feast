import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo and Tagline
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      FeastLogo(),
                      // Tagline
                      FeastTagline(
                        "Welcome To The F.E.A.S.T.\nCharity Management System!",
                      ),
                    ],
                  ),
                ),
                // Bottom Login Form
                BottomFormBackground(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        // Toggle Login / Register
                        const ToggleLoginRegister(isLogin: true),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email Field
                            LabeledTextField(
                              config: LabeledTextFieldConfig(
                                label: "Email",
                                hintText: "name@email.com",
                                prefixIcon: Icons.mail_outline,
                                controller: _emailController,
                                trailingAction: TrailingAction.clear,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Password Field
                            LabeledTextField(
                              config: LabeledTextFieldConfig(
                                label: "Password",
                                hintText: "Enter your password",
                                prefixIcon: Icons.lock_outline,
                                controller: _passwordController,
                                trailingAction: TrailingAction.togglePassword,
                                obscureText: !_isPasswordVisible,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Remember Me
                            FeastCheckbox(
                              text: "Remember Me.",
                              value: _rememberMe,
                              onChanged: (val) =>
                                  setState(() => _rememberMe = val ?? false),
                            ),
                            const SizedBox(height: 20),
                            // Login Button
                            FeastButton(
                              text: "Sign In",
                              onPressed: () {
                                // Perform login
                              },
                            ),
                            const SizedBox(height: 20),
                            // Forgot Password
                            FeastLink(
                              text: 'Forgot Password?',
                              alignment: Alignment.center,
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPassword,
                                );
                              },
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
      ),
    );
  }
}
