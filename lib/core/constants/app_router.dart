import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/features.dart';

// ─────────────────────────────────────────────────────────────────────────────
// app_router.dart  –  Central route table for the F.E.A.S.T. app.
//
// Simple routes (no args) live in [routes].
// Routes that require arguments use [onGenerateRoute].
// ─────────────────────────────────────────────────────────────────────────────

class AppRouter {
  AppRouter._();

  // ── Static route map ──────────────────────────────────────────────────────
  static final Map<String, WidgetBuilder> routes = {
    // Auth
    AppRoutes.splash:         (_) => const SplashScreen(),
    AppRoutes.login:          (_) => const LoginScreen(),
    AppRoutes.register:       (_) => const RegisterScreen(),
    AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
    AppRoutes.resetPassword:  (_) => const ResetPasswordScreen(),

    // Main
    AppRoutes.home:           (_) => const HomeScreen(),
    AppRoutes.aidRequests:    (_) => const AidRequestsScreen(),
    AppRoutes.createAidRequest: (_) => const CreateAidRequestScreen(),
    AppRoutes.charityEvents:  (_) => const CharityEventsScreen(),
    AppRoutes.createEvent:    (_) => const CreateCharityEventScreen(),
    AppRoutes.messages:       (_) => const MessagesScreen(),
    AppRoutes.settings:       (_) => const SettingsScreen(),
    // AppRoutes.editProfile:    (_) => const EditProfileScreen(),

    // Side menu
    AppRoutes.about:          (_) => const AboutUsScreen(),
    AppRoutes.bookmarks:      (_) => const BookmarksScreen(),
    AppRoutes.contact:        (_) => const ContactUsScreen(),
    AppRoutes.guide:          (_) => const AppGuideScreen(),
    AppRoutes.history:        (_) => const HistoryScreen(),
    AppRoutes.legal:          (_) => const TermsConditionsScreen(),
    AppRoutes.notifications:  (_) => const NotificationsScreen(),
    AppRoutes.support:        (_) => const HelpFaqScreen(),

    // Admin (temporary — remove once React.js dashboard is live)
    AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
  };

  // ── Dynamic routes that need arguments ────────────────────────────────────
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Aid request detail  — args: String docId
      // FIX: SelectedAidRequestScreen has no named constructor params.
      // It reads the docId via ModalRoute.of(context)?.settings.arguments
      // inside didChangeDependencies. Pass RouteSettings through _slide so
      // the argument is available to the screen.
      case AppRoutes.aidRequestDetail:
        return _slide(const SelectedAidRequestScreen(), settings: settings);

      // Charity event detail — args: String docId
      // FIX: Same pattern — no eventId constructor param; arg forwarded via
      // RouteSettings instead.
      case AppRoutes.eventDetail:
        return _slide(const SelectedCharityEventScreen(), settings: settings);

      // DM / personal chat  — args: String chatId
      case AppRoutes.chatDetail:
        return _slide(SelectedChatScreen(chatId: settings.arguments as String));

      // Group chat detail   — args: String chatId
      case AppRoutes.groupDetail:
        return _slide(SelectedGroupScreen(chatId: settings.arguments as String));

      default:
        return _slide(
          Scaffold(
            body: Center(
              child: Text(
                'No route found for "${settings.name}"',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        );
    }
  }

  // ── Slide-from-right transition ───────────────────────────────────────────
  // FIX: Added optional `settings` parameter so that PageRouteBuilder carries
  // the route name + arguments, making them accessible to screens via
  // ModalRoute.of(context)?.settings.arguments.
  static PageRouteBuilder _slide(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        );
      },
    );
  }
}
