import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MessageService
// Privacy-first messaging: messages readable ONLY by participants.
// Admins have NO read access to message content (enforced by Security Rules).
// ─────────────────────────────────────────────────────────────────────────────

class MessageService {
  MessageService._();
  static final MessageService instance = MessageService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const _chats = 'chats';

  // ── Create DM or group chat ────────────────────────────────────────────────

  /// Creates a DM (2 participants) or group (3+). Returns the chatId.
  Future<String?> createChat({
    required List<String> participantUids,
    String? groupName,
    String? groupDescription,
  }) async {
    try {
      final isGroup = participantUids.length > 2;
      final chatRef = _db.collection(_chats).doc();
      final chatId = chatRef.id;

      await chatRef.set({
        'id': chatId,
        'participants': participantUids,
        'isGroup': isGroup,
        'groupName': groupName ?? '',
        'groupDescription': groupDescription ?? '',
        'groupImageUrl': '',
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'personal', // 'personal' | 'event'
        'notificationsMutedBy': [],
      });

      // Add reference to each participant's userChats sub-collection
      for (final uid in participantUids) {
        await _db
            .collection('users')
            .doc(uid)
            .collection('chats')
            .doc(chatId)
            .set({'chatId': chatId, 'unreadCount': 0});
      }

      return chatId;
    } catch (e) {
      debugPrint('createChat error: $e');
      return null;
    }
  }

  // ── Create event group chat (called after admin approval) ──────────────────

  Future<String?> createEventGroupChat({
    required String eventId,
    required String eventTitle,
    required List<String> organizerUids,
  }) async {
    try {
      final chatRef = _db.collection(_chats).doc();
      final chatId = chatRef.id;

      await chatRef.set({
        'id': chatId,
        'participants': organizerUids,
        'isGroup': true,
        'groupName': eventTitle,
        'groupDescription': 'Official group chat for $eventTitle.',
        'groupImageUrl': '',
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'event',
        'eventId': eventId,
        'notificationsMutedBy': [],
      });

      // Update the event doc with the chat id
      await _db.collection('charity_events').doc(eventId).update({
        'groupChatId': chatId,
      });

      for (final uid in organizerUids) {
        await _db
            .collection('users')
            .doc(uid)
            .collection('chats')
            .doc(chatId)
            .set({'chatId': chatId, 'unreadCount': 0});
      }

      return chatId;
    } catch (e) {
      return null;
    }
  }

  // ── Send message ───────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String chatId,
    required String senderUid,
    required String text,
    List<File>? attachments,
  }) async {
    try {
      // Upload any attachments first
      final attachmentUrls = <Map<String, String>>[];
      if (attachments != null) {
        for (int i = 0; i < attachments.length; i++) {
          final ref = _storage.ref(
            'chat_attachments/$chatId/${DateTime.now().millisecondsSinceEpoch}_$i',
          );
          await ref.putFile(attachments[i]);
          final url = await ref.getDownloadURL();
          attachmentUrls.add({
            'url': url,
            'name': attachments[i].path.split('/').last,
          });
        }
      }

      final msgRef = _db
          .collection(_chats)
          .doc(chatId)
          .collection('messages')
          .doc();

      await msgRef.set({
        'id': msgRef.id,
        'senderUid': senderUid,
        'text': text,
        'attachments': attachmentUrls,
        'sentAt': FieldValue.serverTimestamp(),
        'readBy': [senderUid],
      });

      // Update last message preview on the chat doc
      await _db.collection(_chats).doc(chatId).update({
        'lastMessage': text.isNotEmpty
            ? text
            : '${attachmentUrls.length} attachment(s)',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('sendMessage error: $e');
    }
  }

  // ── Message stream ─────────────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String chatId) {
    return _db
        .collection(_chats)
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots();
  }

  // ── User's chat list stream ────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> userChatsStream(String uid) {
    return _db
        .collection(_chats)
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  // ── Chat info stream ───────────────────────────────────────────────────────

  Stream<DocumentSnapshot<Map<String, dynamic>>> chatStream(String chatId) {
    return _db.collection(_chats).doc(chatId).snapshots();
  }

  // ── Add member to group ────────────────────────────────────────────────────

  Future<void> addMember(String chatId, String newUid) async {
    await _db.collection(_chats).doc(chatId).update({
      'participants': FieldValue.arrayUnion([newUid]),
    });
    await _db
        .collection('users')
        .doc(newUid)
        .collection('chats')
        .doc(chatId)
        .set({'chatId': chatId, 'unreadCount': 0});
  }

  // ── Remove member from group ───────────────────────────────────────────────

  Future<void> removeMember(String chatId, String targetUid) async {
    await _db.collection(_chats).doc(chatId).update({
      'participants': FieldValue.arrayRemove([targetUid]),
    });
    await _db
        .collection('users')
        .doc(targetUid)
        .collection('chats')
        .doc(chatId)
        .delete();
  }

  // ── Mute / unmute notifications ────────────────────────────────────────────

  Future<void> toggleMuteNotifications(
    String chatId,
    String uid,
    bool mute,
  ) async {
    await _db.collection(_chats).doc(chatId).update({
      'notificationsMutedBy': mute
          ? FieldValue.arrayUnion([uid])
          : FieldValue.arrayRemove([uid]),
    });
  }

  // ── Edit group details ─────────────────────────────────────────────────────

  Future<void> updateGroupDetails({
    required String chatId,
    String? groupName,
    String? groupDescription,
    File? newImage,
  }) async {
    final updates = <String, dynamic>{};
    if (groupName != null) updates['groupName'] = groupName;
    if (groupDescription != null) updates['groupDescription'] = groupDescription;
    if (newImage != null) {
      final ref = _storage.ref('group_images/$chatId/avatar.jpg');
      await ref.putFile(newImage);
      updates['groupImageUrl'] = await ref.getDownloadURL();
    }
    await _db.collection(_chats).doc(chatId).update(updates);
  }

  // ── Delete event chat on event conclusion ──────────────────────────────────

  Future<void> deleteEventChat(String chatId) async {
    // NOTE: Full subcollection deletion should be handled by a Cloud Function.
    // This marks the chat as deleted for the front-end.
    await _db.collection(_chats).doc(chatId).update({'deleted': true});
  }
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Collection : chats
// Document  : {chatId}
// Fields    : id, participants (array of uids), isGroup, groupName,
//             groupDescription, groupImageUrl, lastMessage, lastMessageAt,
//             type ('personal'|'event'), eventId, notificationsMutedBy, createdAt
// Subcollection: chats/{chatId}/messages
//   Fields: id, senderUid, text, attachments (array), sentAt, readBy (array)
// React query (user's chats):
//   const q = query(collection(db, 'chats'),
//     where('participants', 'array-contains', uid),
//     orderBy('lastMessageAt', 'desc'));
// CRITICAL Security Rule:
//   allow read, write: if request.auth.uid in resource.data.participants;
//   (Admin accounts must NOT appear in participants — zero admin read access)
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
