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
      backgroundColor: feastLighterYellow,
      // Background
      body: FeastBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Logo and Tagline
                    Padding(
                      padding: const EdgeInsets.only(top: 80, bottom: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          FeastLogo(height: 120,),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Toggle Login / Register
                            const ToggleLoginRegister(isLogin: true),
                            const SizedBox(height: 32),
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
                            const SizedBox(height: 32),
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
                            const SizedBox(height: 32),
                            // Remember Me
                            FeastCheckbox(
                              text: "Remember Me.",
                              value: _rememberMe,
                              onChanged: (val) =>
                                  setState(() => _rememberMe = val ?? false),
                            ),
                            const SizedBox(height: 32),
                            // Login Button
                            FeastButton(
                              text: "Sign In",
                              onPressed: () {
                                // Perform login then navigate to Home
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.home,
                                );
                              },
                            ),
                            const SizedBox(height: 32),
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
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
