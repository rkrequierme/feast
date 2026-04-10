import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/features.dart';

class AppRouter {
  // All simple screens that need no arguments
  static final Map<String, WidgetBuilder> routes = {
    AppRoutes.splash:           (_) => const SplashScreen(),
    AppRoutes.login:            (_) => const LoginScreen(),
    AppRoutes.register:         (_) => const RegisterScreen(),
    AppRoutes.registerId:       (_) => const RegisterIdScreen(),
    AppRoutes.forgotPassword:   (_) => const ForgotPasswordScreen(),
    AppRoutes.resetPassword:    (_) => const ResetPasswordScreen(),
    AppRoutes.home:             (_) => const HomeScreen(),
    AppRoutes.aidRequests:      (_) => const AidRequestsScreen(),
    AppRoutes.createAidRequest: (_) => const CreateAidRequestScreen(),
    AppRoutes.charityEvents:    (_) => const CharityEventsScreen(),
    AppRoutes.createEvent:      (_) => const CreateCharityEventScreen(),
    AppRoutes.messages:         (_) => const MessagesScreen(),
    AppRoutes.settings:         (_) => const SettingsScreen(),
    AppRoutes.about:            (_) => const AboutUsScreen(),
    AppRoutes.bookmarks:        (_) => const BookmarksScreen(),
    AppRoutes.contact:          (_) => const ContactUsScreen(),
    AppRoutes.guide:            (_) => const AppGuideScreen(),
    AppRoutes.history:          (_) => const HistoryScreen(),
    AppRoutes.legal:            (_) => const TermsConditionsScreen(),
    AppRoutes.notifications:    (_) => const NotificationsScreen(),
    AppRoutes.support:          (_) => const HelpFaqScreen(),
  };

  // Only the screens that need arguments go here
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // final args = settings.arguments;

    switch (settings.name) {
      /*
      case AppRoutes.aidRequestDetail:
        return MaterialPageRoute(
          builder: (_) => SelectedAidRequestScreen(request: args as AidRequestModel),
        );
      case AppRoutes.eventDetail:
        return MaterialPageRoute(
          builder: (_) => SelectedCharityEventScreen(event: args as CommunityEventModel),
        );
      case AppRoutes.chatDetail:
        return MaterialPageRoute(
          builder: (_) => SelectedChatScreen(chat: args as ChatModel),
        );
      case AppRoutes.groupDetail:
        return MaterialPageRoute(
          builder: (_) => SelectedGroupScreen(chat: args as ChatModel),
        );
      */
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
