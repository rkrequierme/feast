import 'package:flutter/material.dart';
import '../core.dart';

class ToggleLoginRegister extends StatelessWidget {
  final bool isLogin;

  const ToggleLoginRegister({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(75),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: isLogin ? null : () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: feastGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: isLogin ? () {
                  Navigator.pushReplacementNamed(context, AppRoutes.register);
                } : null,
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: feastGray,
                      fontSize: 16,
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
