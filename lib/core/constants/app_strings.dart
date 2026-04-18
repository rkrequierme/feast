/// Centralized string constants used across the app.
/// Prevents typos and makes localization easier in the future.
class AppStrings {
  AppStrings._(); // Prevent instantiation

  // ── App Info ───────────────────────────────────────────────────────────────
  static const appName = 'F.E.A.S.T.';
  static const appFullName = 'Food, Emergency Aid, Support & Transparency';
  static const appTagline = 'Charity Management System';

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const login = 'Login';
  static const register = 'Register';
  static const forgotPassword = 'Forgot Password?';
  static const signIn = 'Sign In';
  static const signOut = 'Sign Out';
  static const resetPassword = 'Reset Password';

  // ── Navigation ─────────────────────────────────────────────────────────────
  static const home = 'Home';
  static const messages = 'Messages';
  static const settings = 'Settings';
  static const notifications = 'Notifications';
  static const bookmarks = 'Bookmarks';
  static const history = 'Your History';
  static const aboutUs = 'About Us';
  static const contactUs = 'Contact Us';
  static const helpFaq = 'Help & FAQ';
  static const appGuide = 'App Guide';
  static const termsConditions = 'Terms & Conditions';

  // ── Actions ────────────────────────────────────────────────────────────────
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const delete = 'Delete';
  static const confirm = 'Confirm';
  static const submit = 'Submit';
  static const edit = 'Edit';
  static const share = 'Share';
  static const report = 'Report';
  static const donate = 'Donate';
  static const tryAgain = 'Try Again';

  // ── Empty States ───────────────────────────────────────────────────────────
  static const noNotifications = 'No notifications yet';
  static const noMessages = 'No messages yet';
  static const noBookmarks = 'No bookmarks saved';
  static const noHistory = 'No activity history';
  static const noAidRequests = 'No aid requests found';
  static const noCharityEvents = 'No charity events found';

  // ── Error States ───────────────────────────────────────────────────────────
  static const genericError = 'Something went wrong';
  static const networkError = 'Please check your internet connection';
  static const loadingError = 'Failed to load data';
}
