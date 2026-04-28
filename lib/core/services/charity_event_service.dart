import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CharityEventService
// All Firestore reads/writes for the charity_events collection.
// ─────────────────────────────────────────────────────────────────────────────

class CharityEventService {
  CharityEventService._();
  static final CharityEventService instance = CharityEventService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const _col = 'charity_events';

  // ── Paginated list ─────────────────────────────────────────────────────────

  Query<Map<String, dynamic>> approvedEventsQuery({
    String? category,
    String? sortBy,
    DocumentSnapshot? lastDoc,
  }) {
    var q = _db
        .collection(_col)
        .where('status', isEqualTo: 'approved');

    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }

    q = q.orderBy('startTime', descending: sortBy != 'oldest');

    if (lastDoc != null) q = q.startAfterDocument(lastDoc);

    return q.limit(10);
  }

  // ── Single stream ──────────────────────────────────────────────────────────

  Stream<DocumentSnapshot<Map<String, dynamic>>> eventStream(String id) {
    return _db.collection(_col).doc(id).snapshots();
  }

  // ── Create charity event ───────────────────────────────────────────────────

  Future<String?> createCharityEvent({
    required String organizerUid,
    required String title,
    required String description,
    required String category,
    required String location,
    required DateTime eventDate,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> coOrganizerUids,
    required List<File> images,
  }) async {
    // Validate: same-day, max 12 hours
    if (!_sameDay(startTime, endTime)) {
      return 'Event must start and end on the same calendar day.';
    }
    if (endTime.difference(startTime).inHours > 12) {
      return 'Event duration cannot exceed 12 hours.';
    }
    if (coOrganizerUids.isEmpty) {
      return 'At least one co-organiser is required.';
    }

    try {
      // Upload images
      final imageUrls = <String>[];
      final newId = _db.collection(_col).doc().id;
      for (int i = 0; i < images.length; i++) {
        final ref = _storage.ref('charity_events/$newId/image_$i.jpg');
        await ref.putFile(images[i]);
        imageUrls.add(await ref.getDownloadURL());
      }

      final allOrganizers = [organizerUid, ...coOrganizerUids];

      await _db.collection(_col).doc(newId).set({
        'id': newId,
        'organizerUid': organizerUid,
        'coOrganizerUids': coOrganizerUids,
        'allOrganizerUids': allOrganizers,
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'eventDate': Timestamp.fromDate(eventDate),
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'imageUrls': imageUrls,
        'participantCount': 0,
        'status': 'pending',
        'groupChatId': '', // filled after admin approval
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Log activity
      await _db
          .collection('users')
          .doc(organizerUid)
          .collection('activity_logs')
          .add({
        'type': 'Post Handling',
        'description': 'Create Charity Event.',
        'postId': newId,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      debugPrint('createCharityEvent error: $e');
      return 'Failed to create charity event. Please try again.';
    }
  }

  // ── Join event ─────────────────────────────────────────────────────────────

  Future<String?> joinEvent({
    required String uid,
    required String eventId,
  }) async {
    try {
      // Check if user already joined
      final existing = await _db
          .collection(_col)
          .doc(eventId)
          .collection('volunteers')
          .doc(uid)
          .get();

      if (existing.exists) return 'You have already requested to join.';

      await _db
          .collection(_col)
          .doc(eventId)
          .collection('volunteers')
          .doc(uid)
          .set({
        'uid': uid,
        'status': 'pending', // admin must confirm
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Notify admins (write to admin notification queue)
      await _db.collection('admin_notifications').add({
        'type': 'event_join_request',
        'eventId': eventId,
        'uid': uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to join event. Please try again.';
    }
  }

  // ── Leave event ────────────────────────────────────────────────────────────

  /// Returns error message if within 24h lockout window.
  Future<String?> leaveEvent({
    required String uid,
    required String eventId,
    required DateTime startTime,
  }) async {
    // Check 24h lockout
    final hoursUntilStart = startTime.difference(DateTime.now()).inHours;
    if (hoursUntilStart < 24) {
      return 'You cannot leave within 24 hours of event start.';
    }

    try {
      await _db
          .collection(_col)
          .doc(eventId)
          .collection('volunteers')
          .doc(uid)
          .delete();

      await _db.collection(_col).doc(eventId).update({
        'participantCount': FieldValue.increment(-1),
      });

      return null;
    } catch (e) {
      return 'Failed to leave event. Please try again.';
    }
  }

  // ── Bookmark ───────────────────────────────────────────────────────────────

  Future<void> toggleBookmark({
    required String uid,
    required String eventId,
    required Map<String, dynamic> eventData,
    required bool currentlyBookmarked,
  }) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(eventId);

    if (currentlyBookmarked) {
      await ref.delete();
    } else {
      await ref.set({
        'id': eventId,
        'type': 'event',
        'title': eventData['title'],
        'category': eventData['category'],
        'thumbnailUrl': (eventData['imageUrls'] as List?)?.first ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Draft ──────────────────────────────────────────────────────────────────

  Future<void> saveDraft(String uid, Map<String, dynamic> data) async {
    await _db
        .collection('drafts')
        .doc(uid)
        .collection('charity_event_draft')
        .doc('current')
        .set(data);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String eventDurationStatus(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();
    if (now.isBefore(startTime)) return 'Not Yet Started';
    if (now.isAfter(endTime)) return 'Concluded';
    return 'Ongoing';
  }
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Collection : charity_events
// Document  : {eventId}
// Fields    : id, organizerUid, coOrganizerUids, allOrganizerUids,
//             title, description, category, location, eventDate,
//             startTime, endTime, imageUrls, participantCount,
//             status, groupChatId, createdAt
// Subcollection: charity_events/{id}/volunteers
//   Fields: uid, status ('pending'|'confirmed'|'rejected'), joinedAt
// React query:
//   const q = query(collection(db, 'charity_events'),
//     where('status', '==', 'approved'),
//     orderBy('startTime', 'desc'));
// Notes:
//   - After admin approval, create a group chat doc and update groupChatId.
//   - 'status': 'pending' | 'approved' | 'rejected' | 'cancelled'
//   - Volunteers subcollection status: 'pending' | 'confirmed' | 'rejected'
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
