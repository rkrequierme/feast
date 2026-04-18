/// Centralized Firestore collection and document path helpers.
/// Keeps all path strings in one place for easy refactoring.
class FirestorePaths {
  FirestorePaths._(); // Prevent instantiation

  // ── Top-level collections ──────────────────────────────────────────────────
  static const users = 'users';
  static const aidRequests = 'aid_requests';
  static const charityEvents = 'charity_events';
  static const donations = 'donations';
  static const announcements = 'announcements';
  static const reports = 'reports';

  // ── User sub-collections ───────────────────────────────────────────────────
  static String userDoc(String uid) => '$users/$uid';
  static String userNotifications(String uid) => '$users/$uid/notifications';
  static String userBookmarks(String uid) => '$users/$uid/bookmarks';
  static String userHistory(String uid) => '$users/$uid/activity_logs';
  static String userChats(String uid) => '$users/$uid/chats';

  // ── Aid request helpers ────────────────────────────────────────────────────
  static String aidRequestDoc(String id) => '$aidRequests/$id';
  static String aidRequestDonations(String id) => '$aidRequests/$id/donations';

  // ── Charity event helpers ──────────────────────────────────────────────────
  static String charityEventDoc(String id) => '$charityEvents/$id';
  static String charityEventVolunteers(String id) =>
      '$charityEvents/$id/volunteers';

  // ── Chat helpers ───────────────────────────────────────────────────────────
  static const chats = 'chats';
  static String chatDoc(String chatId) => '$chats/$chatId';
  static String chatMessages(String chatId) => '$chats/$chatId/messages';
}
