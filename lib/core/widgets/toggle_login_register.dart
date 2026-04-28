// lib/core/widgets/toggle_login_register.dart
//
// A pill-shaped toggle that switches between the Login and Register screens.
// The ACTIVE tab is highlighted in green; the inactive tab is plain text.
//
// FIX: The original widget always highlighted "Login" in green regardless of
// the [isLogin] value, because both tab containers used hard-coded colours
// instead of branching on [isLogin]. The corrected version derives the
// background colour and text colour for each tab from [isLogin].
//
// Usage
// ─────
//   // On the Login screen:
//   const ToggleLoginRegister(isLogin: true)
//
//   // On the Register screen:
//   const ToggleLoginRegister(isLogin: false)

import 'package:flutter/material.dart';
import '../core.dart';

class ToggleLoginRegister extends StatelessWidget {
  /// Pass [true] when this widget is rendered on the Login screen,
  /// [false] when it is on the Register screen.
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
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            // ── Login tab ────────────────────────────────────────────────
            Expanded(
              child: GestureDetector(
                // Tapping the Login tab while on the Register screen navigates back.
                // Tapping it while already on Login does nothing.
                onTap: isLogin
                    ? null
                    : () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        ),
                child: _TabContainer(
                  label: 'Login',
                  isActive: isLogin, // highlighted when on the Login screen
                ),
              ),
            ),

            // ── Register tab ─────────────────────────────────────────────
            Expanded(
              child: GestureDetector(
                // Tapping the Register tab while on the Login screen navigates forward.
                // Tapping it while already on Register does nothing.
                onTap: isLogin
                    ? () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.register,
                        )
                    : null,
                child: _TabContainer(
                  label: 'Register',
                  isActive: !isLogin, // highlighted when on the Register screen
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private helper — a single coloured tab pill ───────────────────────────────

class _TabContainer extends StatelessWidget {
  final String label;
  final bool isActive;

  const _TabContainer({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Active tab gets the green background; inactive is transparent.
        color: isActive ? feastGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          // Active tab uses white text; inactive uses the app's grey.
          color: isActive ? Colors.white : feastGray,
          fontSize: 16,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
