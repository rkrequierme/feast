import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// app_colors.dart  –  Single source of truth for every color in F.E.A.S.T.
//
// USAGE RULES:
//  • Never use raw Color() literals anywhere outside this file.
//  • Import via `package:feast/core/core.dart`.
// ─────────────────────────────────────────────────────────────────────────────

// ── Brand greens ──────────────────────────────────────────────────────────────
const Color feastGreen       = Color(0xFF2E7D32);
const Color feastLightGreen  = Color(0xFFB4DCCD);
const Color feastDarkGreen   = Color(0xFF1B5E20);

// ── Brand blues ───────────────────────────────────────────────────────────────
const Color feastBlue           = Color(0xFF0277BD);
const Color feastDarkBlue       = Color(0xFF01579B);
const Color feastLightBlue      = Color(0xFF81D4FA);
const Color feastLighterBlue    = Color(0xFFB3E5FC);
const Color feastLightBlueAccent= Color(0xFF90CAF9);

// ── Brand yellows / oranges ───────────────────────────────────────────────────
const Color feastOrange           = Color(0xFFF57F17);
const Color feastLightYellow      = Color(0xFFFFF59D);
const Color feastLighterYellow    = Color(0xFFFEF8C4);
const Color feastLightYellowAccent= Color(0xFFFFE082);

// ── Neutrals ──────────────────────────────────────────────────────────────────
const Color feastGray  = Color(0xFF656070);
const Color feastBlack = Color(0xFF1D1B20);
const Color feastWhite = Color(0xFFFFFFFF);

// ── Nav / widget chrome ───────────────────────────────────────────────────────
const Color feastNavBarBackground = Color(0xFFE8F5E9);
const Color feastUnselected       = Color(0xFF9BB97D);
const Color feastLogTitle         = Color(0xFF00696D);

// ── Semantic / status ─────────────────────────────────────────────────────────
const Color feastLink    = Color(0xFF0000FF);
const Color feastInfo    = Color(0xFF0088FF);
const Color feastSuccess = Color(0xFF34C759);
const Color feastPending = Color(0xFFFF8D28);
const Color feastError   = Color(0xFFFF383C);
const Color feastWarning = Color(0xFFDC143C);

// ── Duration-status colors (charity events) ───────────────────────────────────
const Color feastEventNotStarted = Color(0xFFF57F17); // orange
const Color feastEventOngoing    = Color(0xFF2E7D32); // green
const Color feastEventConcluded  = Color(0xFF9E9E9E); // grey

// ── Theme helper: returns correct tab accent for requests vs events ───────────
Color feastTabAccent(bool isRequests) =>
    isRequests ? feastLightYellowAccent : feastLightBlueAccent;

Color feastTabBorder(bool isRequests) =>
    isRequests ? feastOrange : feastBlue;
