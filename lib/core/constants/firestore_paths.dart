// ─────────────────────────────────────────────────────────────────────────────
// firestore_paths.dart  –  Centralised Firestore path constants.
// All paths in the app come from here — never use raw strings elsewhere.
// ─────────────────────────────────────────────────────────────────────────────

class FirestorePaths {
  FirestorePaths._();

  // ── Top-level collections ─────────────────────────────────────────────────
  static const users         = 'users';
  static const aidRequests   = 'aid_requests';
  static const charityEvents = 'charity_events';
  static const announcements = 'announcements';
  static const reports       = 'reports';
  static const chats         = 'chats';
  static const drafts        = 'drafts';
  static const appContent    = 'app_content';
  static const adminLogs     = 'admin_logs';
  static const adminNotifications = 'admin_notifications';
  static const systemConfig  = 'system_config';

  // ── User document + sub-collections ──────────────────────────────────────
  static String userDoc(String uid)           => '$users/$uid';
  static String userNotifications(String uid) => '$users/$uid/notifications';
  static String userBookmarks(String uid)     => '$users/$uid/bookmarks';
  static String userHistory(String uid)       => '$users/$uid/activity_logs';
  static String userChats(String uid)         => '$users/$uid/chats';

  // ── Aid request ───────────────────────────────────────────────────────────
  static String aidRequestDoc(String id)       => '$aidRequests/$id';
  static String aidRequestDonations(String id) => '$aidRequests/$id/donations';

  // ── Charity event ─────────────────────────────────────────────────────────
  static String charityEventDoc(String id)       => '$charityEvents/$id';
  static String charityEventVolunteers(String id) => '$charityEvents/$id/volunteers';

  // ── Chat ──────────────────────────────────────────────────────────────────
  static String chatDoc(String chatId)      => '$chats/$chatId';
  static String chatMessages(String chatId) => '$chats/$chatId/messages';
  static String chatMembers(String chatId)  => '$chats/$chatId/members';

  // ── Draft ─────────────────────────────────────────────────────────────────
  static String aidRequestDraft(String uid) =>
      '$drafts/$uid/aid_request_draft/current';
  static String charityEventDraft(String uid) =>
      '$drafts/$uid/charity_event_draft/current';

  // ── App content (admin-editable) ──────────────────────────────────────────
  static String appContentDoc(String section) => '$appContent/$section';

  // ── System ────────────────────────────────────────────────────────────────
  static const maintenanceDoc = 'system_config/maintenance';
}
