import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:feast/core/core.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ─── Logo and Tagline ───
              Expanded(
                flex: 4,
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
              // ─── Bottom Form ───
              Expanded(
                flex: 6,
                child: BottomFormBackground(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        // ─── Title ───
                        FeastTagline("Reset Your Password"),
                        const SizedBox(height: 24),

                        // ─── Email Field ───
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FieldLabel(text: "Email"),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(13),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'name@email.com',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontFamily: "Outfit",
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.mail_outline,
                                    color: Colors.black54,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.black54,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _emailController.clear();
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ─── Terms Checkbox ───
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value ?? false;
                                  });
                                },
                                activeColor: feastGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: "Yes, I've read the ",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'terms',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Open terms
                                        },
                                    ),
                                    const TextSpan(text: '. Send the link.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // ─── Send Link Button ───
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.resetPassword,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: feastGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Request Password Change',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Back to Login ───
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                          child: const Text(
                            'Return To Login',
                            style: TextStyle(
                              color: feastLink,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
