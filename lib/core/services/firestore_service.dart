// lib/core/services/firestore_service.dart
//
// All Firestore read / write operations live here.
// Screens call these methods — no raw Firestore calls in UI code.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feast/core/core.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // ════════════════════════════════════════════════════════════════════════
  // ── USER ────────────────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════

  /// Stream of the currently signed-in user's document.
  Stream<DocumentSnapshot> get currentUserStream =>
      _db.collection(FirestorePaths.users).doc(_uid).snapshots();

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final doc = await _db.collection(FirestorePaths.users).doc(_uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _db.collection(FirestorePaths.users).doc(_uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _logActivity(
      type: 'Profile Update',
      description: 'Updated profile settings.',
      status: 'Success',
    );
  }

  /// Updates specific fields for a user document by UID.
  /// Useful during registration or admin overrides.
  Future<void> updateUserField({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection(FirestorePaths.users).doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ════════════════════════════════════════════════════════════════════════
  // ── AID REQUESTS ────────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════

  /// Paginated, approved aid requests ordered by newest first.
  Query<Map<String, dynamic>> aidRequestsQuery({
    String? category,
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection(FirestorePaths.aidRequests)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }
    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }
    return q;
  }

  /// Real-time stream of the 3 most recent approved aid requests (for carousel).
  Stream<QuerySnapshot> featuredAidRequestsStream() =>
      _db
          .collection(FirestorePaths.aidRequests)
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots();

  Future<DocumentReference> createAidRequest(
      Map<String, dynamic> data) async {
    final ref = await _db.collection(FirestorePaths.aidRequests).add({
      ...data,
      'authorId': _uid,
      'status': 'pending', // admin must approve
      'donorCount': 0,
      'fundsDonated': 0.0,
      'itemsDonated': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _logActivity(
      type: 'Post Handling',
      description: 'Created Aid Request: ${data['title']}',
      status: 'Pending',
    );

    return ref;
  }

  Future<void> saveDraft(
      Map<String, dynamic> data, String collection) async {
    await _db.collection('drafts').add({
      ...data,
      'authorId': _uid,
      'collection': collection,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Donations ──────────────────────────────────────────────────────────

  Future<void> donateFunds({
    required String requestId,
    required double amount,
  }) async {
    final batch = _db.batch();

    final donationRef = _db
        .collection(FirestorePaths.aidRequestDonations(requestId))
        .doc();

    batch.set(donationRef, {
      'donorId': _uid,
      'type': 'funds',
      'amount': amount,
      'status': 'pledged', // 'pledged' → 'delivered' → 'claimed'
      'pledgedAt': FieldValue.serverTimestamp(),
      'deadline': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 3)),
      ),
    });

    batch.update(
      _db.collection(FirestorePaths.aidRequests).doc(requestId),
      {
        'fundsDonated': FieldValue.increment(amount),
        'donorCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();

    await _logActivity(
      type: 'Donation',
      description: 'Pledged ₱${amount.toStringAsFixed(2)} to aid request.',
      status: 'Pending',
    );
  }

  Future<void> donateItems({
    required String requestId,
    required List<Map<String, dynamic>> items, // [{name, quantity}]
  }) async {
    final batch = _db.batch();

    for (final item in items) {
      final donationRef = _db
          .collection(FirestorePaths.aidRequestDonations(requestId))
          .doc();
      batch.set(donationRef, {
        'donorId': _uid,
        'type': 'items',
        'itemName': item['name'],
        'quantity': item['quantity'],
        'status': 'pledged',
        'pledgedAt': FieldValue.serverTimestamp(),
        'deadline': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
      });
    }

    batch.update(
      _db.collection(FirestorePaths.aidRequests).doc(requestId),
      {
        'itemsDonated': FieldValue.increment(items.length),
        'donorCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();

    await _logActivity(
      type: 'Donation',
      description: 'Donated ${items.length} item(s) to aid request.',
      status: 'Pending',
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // ── CHARITY EVENTS ────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════

  Query<Map<String, dynamic>> charityEventsQuery({
    String? category,
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection(FirestorePaths.charityEvents)
        .where('status', isEqualTo: 'approved')
        .orderBy('startTime', descending: false)
        .limit(limit);

    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }
    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }
    return q;
  }

  Future<DocumentReference> createCharityEvent(
      Map<String, dynamic> data) async {
    final ref = await _db.collection(FirestorePaths.charityEvents).add({
      ...data,
      'organiserId': _uid,
      'organiserIds': [_uid, ...((data['coOrganiserIds'] as List?) ?? [])],
      'status': 'pending',
      'participantCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _logActivity(
      type: 'Post Handling',
      description: 'Created Charity Event: ${data['title']}',
      status: 'Pending',
    );

    return ref;
  }

  Future<void> joinCharityEvent(String eventId) async {
    await _db
        .collection(FirestorePaths.charityEventVolunteers(eventId))
        .doc(_uid)
        .set({
      'userId': _uid,
      'status': 'pending', // admin must confirm
      'joinedAt': FieldValue.serverTimestamp(),
    });

    await _logActivity(
      type: 'Event Participation',
      description: 'Requested to join charity event.',
      status: 'Pending',
    );
  }

  Future<void> leaveCharityEvent(String eventId) async {
    // Check 24-hour restriction before allowing leave
    final eventDoc = await _db
        .collection(FirestorePaths.charityEvents)
        .doc(eventId)
        .get();
    final startTime =
        (eventDoc.data()?['startTime'] as Timestamp?)?.toDate();

    if (startTime != null &&
        DateTime.now().isAfter(
          startTime.subtract(const Duration(hours: 24)),
        )) {
      throw Exception(
        'Cannot leave an event within 24 hours of its start time. '
        'A penalty may apply.',
      );
    }

    await _db
        .collection(FirestorePaths.charityEventVolunteers(eventId))
        .doc(_uid)
        .delete();

    await _db.collection(FirestorePaths.charityEvents).doc(eventId).update({
      'participantCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _logActivity(
      type: 'Event Participation',
      description: 'Left charity event.',
      status: 'Success',
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // ── ANNOUNCEMENTS ─────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════

  Stream<QuerySnapshot> announcementsStream({int limit = 5}) =>
      _db
          .collection(FirestorePaths.announcements)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots();

  // ════════════════════════════════════════════════════════════════════════
  // ── NOTIFICATIONS ─────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════

  Stream<QuerySnapshot> notificationsStream() =>
      _db
          .collection(FirestorePaths.userNotifications(_uid))
          .orderBy('createdAt', descending: true)
          .snapshots();

  Future<void> markAllNotificationsRead() async {
    final snap = await _db
        .collection(FirestorePaths.userNotifications(_uid))
        .where('read', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;
    
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> markNotificationRead(String notifId) async {
    await _db
        .collection(FirestorePaths.userNotifications(_uid))
        .doc(notifId)
        .update({'read': true});
  }

  Future<void> deleteNotification(String notifId) async {
    await _db
        .collection(FirestorePaths.userNotifications(_uid))
        .doc(notifId)
        .delete();
  }

  // ════════════════════════════════════════════════════════════════════════
  // ── BOOKMARKS ─────────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════

  Stream<QuerySnapshot> bookmarksStream() =>
      _db
          .collection(FirestorePaths.userBookmarks(_uid))
          .orderBy('savedAt', descending: true)
          .snapshots();

  Future<void> addBookmark({
    required String itemId,
    required String itemType, // 'request' | 'event'
    required String title,
  }) async {
    await _db
        .collection(FirestorePaths.userBookmarks(_uid))
        .doc(itemId)
        .set({
      'itemId': itemId,
      'itemType': itemType,
      'title': title,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark(String itemId) async {
    await _db
        .collection(FirestorePaths.userBookmarks(_uid))
        .doc(itemId)
        .delete();
  }

  Future<bool> isBookmarked(String itemId) async {
    final doc = await _db
        .collection(FirestorePaths.userBookmarks(_uid))
        .doc(itemId)
        .get();
    return doc.exists;
  }

  // ════════════════════════════════════════════════════════════════════════
  // ── MESSAGES / CHATS ──────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════

  /// Stream of chats where the current user is a participant.
  Stream<QuerySnapshot> chatsStream() =>
      _db
          .collection(FirestorePaths.chats)
          .where('participantIds', arrayContains: _uid)
          .orderBy('lastMessageAt', descending: true)
          .snapshots();

  /// Paginated messages for a chat — newest first, then reversed in UI.
  Query<Map<String, dynamic>> messagesQuery(
    String chatId, {
    DocumentSnapshot? startAfter,
    int limit = 30,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection(FirestorePaths.chatMessages(chatId))
        .orderBy('sentAt', descending: true)
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    return q;
  }

  Future<DocumentReference> createChat({
    required List<String> participantIds,
    required bool isGroup,
    String? groupName,
    String? groupImageUrl,
  }) async {
    final allParticipants = [...participantIds];
    if (!allParticipants.contains(_uid)) allParticipants.add(_uid);

    final ref = await _db.collection(FirestorePaths.chats).add({
      'participantIds': allParticipants,
      'isGroup': isGroup,
      'groupName': groupName ?? '',
      'groupImageUrl': groupImageUrl ?? '',
      'creatorId': _uid,
      'adminIds': [_uid],
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return ref;
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    final batch = _db.batch();

    final msgRef = _db
        .collection(FirestorePaths.chatMessages(chatId))
        .doc();

    batch.set(msgRef, {
      'senderId': _uid,
      'text': text,
      'attachmentUrl': attachmentUrl ?? '',
      'attachmentType': attachmentType ?? '',
      'sentAt': FieldValue.serverTimestamp(),
      'readBy': [_uid],
    });

    batch.update(
      _db.collection(FirestorePaths.chats).doc(chatId),
      {
        'lastMessage': text.isEmpty ? '[Attachment]' : text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }

  // ════════════════════════════════════════════════════════════════════════
  // ── HISTORY / ACTIVITY LOGS ────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════

  Stream<QuerySnapshot> activityLogsStream() =>
      _db
          .collection(FirestorePaths.userHistory(_uid))
          .orderBy('timestamp', descending: true)
          .snapshots();

  // ════════════════════════════════════════════════════════════════════════
  // ── REPORTS ────────────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════

  Future<void> submitReport({
    required String targetId,
    required String targetType, // 'user' | 'aid_request' | 'charity_event'
    required String title,
    required String description,
  }) async {
    await _db.collection(FirestorePaths.reports).add({
      'reporterId': _uid,
      'targetId': targetId,
      'targetType': targetType,
      'title': title,
      'description': description,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _logActivity(
      type: 'Report',
      description: 'Submitted a report for $targetType.',
      status: 'Pending',
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // ── ADMIN ──────────────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════

  /// Only callable when role == 'admin'.
  Future<void> approveUser(String uid) async {
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _sendNotification(
      uid: uid,
      title: 'Account Approved',
      body: 'Your F.E.A.S.T. account has been approved. Welcome!',
      type: 'system',
      status: 'approved',
    );
  }

  Future<void> rejectUser(String uid, String reason) async {
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _sendNotification(
      uid: uid,
      title: 'Account Rejected',
      body: 'Your registration was not approved. Reason: $reason',
      type: 'system',
      status: 'rejected',
    );
  }

  Future<void> approvePost(String collection, String postId) async {
    await _db.collection(collection).doc(postId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectPost(
      String collection, String postId, String reason) async {
    await _db.collection(collection).doc(postId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> issueWarning(String uid, String reason) async {
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'warningCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _sendNotification(
      uid: uid,
      title: 'Warning Issued',
      body: 'You have received a warning. Reason: $reason',
      type: 'system',
      status: 'warning',
    );
  }

  Future<void> banUser(String uid, String reason, int days) async {
    final banExpiry = days == 0
        ? null
        : Timestamp.fromDate(
            DateTime.now().add(Duration(days: days)),
          );
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'status': 'banned',
      'banReason': reason,
      'banExpiry': banExpiry,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _sendNotification(
      uid: uid,
      title: 'Account Banned',
      body: 'Your account has been banned. Reason: $reason',
      type: 'system',
      status: 'banned',
    );
  }

  Future<void> postAnnouncement(Map<String, dynamic> data) async {
    await _db.collection(FirestorePaths.announcements).add({
      ...data,
      'authorId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Pending counts (used by admin dashboard) ───────────────────────────

  Stream<int> pendingUsersCount() => _db
      .collection(FirestorePaths.users)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) => s.size);

  Stream<int> pendingPostsCount(String collection) => _db
      .collection(collection)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) => s.size);

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Future<void> _logActivity({
    required String type,
    required String description,
    required String status,
  }) async {
    await _db
        .collection(FirestorePaths.userHistory(_uid))
        .add({
      'type': type,
      'description': description,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _sendNotification({
    required String uid,
    required String title,
    required String body,
    required String type,
    required String status,
  }) async {
    await _db
        .collection(FirestorePaths.userNotifications(uid))
        .add({
      'title': title,
      'body': body,
      'type': type, // 'system' | 'user'
      'status': status,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Collection : aid_requests
// Fields    : title, description, category, location, authorId, status,
//             aidType, imageUrls, fundraiserGoal, fundsDonated,
//             donorCount, itemsDonated, acceptedItems, postDuration,
//             createdAt, approvedAt, updatedAt
// Sub-coll  : donations — donorId, type, amount|items, status, deadline
//
// Collection : charity_events
// Fields    : title, description, category, location, organiserId,
//             coOrganiserIds, startTime, endTime, status, imageUrls,
//             participantCount, createdAt, approvedAt
// Sub-coll  : volunteers — userId, status, joinedAt
//
// Collection : chats
// Fields    : participantIds[], isGroup, groupName, creatorId, adminIds[]
// Sub-coll  : messages — senderId, text, attachmentUrl, sentAt, readBy[]
//
// Pagination: React uses startAfter(lastDoc) from Firestore SDK v9+.
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
