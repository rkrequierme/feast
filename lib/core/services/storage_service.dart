// lib/core/services/storage_service.dart
//
// Firebase Storage uploads with client-side AES-256 encryption for legal IDs.
// All other uploads (post images, profile pictures) are stored unencrypted.

import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // ─── AES-256 Key & IV ──────────────────────────────────────────────────
  // IMPORTANT: In a real production app store the key in a secure location
  // such as Firebase Remote Config (server-side only), or derive it from the
  // admin's credentials. For this mobile client, a hardcoded key is used
  // as a placeholder — replace before going live.
  static final enc.Key _aesKey = enc.Key.fromUtf8(
    'FEASTCharityMgmt2024SecureKey!32', // exactly 32 bytes → AES-256
  );
  static final enc.IV _aesIv = enc.IV.fromUtf8('FEASTiv16Bytes!!'); // 16 bytes

  // ─── Allowed Legal ID Extensions ────────────────────────────────────────

  static const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];

  // ─── Upload Legal ID (Encrypted) ────────────────────────────────────────

  /// Encrypts [file] client-side with AES-256-CBC then uploads to Storage.
  /// Returns the download URL of the encrypted blob.
  /// Throws [StorageException] with a user-friendly message on failure.
  Future<String> uploadLegalId(File file, String uid) async {
    // Validate extension
    final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      throw StorageException(
        'Invalid file type. Only JPG, JPEG, PNG, WEBP, and GIF are accepted.',
      );
    }

    try {
      // Read bytes
      final bytes = await file.readAsBytes();

      // Encrypt with AES-256-CBC
      final encrypter = enc.Encrypter(enc.AES(_aesKey, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encryptBytes(bytes, iv: _aesIv);
      final encryptedBytes = Uint8List.fromList(encrypted.bytes);

      // Upload encrypted blob — stored as .enc to signal it is encrypted
      final ref = _storage.ref('legal_ids/$uid/${_uuid.v4()}.enc');
      final task = await ref.putData(
        encryptedBytes,
        SettableMetadata(
          contentType: 'application/octet-stream',
          customMetadata: {
            'originalExt': ext,
            'encrypted': 'true',
            'algorithm': 'AES-256-CBC',
          },
        ),
      );

      return await task.ref.getDownloadURL();
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to upload ID. Please try again.');
    }
  }

  /// Decrypts the encrypted bytes downloaded from Storage.
  /// Called by admins only during registration review.
  static Uint8List decryptLegalId(Uint8List encryptedBytes) {
    final encrypter = enc.Encrypter(enc.AES(_aesKey, mode: enc.AESMode.cbc));
    final decrypted = encrypter.decryptBytes(
      enc.Encrypted(encryptedBytes),
      iv: _aesIv,
    );
    return Uint8List.fromList(decrypted);
  }

  // ─── Upload Post Images (Unencrypted) ────────────────────────────────────

  /// Uploads one or more post images and returns their download URLs.
  Future<List<String>> uploadPostImages(
    List<File> files,
    String collection, // 'aid_requests' | 'charity_events'
    String postId,
  ) async {
    final urls = <String>[];
    for (final file in files) {
      final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
      if (!_allowedExtensions.contains(ext)) continue;

      final ref = _storage.ref('$collection/$postId/${_uuid.v4()}.$ext');
      final task = await ref.putFile(file);
      urls.add(await task.ref.getDownloadURL());
    }
    return urls;
  }

  // ─── Upload Profile Picture ───────────────────────────────────────────

  Future<String> uploadProfilePicture(File file, String uid) async {
    final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    final ref = _storage.ref('profile_pictures/$uid/avatar.$ext');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  // ─── Upload Chat Attachment ────────────────────────────────────────────

  /// Chat attachments accept ALL file types.
  Future<String> uploadChatAttachment(File file, String chatId) async {
    final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    final fileName = '${_uuid.v4()}.$ext';
    final ref = _storage.ref('chat_attachments/$chatId/$fileName');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => message;
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Storage paths:
//   legal_ids/{uid}/{uuid}.enc  — AES-256-CBC encrypted legal ID image
//   aid_requests/{postId}/{uuid}.ext — post images
//   charity_events/{postId}/{uuid}.ext — event images
//   profile_pictures/{uid}/avatar.ext — profile pictures
//   chat_attachments/{chatId}/{uuid}.ext — chat files (all types)
//
// React admin decrypt flow (admin web dashboard):
//   1. Download the .enc blob as ArrayBuffer.
//   2. Use Web Crypto API (AES-CBC, 256-bit) with the shared key/IV
//      stored in a server-side Cloud Function — NEVER expose the key
//      in React client code.
//   3. Create an Object URL from the decrypted bytes and display/download.
//   4. Immediately revoke access after admin decision is saved.
//
// Security: Storage rules must deny public read on legal_ids/.
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
