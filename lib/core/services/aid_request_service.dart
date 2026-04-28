import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AidRequestService
// All Firestore reads/writes for the aid_requests collection.
// ─────────────────────────────────────────────────────────────────────────────

class AidRequestService {
  AidRequestService._();
  static final AidRequestService instance = AidRequestService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const _col = 'aid_requests';

  // ── Paginated list ─────────────────────────────────────────────────────────

  /// Returns a paginated query of approved aid requests.
  /// Pass [lastDoc] to load the next page.
  Query<Map<String, dynamic>> approvedRequestsQuery({
    String? category,
    String? sortBy, // 'newest' | 'oldest'
    DocumentSnapshot? lastDoc,
  }) {
    var q = _db
        .collection(_col)
        .where('status', isEqualTo: 'approved')
        .where('isExpired', isEqualTo: false);

    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }

    q = q.orderBy(
      'createdAt',
      descending: sortBy != 'oldest',
    );

    if (lastDoc != null) {
      q = q.startAfterDocument(lastDoc);
    }

    return q.limit(10);
  }

  // ── Single document stream ─────────────────────────────────────────────────

  Stream<DocumentSnapshot<Map<String, dynamic>>> requestStream(String id) {
    return _db.collection(_col).doc(id).snapshots();
  }

  // ── Create aid request ─────────────────────────────────────────────────────

  /// Uploads images and writes the aid request document (status: pending).
  Future<String?> createAidRequest({
    required String uid,
    required String title,
    required String description,
    required String category,
    required String aidRequestType, // 'Fundraiser' | 'In-Kind' | 'Supply & Support'
    required String location,
    required int postDurationDays,
    required List<File> images,
    double? fundraiserGoal,        // for Fundraiser / Supply & Support
    List<String>? acceptedItems,   // for In-Kind / Supply & Support
  }) async {
    try {
      // 1. Upload images to Storage
      final imageUrls = <String>[];
      for (int i = 0; i < images.length; i++) {
        final docId = _db.collection(_col).doc().id;
        final ref = _storage.ref('aid_requests/$docId/image_$i.jpg');
        await ref.putFile(images[i]);
        imageUrls.add(await ref.getDownloadURL());
      }

      // 2. Compute expiry date
      final expiresAt = DateTime.now().add(Duration(days: postDurationDays));

      // 3. Write to Firestore
      final docRef = _db.collection(_col).doc();
      await docRef.set({
        'id': docRef.id,
        'uid': uid,
        'title': title,
        'description': description,
        'category': category,
        'aidRequestType': aidRequestType,
        'location': location,
        'postDurationDays': postDurationDays,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'imageUrls': imageUrls,
        'fundraiserGoal': fundraiserGoal ?? 0,
        'fundraiserRaised': 0,
        'acceptedItems': acceptedItems ?? [],
        'itemsDonated': 0,
        'donorCount': 0,
        'status': 'pending', // awaits admin approval
        'isExpired': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Log activity
      await _db
          .collection('users')
          .doc(uid)
          .collection('activity_logs')
          .add({
        'type': 'Post Handling',
        'description': 'Create Aid Request.',
        'postId': docRef.id,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // success
    } catch (e) {
      debugPrint('createAidRequest error: $e');
      return 'Failed to submit aid request. Please try again.';
    }
  }

  // ── Save draft ─────────────────────────────────────────────────────────────

  Future<void> saveDraft({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection('drafts')
        .doc(uid)
        .collection('aid_request_draft')
        .doc('current')
        .set(data);
  }

  Future<Map<String, dynamic>?> loadDraft(String uid) async {
    final doc = await _db
        .collection('drafts')
        .doc(uid)
        .collection('aid_request_draft')
        .doc('current')
        .get();
    return doc.data();
  }

  // ── Bookmark ───────────────────────────────────────────────────────────────

  Future<void> toggleBookmark({
    required String uid,
    required String requestId,
    required Map<String, dynamic> requestData,
    required bool currentlyBookmarked,
  }) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(requestId);

    if (currentlyBookmarked) {
      await ref.delete();
    } else {
      await ref.set({
        'id': requestId,
        'type': 'request',
        'title': requestData['title'],
        'category': requestData['category'],
        'thumbnailUrl': (requestData['imageUrls'] as List?)?.first ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Donate funds ───────────────────────────────────────────────────────────

  Future<String?> donateFunds({
    required String donorUid,
    required String requestId,
    required double amount,
  }) async {
    try {
      // Write to the request's donations subcollection
      final donationRef = _db
          .collection(_col)
          .doc(requestId)
          .collection('donations')
          .doc();

      await donationRef.set({
        'donorUid': donorUid,
        'amount': amount,
        'type': 'funds',
        'status': 'pledged', // donor has 3 days to fulfil
        'pledgedAt': FieldValue.serverTimestamp(),
        'dueAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
      });

      // Increment donor count
      await _db.collection(_col).doc(requestId).update({
        'donorCount': FieldValue.increment(1),
        'fundraiserRaised': FieldValue.increment(amount),
      });

      // Notify the beneficiary
      await _db
          .collection('users')
          .doc(requestId) // NOTE: replace with beneficiary uid from doc
          .collection('notifications')
          .add({
        'type': 'user',
        'title': 'Someone pledged a donation!',
        'body': 'A donor has pledged ₱${amount.toStringAsFixed(0)} to your request.',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to record donation. Please try again.';
    }
  }

  // ── Donate items ───────────────────────────────────────────────────────────

  Future<String?> donateItems({
    required String donorUid,
    required String requestId,
    required List<Map<String, dynamic>> items, // [{name, qty}]
  }) async {
    try {
      final donationRef = _db
          .collection(_col)
          .doc(requestId)
          .collection('donations')
          .doc();

      await donationRef.set({
        'donorUid': donorUid,
        'items': items,
        'type': 'items',
        'status': 'pledged',
        'pledgedAt': FieldValue.serverTimestamp(),
        'dueAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
      });

      await _db.collection(_col).doc(requestId).update({
        'donorCount': FieldValue.increment(1),
        'itemsDonated': FieldValue.increment(
          items.fold<int>(0, (sum, item) => sum + (item['qty'] as int? ?? 0)),
        ),
      });

      return null;
    } catch (e) {
      return 'Failed to record item donation. Please try again.';
    }
  }

  // ── Report ─────────────────────────────────────────────────────────────────

  Future<void> reportContent({
    required String reporterUid,
    required String targetId,
    required String targetType, // 'request' | 'event' | 'message' | 'user'
    required String title,
    required String description,
  }) async {
    await _db.collection('reports').add({
      'reporterUid': reporterUid,
      'targetId': targetId,
      'targetType': targetType,
      'title': title,
      'description': description,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Collection : aid_requests
// Document  : {requestId}
// Fields    : id, uid, title, description, category, aidRequestType,
//             location, postDurationDays, expiresAt, imageUrls,
//             fundraiserGoal, fundraiserRaised, acceptedItems,
//             itemsDonated, donorCount, status, isExpired, createdAt
// Subcollection: aid_requests/{id}/donations
//   Fields: donorUid, amount, type, status, pledgedAt, dueAt
// React query:
//   const q = query(collection(db, 'aid_requests'),
//     where('status', '==', 'approved'),
//     where('isExpired', '==', false),
//     orderBy('createdAt', 'desc'));
// Notes:
//   - status: 'pending' | 'approved' | 'rejected' | 'completed' | 'cancelled'
//   - Admin approves via update({ status: 'approved' })
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
