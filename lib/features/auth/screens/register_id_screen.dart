import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class RegisterIdScreen extends StatefulWidget {
  const RegisterIdScreen({super.key});

  @override
  State<RegisterIdScreen> createState() => _RegisterIdScreenState();
}

class _RegisterIdScreenState extends State<RegisterIdScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: feastLightYellow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verify Identity',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // ── Icon ────────────────────────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: feastGreen.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  size: 48,
                  color: feastGreen,
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ───────────────────────────────────────────────────
              const Text(
                'ID Verification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // ── Description ─────────────────────────────────────────────
              const Text(
                'Upload a valid government-issued ID to complete your '
                'registration. This helps us verify your identity and '
                'keep the community safe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // ── Coming Soon Badge ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: feastLightYellowAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Back Button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feastGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
