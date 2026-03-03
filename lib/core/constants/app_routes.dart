class AppRoutes {
  // Auth
  static const splash           = '/';
  static const login            = '/login';
  static const register         = '/register';
  static const registerId       = '/register/id';
  static const forgotPassword   = '/forgot_password';
  static const resetPassword    = '/reset_password';

  // Main Features
  static const home             = '/home';
  static const aidRequests      = '/aid_requests';
  static const aidRequestDetail = '/aid_requests/detail';
  static const createAidRequest = '/aid_requests/create';
  static const charityEvents    = '/charity_events';
  static const eventDetail      = '/charity_events/detail';
  static const createEvent      = '/charity_events/create';
  static const messages         = '/messages';
  static const chatDetail       = '/messages/chat';
  static const groupDetail      = '/messages/group';
  static const settings         = '/settings';
  static const editProfile      = '/settings/edit_profile';

  // Side Menu Features
  static const about            = '/about';
  static const bookmarks        = '/bookmarks';
  static const contact          = '/contact';
  static const guide            = '/guide';
  static const history          = '/history';
  static const legal            = '/legal';
  static const notifications    = '/notifications';
  static const support          = '/support';
}