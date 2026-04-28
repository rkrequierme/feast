// lib/features/splash_screen.dart
//
// Animated splash screen shown while checking authentication state.
// Displays logo, tagline, and loading indicator.
// Auto-navigates to login screen after 3 seconds or when auth state changes.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// In React, implement splash screen using useEffect + setTimeout:
//   useEffect(() => {
//     const timer = setTimeout(() => {
//       onAuthStateChanged(auth, (user) => {
//         if (user) navigate('/home');
//         else navigate('/login');
//       });
//     }, 2000);
//     return () => clearTimeout(timer);
//   }, []);

import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    // Auto-navigate to login after splash
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: feastLightYellow,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FeastLogo(height: 120),
              const SizedBox(height: 16),
              const FeastTagline(
                'F.E.A.S.T.',
                fontSize: 32,
                fontFamily: 'Ultra',
                strokeColor: feastBlue,
                strokeWidth: 10,
              ),
              const SizedBox(height: 8),
              const FeastTagline(
                'Charity Management System',
                fontSize: 16,
                strokeWidth: 8,
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(feastGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
